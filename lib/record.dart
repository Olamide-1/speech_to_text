import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sound_lite/flutter_sound.dart';
import 'package:google_speech/google_speech.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rxdart/rxdart.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:avatar_glow/avatar_glow.dart';

const int kAudioSampleRate = 16000;
const int kAudioNumChannels = 1;

class RecordPage extends StatefulWidget {
  const RecordPage({Key? key}) : super(key: key);

  @override
  State<RecordPage> createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  SpeechToText speechToText = SpeechToText();
  bool _isRecording = false;
  String _text = 'Hold the record button to get started';
  BehaviorSubject<List<int>>? _audioStream;
  StreamController<Food>? _recordingDataController;
  StreamSubscription? _recordingDataSubscription;

  @override
  void initState() {
    super.initState();
  }

  Future<bool> checkBatteryLevel() async {
    // Perform battery level checking here, for demonstration purposes, let's assume the battery level is below 20%
    return false;
  }

  void streamingRecognize() async {
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
        sampleRate: kAudioSampleRate);

    final bool isCloudBased = await checkBatteryLevel();

    if (isCloudBased) {
      await performCloudSpeechToText();
    } else {
      await performLocalSpeechToText();
    }
  }

  Future<void> performCloudSpeechToText() async {
    final serviceAccount = ServiceAccount.fromString(
        (await rootBundle.loadString('speechtotext-392700-95778e2b587d.json')));
    final speechToText = SpeechToText.viaServiceAccount(serviceAccount);
    final config = _getConfig();

    final responseStream = speechToText.streamingRecognize(
        StreamingRecognitionConfig(config: config, interimResults: true),
        _audioStream!);

    var responseText = '';

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

  void stopRecording() async {
    await _recorder.stopRecorder();
    await _audioStream?.close();
    await _recordingDataSubscription?.cancel();
    setState(() {
      _isRecording = false;
    });
  }

  RecognitionConfig _getConfig() => RecognitionConfig(
      encoding: AudioEncoding.LINEAR16,
      model: RecognitionModel.basic,
      enableAutomaticPunctuation: true,
      sampleRateHertz: 16000,
      languageCode: 'en-US');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Real-time Speech to Text'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            _RecognizeContent(
              text: _text,
            ),
            AvatarGlow(
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

class _RecognizeContent extends StatelessWidget {
  final String text;

  const _RecognizeContent({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: <Widget>[
          const Text(
            'The text recognized by the Speech API:',
          ),
          const SizedBox(
            height: 16.0,
          ),
          Text(
            text,
            style: Theme.of(context).textTheme.bodyText1,
          ),
        ],
      ),
    );
  }
}
