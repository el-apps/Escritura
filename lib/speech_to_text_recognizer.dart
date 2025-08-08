import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'speech_recognizer.dart';

class SpeechToTextRecognizer implements SpeechRecognizer {
  final SpeechToText _speechToText = SpeechToText();
  bool _isListening = false;

  @override
  void Function(String text, bool isFinal)? onResult;

  @override
  void Function(String error)? onError;

  @override
  void Function(String status)? onStatus;

  @override
  bool get isListening => _isListening;

  @override
  bool get isAvailable => _speechToText.isAvailable;

  @override
  Future<bool> initialize() async {
    return await _speechToText.initialize(
      onError: (val) => onError?.call(val.toString()),
      onStatus: (val) {
        onStatus?.call(val);
        if (val == 'done' || val == 'notListening') {
          _isListening = false;
        }
      },
    );
  }

  @override
  Future<void> startListening() async {
    if (!_speechToText.isAvailable) {
      onError?.call('Speech recognition not available');
      return;
    }

    _isListening = true;
    
    await _speechToText.listen(
      onResult: (SpeechRecognitionResult result) {
        onResult?.call(result.recognizedWords, result.finalResult);
      },
      listenFor: const Duration(minutes: 5),
      pauseFor: const Duration(seconds: 30),
      localeId: 'en_US',
      listenOptions: SpeechListenOptions(
        listenMode: ListenMode.dictation,
        partialResults: true,
        onDevice: true,
      ),
    );
  }

  @override
  Future<void> stopListening() async {
    await _speechToText.stop();
    _isListening = false;
  }
}
