import 'package:flutter/material.dart';
import 'package:speech_app/record.dart';
import 'package:speech_app/text.dart';

import 'NavBar.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavBar(),
      appBar: AppBar(
        title: Text(
          'VOICEY',
          style: TextStyle(
            color: Colors.purple,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/background.jpg'),
            //alignment: Alignment.bottomCenter,
            alignment: Alignment.topCenter,
            fit: BoxFit.fitWidth,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 100.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              //Text('Save Time With Our Speech Transcription.'),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => RecordPage()),
                      );
                    },
                    icon: Icon(Icons.radio_button_checked_outlined),
                    iconSize: 80.0,
                    color: Colors.purple,
                    alignment: Alignment.bottomCenter,
                  ),
                  Text(
                    'Record',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => TextPage()),
                      );
                    },
                    icon: Icon(Icons.article_outlined),
                    iconSize: 80.0,
                    color: Colors.purple,
                  ),
                  Text(
                    'Transcribe',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
