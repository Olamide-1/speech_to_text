import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sound_lite/flutter_sound.dart'; //flutter sound
import 'package:google_speech/google_speech.dart'
    as google_speech; //google offloading API
import 'package:permission_handler/permission_handler.dart'; //audio permissions
import 'package:rxdart/rxdart.dart';
import 'package:speech_app/login.dart';
import 'package:speech_to_text/speech_to_text.dart'; //flutter speech to text package
import 'package:avatar_glow/avatar_glow.dart'; //icon glow
import 'package:internet_connection_checker/internet_connection_checker.dart'; //internet connection

// Constants for audio recording
const int kAudioSampleRate = 16000;
const int kAudioNumChannels = 1;

class TextPage extends StatefulWidget {
  const TextPage({Key? key}) : super(key: key);

  @override
  State<TextPage> createState() => _TextPageState();
}

class _TextPageState extends State<TextPage> {
  // FlutterSoundRecorder instance for audio recording
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();

  // SpeechToText instance for local speech recognition
  SpeechToText speechToText = SpeechToText();

  // State variables
  bool _isRecording = false;
  String _text = 'Hold the record button to get started';
  BehaviorSubject<List<int>>? _audioStream;
  StreamController<Food>? _recordingDataController;
  StreamSubscription? _recordingDataSubscription;

  @override
  void initState() {
    super.initState();
  }

  // Function to check network connectivity
  Future<bool> checkNetworkConnectivity() async {
    return await InternetConnectionChecker().hasConnection;
  }

  // Function to simulate battery level checking (replace with actual implementation)
  Future<bool> checkBatteryLevel() async {
    // Simulate battery level checking delay (you can replace this with an actual battery level checking)
    await Future.delayed(Duration(seconds: 2));

    // For demonstration purposes, assume the battery level is 15% (below 20%)
    double batteryLevel = 15;

    // Check if the battery level is below 20%
    if (batteryLevel < 20) {
      return true; // Battery level is below 20%
    } else {
      return false; // Battery level is above or equal to 20%
    }
  }

  // Function to start streaming audio for speech recognition
  Future<void> streamingRecognize() async {
    await _recorder.openAudioSession();
    // Stream to be consumed by speech recognizer
    _audioStream = BehaviorSubject<List<int>>();

    // Create recording stream
    _recordingDataController = StreamController<Food>();
    _recordingDataSubscription =
        _recordingDataController?.stream.listen((buffer) {
      if (buffer is FoodData) {
        _audioStream!.add(buffer.data!);
      }
    });

    setState(() {
      _isRecording = true;
    });

    await Permission.microphone.request();

    await _recorder.startRecorder(
      toStream: _recordingDataController!.sink,
      codec: Codec.pcm16,
      numChannels: kAudioNumChannels,
      sampleRate: kAudioSampleRate,
    );

    await performSpeechToText();
  }

  // Function to perform speech recognition (local or cloud-based)
  Future<void> performSpeechToText() async {
    bool isNetworkConnected = await checkNetworkConnectivity();
    bool isBatteryLow = await checkBatteryLevel();

    if (isNetworkConnected && !isBatteryLow) {
      await performCloudSpeechToText();
    } else {
      await performLocalSpeechToText();
    }
  }

  // Function to perform cloud-based speech recognition using Google Cloud Speech API
  Future<void> performCloudSpeechToText() async {
    // Load the service account credentials from a JSON file in assets folder
    final serviceAccount = google_speech.ServiceAccount.fromString(
      (await rootBundle.loadString(
          'speechtotext-392700-95778e2b587d.json')), //created on google cloud
    );

    // Create an instance of the Google Cloud Speech API
    final speechToText =
        google_speech.SpeechToText.viaServiceAccount(serviceAccount);
    final config = _getConfig();

    // Stream the audio to the cloud for speech recognition
    final responseStream = speechToText.streamingRecognize(
      google_speech.StreamingRecognitionConfig(
          config: config, interimResults: true),
      _audioStream!,
    );

    var responseText = '';

    // Listen for the response from the cloud
    responseStream.listen((data) {
      final currentText =
          data.results.map((e) => e.alternatives.first.transcript).join('\n');

      if (data.results.first.isFinal) {
        responseText += '\n' + currentText;
        setState(() {
          _text = responseText;
        });
      } else {
        setState(() {
          _text = responseText + '\n' + currentText;
        });
      }
    }, onDone: () {
      setState(() {
        _isRecording = false;
      });
    });
  }

  // Function to perform local speech recognition
  Future<void> performLocalSpeechToText() async {
    var available = await speechToText.initialize();
    if (available) {
      speechToText.listen(onResult: (result) {
        setState(() {
          _text = result.recognizedWords;
        });
      });
    } else {
      setState(() {
        _isRecording = false;
        _text = 'Speech to text is not available on this device.';
      });
    }
  }

  // Function to stop audio recording
  void stopRecording() async {
    await _recorder.stopRecorder();
    await _audioStream?.close();
    await _recordingDataSubscription?.cancel();
    setState(() {
      _isRecording = false;
    });
  }

  // Function to get the Google Cloud Speech API configuration
  google_speech.RecognitionConfig _getConfig() =>
      google_speech.RecognitionConfig(
        encoding: google_speech.AudioEncoding.LINEAR16,
        model: google_speech.RecognitionModel.basic,
        enableAutomaticPunctuation: true,
        sampleRateHertz: 16000,
        languageCode: 'en-US',
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'VOICEY',
          style: TextStyle(
            color: Colors.purple,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_outlined),
          color: Colors.purple,
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LoginPage()),
            );
          },
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            _RecognizeContent(
              text: _text,
            ),
            AvatarGlow(
              //glow effect around the icon
              endRadius: 100.0,
              animate: _isRecording,
              duration: const Duration(milliseconds: 4000),
              glowColor: Colors.purple,
              repeat: true,
              repeatPauseDuration: Duration(milliseconds: 100),
              showTwoGlows: true,
              child: GestureDetector(
                onTapDown: (details) async {
                  if (!_isRecording) {
                    await streamingRecognize();
                  }
                },
                onTapUp: (details) {
                  if (_isRecording) {
                    stopRecording();
                  }
                },
                child: CircleAvatar(
                  backgroundColor: Colors.purple,
                  radius: 35,
                  child: Icon(
                    _isRecording ? Icons.mic_outlined : Icons.mic_none_outlined,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget for displaying the recognized text
class _RecognizeContent extends StatelessWidget {
  final String text;

  const _RecognizeContent({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: <Widget>[
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }
}
