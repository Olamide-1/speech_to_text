import 'package:flutter/material.dart';
import 'package:speech_app/homepage.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:speech_to_text/speech_to_text.dart';

class TextPage extends StatefulWidget {
  const TextPage({Key? key}) : super(key: key);
  @override
  State<TextPage> createState() => _TextPageState();
}

class _TextPageState extends State<TextPage> {
  SpeechToText speechtotext = SpeechToText();
  var _text = "Hold the record button to get started";
  var _isRecording = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Transcribe',
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
                MaterialPageRoute(builder: (context) => HomePage()),
              );
            }),
        actions: [
          IconButton(
              icon: const Icon(
                Icons.save_alt_outlined,
              ),
              color: Colors.purple,
              onPressed: () {}),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: AvatarGlow(
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
              var available = await speechtotext.initialize();
              if (available) {
                setState(() {
                  _isRecording = true;
                  speechtotext.listen(onResult: (result) {
                    _text = result.recognizedWords;
                  });
                });
              }
            }
          },
          onTapUp: (details) {
            setState(() {
              _isRecording = false;
            });
            speechtotext.stop();
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
      body: SingleChildScrollView(
        reverse: true,
        physics: const BouncingScrollPhysics(),
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.7,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          margin: EdgeInsets.only(bottom: 150),
          child: Text(
            _text,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
