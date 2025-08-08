import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'speech_recognizer.dart';
import 'whisper_speech_recognizer.dart';
import 'speech_to_text_recognizer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Escritura',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.brown),
        useMaterial3: true,
      ),
      home: const EscrituraHomePage(),
    );
  }
}

class EscrituraHomePage extends StatefulWidget {
  const EscrituraHomePage({super.key});

  @override
  State<EscrituraHomePage> createState() => _EscrituraHomePageState();
}

class _EscrituraHomePageState extends State<EscrituraHomePage> {
  late SpeechRecognizer _speechRecognizer;
  bool _speechEnabled = false;
  bool _isListening = false;
  bool _isProcessing = false;
  String _lastWords = '';
  String _fullTranscript = '';
  bool _useWhisper = true; // Toggle between Whisper and SpeechToText

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  void _initSpeech() async {
    var status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      _showPermissionDialog();
      return;
    }

    // Choose speech recognizer implementation
    _speechRecognizer = _useWhisper
        ? WhisperSpeechRecognizer()
        : SpeechToTextRecognizer();

    // Set up callbacks
    _speechRecognizer.onError = (error) {
      print('Speech recognition error: $error');
      setState(() {
        _isListening = false;
      });
    };

    _speechRecognizer.onStatus = (status) {
      print('Speech recognition status: $status');
      if (status == 'processing') {
        setState(() {
          _isProcessing = true;
        });
      } else if (status == 'done' || status == 'notListening') {
        setState(() {
          _isListening = false;
          _isProcessing = false;
        });
      }
    };

    _speechRecognizer.onResult = (text, isFinal) {
      setState(() {
        _lastWords = text;
        if (isFinal) {
          _fullTranscript += '$text\n';
        }
      });
    };

    _speechEnabled = await _speechRecognizer.initialize();
    setState(() {});
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Permission Required'),
          content: const Text(
            'Microphone permission is required for speech transcription.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
              child: const Text('Open Settings'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _startListening() async {
    if (!_speechEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Speech recognition not available')),
      );
      return;
    }

    setState(() {
      _isListening = true;
      _fullTranscript = '';
      _lastWords = '';
    });

    await _speechRecognizer.startListening();
  }

  void _stopListening() async {
    setState(() {
      _isProcessing = true;
    });
    await _speechRecognizer.stopListening();
    setState(() {
      _isListening = false;
      _isProcessing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Escritura'),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _useWhisper = !_useWhisper;
              });
              _initSpeech();
            },
            icon: Icon(_useWhisper ? Icons.psychology : Icons.mic),
            tooltip: _useWhisper
                ? 'Switch to SpeechToText'
                : 'Switch to Whisper',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _speechEnabled
                    ? Colors.green.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _speechEnabled ? Colors.green : Colors.red,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _speechEnabled ? Icons.mic : Icons.mic_off,
                    color: _speechEnabled ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _speechEnabled
                        ? 'Speech recognition ready (${_useWhisper ? 'Whisper' : 'SpeechToText'})'
                        : 'Speech recognition not available',
                    style: TextStyle(
                      color: _speechEnabled ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            if (_isListening || _isProcessing) ...[
              Text(
                _isProcessing ? 'Processing...' : 'Listening...',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _isProcessing ? Colors.orange : Colors.blue,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: (_isProcessing ? Colors.orange : Colors.blue)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _isProcessing ? Colors.orange : Colors.blue,
                  ),
                ),
                child: Row(
                  children: [
                    if (_isProcessing) ...[
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: Text(
                        _isProcessing
                            ? 'Transcribing audio...'
                            : (_lastWords.isEmpty
                                  ? 'Say something...'
                                  : _lastWords),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _fullTranscript.isEmpty
                        ? 'Transcript will appear here...'
                        : _fullTranscript,
                    style: TextStyle(
                      fontSize: 16,
                      color: _fullTranscript.isEmpty
                          ? Colors.grey
                          : Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: switch ((_isProcessing, _isListening)) {
          (true, _) => null,
          (false, true) => _stopListening,
          (false, false) => _startListening,
        },
        backgroundColor: (_isListening || _isProcessing)
            ? Colors.red
            : Colors.blue,
        child: switch ((_isProcessing, _isListening)) {
          (true, _) => const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          (false, true) => const Icon(Icons.stop, color: Colors.white),
          (false, false) => const Icon(Icons.mic, color: Colors.white),
        },
      ),
    );
  }
}
