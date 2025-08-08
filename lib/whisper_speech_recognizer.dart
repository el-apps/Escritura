import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:whisper_ggml/whisper_ggml.dart';
import 'speech_recognizer.dart';

class WhisperSpeechRecognizer implements SpeechRecognizer {
  WhisperGgml? _whisper;
  bool _isListening = false;
  bool _isAvailable = false;
  StreamSubscription? _audioSubscription;

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
      
      // Initialize Whisper with a small model
      _whisper = WhisperGgml();
      
      // Load the model (you'll need to add the model file to assets)
      await _whisper!.init(
        modelPath: 'assets/models/ggml-tiny.en.bin',
        language: 'en',
      );
      
      _isAvailable = true;
      onStatus?.call('Whisper initialized successfully');
      return true;
    } catch (e) {
      onError?.call('Failed to initialize Whisper: $e');
      _isAvailable = false;
      return false;
    }
  }

  @override
  Future<void> startListening() async {
    if (!_isAvailable || _whisper == null) {
      onError?.call('Whisper not available');
      return;
    }

    if (_isListening) {
      return;
    }

    try {
      _isListening = true;
      onStatus?.call('listening');
      
      // Start recording audio
      await _whisper!.startRecording();
      
      // Set up a timer to periodically get transcription
      Timer.periodic(const Duration(seconds: 2), (timer) async {
        if (!_isListening) {
          timer.cancel();
          return;
        }
        
        try {
          // Get partial transcription
          final result = await _whisper!.getTranscription();
          if (result.isNotEmpty) {
            onResult?.call(result, false);
          }
        } catch (e) {
          // Ignore partial transcription errors
        }
      });
      
    } catch (e) {
      _isListening = false;
      onError?.call('Failed to start listening: $e');
      onStatus?.call('notListening');
    }
  }

  @override
  Future<void> stopListening() async {
    if (!_isListening || _whisper == null) {
      return;
    }

    try {
      _isListening = false;
      onStatus?.call('done');
      
      // Stop recording and get final transcription
      await _whisper!.stopRecording();
      final finalResult = await _whisper!.getTranscription();
      
      if (finalResult.isNotEmpty) {
        onResult?.call(finalResult, true);
      }
      
      onStatus?.call('notListening');
    } catch (e) {
      onError?.call('Failed to stop listening: $e');
      onStatus?.call('notListening');
    }
  }

  void dispose() {
    _audioSubscription?.cancel();
    _whisper?.dispose();
  }
}
