import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:whisper_ggml/whisper_ggml.dart';
import 'speech_recognizer.dart';

class WhisperSpeechRecognizer implements SpeechRecognizer {
  final WhisperModel _model = WhisperModel.tiny;
  final AudioRecorder _audioRecorder = AudioRecorder();
  final WhisperController _whisperController = WhisperController();
  bool _isListening = false;
  bool _isAvailable = false;
  String? _currentRecordingPath;

  @override
  void Function(String text, bool isFinal)? onResult;

  @override
  void Function(String error)? onError;

  @override
  void Function(String status)? onStatus;

  @override
  bool get isListening => _isListening;

  @override
  bool get isAvailable => _isAvailable;

  @override
  Future<bool> initialize() async {
    try {
      onStatus?.call('Initializing Whisper...');
      
      // Check microphone permission
      if (!await _audioRecorder.hasPermission()) {
        onError?.call('Microphone permission not granted');
        return false;
      }
      
      // Initialize the model
      await _initModel();
      
      _isAvailable = true;
      onStatus?.call('Whisper initialized successfully');
      return true;
    } catch (e) {
      onError?.call('Failed to initialize Whisper: $e');
      _isAvailable = false;
      return false;
    }
  }

  Future<void> _initModel() async {
    try {
      // Try initializing the model from assets first
      final bytesBase = await rootBundle.load('assets/ggml-${_model.modelName}.bin');
      final modelPathBase = await _whisperController.getPath(_model);
      final fileBase = File(modelPathBase);
      await fileBase.writeAsBytes(bytesBase.buffer
          .asUint8List(bytesBase.offsetInBytes, bytesBase.lengthInBytes));
    } catch (e) {
      // On error try downloading the model
      onStatus?.call('Downloading Whisper model...');
      await _whisperController.downloadModel(_model);
    }
  }

  @override
  Future<void> startListening() async {
    if (!_isAvailable) {
      onError?.call('Whisper not available');
      return;
    }

    if (_isListening) {
      return;
    }

    try {
      _isListening = true;
      onStatus?.call('listening');
      
      // Start recording
      final Directory appDirectory = await getTemporaryDirectory();
      _currentRecordingPath = '${appDirectory.path}/whisper_recording_${DateTime.now().millisecondsSinceEpoch}.m4a';
      
      await _audioRecorder.start(
        const RecordConfig(),
        path: _currentRecordingPath!,
      );
      
    } catch (e) {
      _isListening = false;
      onError?.call('Failed to start listening: $e');
      onStatus?.call('notListening');
    }
  }

  @override
  Future<void> stopListening() async {
    if (!_isListening) {
      return;
    }

    try {
      _isListening = false;
      onStatus?.call('processing');
      
      // Stop recording
      final audioPath = await _audioRecorder.stop();
      
      if (audioPath != null) {
        // Transcribe the audio
        final result = await _whisperController.transcribe(
          model: _model,
          audioPath: audioPath,
          lang: 'en',
        );
        
        if (result?.transcription.text != null && result!.transcription.text.isNotEmpty) {
          onResult?.call(result.transcription.text, true);
        } else {
          onResult?.call('No speech detected', true);
        }
        
        // Clean up the temporary file
        try {
          await File(audioPath).delete();
        } catch (e) {
          // Ignore cleanup errors
        }
      } else {
        onError?.call('No recording found');
      }
      
      onStatus?.call('notListening');
    } catch (e) {
      onError?.call('Failed to stop listening: $e');
      onStatus?.call('notListening');
    }
  }

  void dispose() {
    if (_isListening) {
      _audioRecorder.stop();
    }
  }
}
