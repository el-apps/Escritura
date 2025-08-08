abstract class SpeechRecognizer {
  Future<bool> initialize();
  Future<void> startListening();
  Future<void> stopListening();
  bool get isListening;
  bool get isAvailable;
  
  // Callbacks
  void Function(String text, bool isFinal)? onResult;
  void Function(String error)? onError;
  void Function(String status)? onStatus;
}

class SpeechRecognitionResult {
  final String recognizedWords;
  final bool finalResult;

  SpeechRecognitionResult({
    required this.recognizedWords,
    required this.finalResult,
  });
}
