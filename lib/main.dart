import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';

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
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  bool _isListening = false;
  String _lastWords = '';
  String _fullTranscript = '';

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

    _speechEnabled = await _speechToText.initialize(
      onError: (val) {
        print('Speech recognition error: $val');
        setState(() {
          _isListening = false;
        });
      },
      onStatus: (val) {
        print('Speech recognition status: $val');
        if (val == 'done' || val == 'notListening') {
          setState(() {
            _isListening = false;
          });
        }
      },
    );

    setState(() {});

    if (_speechEnabled) {
      var locales = await _speechToText.locales();
      print('Available locales: ${locales.length}');

      var offlineLocale = locales
          .where((locale) => locale.localeId.startsWith('en'))
          .firstOrNull;

      if (offlineLocale != null) {
        print('Using locale: ${offlineLocale.localeId}');
      }
    }
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
      _lastWords = '';
    });

    await _speechToText.listen(
      onResult: _onSpeechResult,
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

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {
      _isListening = false;
    });
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = result.recognizedWords;
      if (result.finalResult) {
        _fullTranscript += '${_lastWords}\n';
      }
    });
  }

  void _clearTranscript() {
    setState(() {
      _fullTranscript = '';
      _lastWords = '';
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
            onPressed: _clearTranscript,
            icon: const Icon(Icons.clear),
            tooltip: 'Clear transcript',
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
                        ? 'Speech recognition ready'
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

            if (_isListening) ...[
              const Text(
                'Listening...',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.blue),
                ),
                child: Text(
                  _lastWords.isEmpty ? 'Say something...' : _lastWords,
                  style: const TextStyle(fontSize: 16),
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
        onPressed: _isListening ? _stopListening : _startListening,
        backgroundColor: _isListening ? Colors.red : Colors.blue,
        child: Icon(_isListening ? Icons.stop : Icons.mic, color: Colors.white),
      ),
    );
  }
}
