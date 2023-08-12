import 'dart:async';
import 'dart:io' show Platform, sleep;
import 'package:englishdenemeone/word.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: "https://cxbfpwsacdvtnlvxlcif.supabase.co",
    anonKey:
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN4YmZwd3NhY2R2dG5sdnhsY2lmIiwicm9sZSI6ImFub24iLCJpYXQiOjE2NzM4NzA5NTcsImV4cCI6MTk4OTQ0Njk1N30.OZt1pY16VuDuYDBVCCqoFBe8U_G3rIghdGncAIhcLIY",
  );

  runApp(MyApp());
}

// void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

enum TtsState { playing, stopped, paused, continued }

class _MyAppState extends State<MyApp> {
  var wordList = [];

  late FlutterTts flutterTts;
  String? language;
  String? engine;
  double volume = 0.5;
  double pitch = 1.0;
  double rate = 0.5;
  bool isCurrentLanguageInstalled = false;

  //String? _newVoiceText;
  int? _inputLength;
  String turkishText = "";
  String englishText = "";
  String turkishTextSentece = "";
  String englishTextSentece = "";
  TtsState ttsState = TtsState.stopped;

  get isPlaying => ttsState == TtsState.playing;
  get isStopped => ttsState == TtsState.stopped;
  get isPaused => ttsState == TtsState.paused;
  get isContinued => ttsState == TtsState.continued;

  bool get isIOS => !kIsWeb && Platform.isIOS;
  bool get isAndroid => !kIsWeb && Platform.isAndroid;
  bool get isWindows => !kIsWeb && Platform.isWindows;
  bool get isWeb => kIsWeb;

  @override
  initState() {
    super.initState();
    initTts();
  }

  initTts() {
    flutterTts = FlutterTts();
    Supabase.instance.client.from('word').select().then((value) => wordList.add(value));

    //  final _future2s = Supabase.instance.client
    // .from('countries')
    // .select<List<Map<String, dynamic>>>();

    Supabase.instance.client.from('word').select().then((value) => print(value));

    _setAwaitOptions();

    if (isAndroid) {
      _getDefaultEngine();
      _getDefaultVoice();
    }

    flutterTts.setStartHandler(() {
      setState(() {
        print("Playing");
        ttsState = TtsState.playing;
      });
    });

    if (isAndroid) {
      flutterTts.setInitHandler(() {
        setState(() {
          print("TTS Initialized");
        });
      });
    }

    flutterTts.setCompletionHandler(() {
      setState(() {
        print("Complete");
        ttsState = TtsState.stopped;
      });
    });

    flutterTts.setCancelHandler(() {
      setState(() {
        print("Cancel");
        ttsState = TtsState.stopped;
      });
    });

    flutterTts.setPauseHandler(() {
      setState(() {
        print("Paused");
        ttsState = TtsState.paused;
      });
    });

    flutterTts.setContinueHandler(() {
      setState(() {
        print("Continued");
        ttsState = TtsState.continued;
      });
    });

    flutterTts.setErrorHandler((msg) {
      setState(() {
        print("error: $msg");
        ttsState = TtsState.stopped;
      });
    });
  }

  Future<dynamic> _getLanguages() async => await flutterTts.getLanguages;

  Future<dynamic> _getEngines() async => await flutterTts.getEngines;

  Future _getDefaultEngine() async {
    var engine = await flutterTts.getDefaultEngine;
    if (engine != null) {
      print(engine);
    }
  }

  Future _getDefaultVoice() async {
    var voice = await flutterTts.getDefaultVoice;
    if (voice != null) {
      print(voice);
    }
  }

  Future _speak() async {
    await flutterTts.setVolume(volume);
    await flutterTts.setSpeechRate(rate);
    await flutterTts.setPitch(pitch);

// Supabase.instance.client.auth.signInWithPassword(password: "password")
    // final data = await Supabase.instance.client.from('Word').select('turkish');

    // List<Word>? wordList;
    // wordList = <Word>[];

    // var word = Word();
    // word.English = 'Hello';
    // word.Turkish = 'Merhaba';
    // word.TurkisSentence = 'Merhaba Canım';
    // word.EnglishSentence = 'Hello Dear';
    // wordList.add(word);

    // var word1 = Word();
    // word1.English = 'Home';
    // word1.Turkish = 'Ev';
    // word1.TurkisSentence = 'Eve vardım';
    // word1.EnglishSentence = 'I arrived home';
    // wordList.add(word1);

    // var word2 = Word();
    // word2.English = 'Sea';
    // word2.Turkish = 'Deniz';
    // word2.TurkisSentence = 'Denizde yüzmeyi severim';
    // word2.EnglishSentence = 'I like swimming in the sea';
    // wordList.add(word2);

    //var adasd = dasds;

    for (var wordMap in wordList[0]) {
      var word = Word.fromJson(wordMap);
      changedLanguageDropDownItem('tr-TR');
      setState(() {
        turkishText = word.turkish!;
        englishText = word.english!;
        turkishTextSentece = word.turkish_sentence!;
        englishTextSentece = word.english_sentence!;
      });

      sleep(const Duration(seconds: 1));
      changedLanguageDropDownItem('en-US');
      if (word.english != null) {
        if (word.english!.isNotEmpty) {
          await flutterTts.speak(word.english!);
        }
      }
      sleep(const Duration(seconds: 1));
      changedLanguageDropDownItem('tr-TR');
      if (word.turkish != null) {
        if (word.turkish!.isNotEmpty) {
          await flutterTts.speak(word.turkish!);
        }
      }
      sleep(const Duration(seconds: 1));
      changedLanguageDropDownItem('en-US');
      if (word.english_sentence != null) {
        if (word.english_sentence!.isNotEmpty) {
          await flutterTts.speak(word.english_sentence!);
        }
      }
      sleep(const Duration(seconds: 1));
      changedLanguageDropDownItem('tr-TR');
      if (word.turkish_sentence != null) {
        if (word.turkish_sentence!.isNotEmpty) {
          await flutterTts.speak(word.turkish_sentence!);
        }
      }

      sleep(const Duration(seconds: 3));
    }

    // if (_newVoiceText != null) {
    //   if (_newVoiceText!.isNotEmpty) {
    //     await flutterTts.speak(_newVoiceText!);
    //   }
    // }
  }

  Future _setAwaitOptions() async {
    await flutterTts.awaitSpeakCompletion(true);
  }

  Future _stop() async {
    var result = await flutterTts.stop();
    if (result == 1) setState(() => ttsState = TtsState.stopped);
  }

  Future _pause() async {
    var result = await flutterTts.pause();
    if (result == 1) setState(() => ttsState = TtsState.paused);
  }

  @override
  void dispose() {
    super.dispose();
    flutterTts.stop();
  }

  List<DropdownMenuItem<String>> getEnginesDropDownMenuItems(dynamic engines) {
    var items = <DropdownMenuItem<String>>[];
    for (dynamic type in engines) {
      items.add(DropdownMenuItem(value: type as String?, child: Text(type as String)));
    }
    return items;
  }

  void changedEnginesDropDownItem(String? selectedEngine) async {
    await flutterTts.setEngine(selectedEngine!);
    language = null;
    setState(() {
      engine = selectedEngine;
    });
  }

  List<DropdownMenuItem<String>> getLanguageDropDownMenuItems(dynamic languages) {
    var items = <DropdownMenuItem<String>>[];
    for (dynamic type in languages) {
      items.add(DropdownMenuItem(value: type as String?, child: Text(type as String)));
    }
    return items;
  }

  void changedLanguageDropDownItem(String? selectedType) {
    setState(() {
      language = selectedType;
      flutterTts.setLanguage(language!);
      if (isAndroid) {
        flutterTts.isLanguageInstalled(language!).then((value) => isCurrentLanguageInstalled = (value as bool));
      }
    });
  }

  // void _onChange(String text) {
  //   setState(() {
  //    // _newVoiceText = text;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          // title: const Text('Türkilish'),
        ),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              // _inputSection(),

              _inputSectionEnglish(),
              // SelectableText.rich(

              //   TextSpan(
              //     text: 'Hello', // default text style
              //     children: <TextSpan>[
              //       TextSpan(text: ' beautiful ', style: TextStyle(fontStyle: FontStyle.italic)),
              //       TextSpan(text: 'world', style: TextStyle(fontWeight: FontWeight.bold)),
              //     ],
              //   ),
              // ),

              // Center(
              //   child: SelectableText(
              //     "Flutter Tutorial by Flutter Dev's.com",
              //     style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 45),
              //     textAlign: TextAlign.center,
              //     onTap: () => print(''),
              //     // ignore: prefer_const_constructors
              //     toolbarOptions: ToolbarOptions(
              //       copy: true,
              //       selectAll: true,
              //     ),
              //     showCursor: true,
              //     cursorWidth: 2,
              //     cursorColor: Colors.red,
              //     cursorRadius: Radius.circular(5),
              //   ),
              // ),
              _inputSectionTurkish(),
              _inputSectionEnglishSentence(),
              _inputSectionTurkishSentence(),
              _btnSection(),
              _engineSection(),
              _futureBuilder(),
              _buildSliders(),
              if (isAndroid) _getMaxSpeechInputLengthSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _engineSection() {
    if (isAndroid) {
      return FutureBuilder<dynamic>(
          future: _getEngines(),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.hasData) {
              return _enginesDropDownSection(snapshot.data);
            } else if (snapshot.hasError) {
              return Text('Error loading engines...');
            } else
              return Text('Loading engines...');
          });
    } else
      return Container(width: 0, height: 0);
  }

  Widget _futureBuilder() => FutureBuilder<dynamic>(
      future: _getLanguages(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData) {
          return _languageDropDownSection(snapshot.data);
        } else if (snapshot.hasError) {
          return Text('Error loading languages...');
        } else
          return Text('Loading Languages...');
      });

  // Widget _inputSection() => Container(
  //     alignment: Alignment.topCenter,
  //     padding: EdgeInsets.only(top: 25.0, left: 25.0, right: 25.0),
  //     child: TextField(
  //       maxLines: 11,
  //       minLines: 6,
  //       onChanged: (String value) {
  //         _onChange(value);
  //       },
  //     ));

  Widget _inputSectionTurkish() => Container(
      alignment: Alignment.topLeft,
      padding: EdgeInsets.only(top: 25.0, left: 25.0, right: 25.0),
      child: RichText(
        text: TextSpan(
            style: TextStyle(
              color: Colors.red,
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
            children: [TextSpan(text: turkishText)]),
      ));

  Widget _inputSectionEnglish() => Container(
      alignment: Alignment.topLeft,
      padding: EdgeInsets.only(top: 25.0, left: 25.0, right: 25.0),
      child: RichText(
        text: TextSpan(style: TextStyle(color: Colors.black, fontSize: 20.0, fontWeight: FontWeight.bold), children: [TextSpan(text: englishText)]),
      ));

  Widget _inputSectionTurkishSentence() => Container(
      alignment: Alignment.topLeft,
      padding: EdgeInsets.only(top: 25.0, left: 25.0, right: 25.0),
      child: RichText(
        text: TextSpan(
            style: TextStyle(color: Colors.red, fontSize: 20.0, fontWeight: FontWeight.bold), children: [TextSpan(text: turkishTextSentece)]),
      ));

  Widget _inputSectionEnglishSentence() => Container(
      alignment: Alignment.topLeft,
      padding: EdgeInsets.only(top: 25.0, left: 25.0, right: 25.0),
      child:
          //  SelectableText(
          //   englishTextSentece,
          //   style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 45),
          //   textAlign: TextAlign.center,
          //   onTap: () => print(''),
          //   // ignore: prefer_const_constructors
          //   toolbarOptions: ToolbarOptions(
          //     copy: true,
          //     selectAll: true,
          //   ),
          //   showCursor: true,
          //   cursorWidth: 2,
          //   cursorColor: Colors.red,
          //   cursorRadius: Radius.circular(5),
          // )
          RichText(
        text: TextSpan(
            style: TextStyle(color: Colors.black, fontSize: 20.0, fontWeight: FontWeight.bold), children: [TextSpan(text: englishTextSentece)]),
      ));

  Widget _btnSection() {
    return Container(
      padding: EdgeInsets.only(top: 50.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildButtonColumn(Colors.green, Colors.greenAccent, Icons.play_arrow, 'PLAY', _speak),
          _buildButtonColumn(Colors.red, Colors.redAccent, Icons.stop, 'STOP', _stop),
          _buildButtonColumn(Colors.blue, Colors.blueAccent, Icons.pause, 'PAUSE', _pause),
        ],
      ),
    );
  }

  Widget _enginesDropDownSection(dynamic engines) => Container(
        padding: EdgeInsets.only(top: 50.0),
        child: DropdownButton(
          value: engine,
          items: getEnginesDropDownMenuItems(engines),
          onChanged: changedEnginesDropDownItem,
        ),
      );

  Widget _languageDropDownSection(dynamic languages) => Container(
      padding: EdgeInsets.only(top: 10.0),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        DropdownButton(
          value: language,
          items: getLanguageDropDownMenuItems(languages),
          onChanged: changedLanguageDropDownItem,
        ),
        Visibility(
          visible: isAndroid,
          child: Text("Is installed: $isCurrentLanguageInstalled"),
        ),
      ]));

  Column _buildButtonColumn(Color color, Color splashColor, IconData icon, String label, Function func) {
    return Column(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: [
      IconButton(icon: Icon(icon), color: color, splashColor: splashColor, onPressed: () => func()),
      Container(
          margin: const EdgeInsets.only(top: 8.0), child: Text(label, style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.w400, color: color)))
    ]);
  }

  Widget _getMaxSpeechInputLengthSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          child: Text('Get max speech input length'),
          onPressed: () async {
            _inputLength = await flutterTts.getMaxSpeechInputLength;
            setState(() {});
          },
        ),
        Text("$_inputLength characters"),
      ],
    );
  }

  Widget _buildSliders() {
    return Column(
      children: [_volume(), _pitch(), _rate()],
    );
  }

  Widget _volume() {
    return Slider(
        value: volume,
        onChanged: (newVolume) {
          setState(() => volume = newVolume);
        },
        min: 0.0,
        max: 1.0,
        divisions: 10,
        label: "Volume: $volume");
  }

  Widget _pitch() {
    return Slider(
      value: pitch,
      onChanged: (newPitch) {
        setState(() => pitch = newPitch);
      },
      min: 0.5,
      max: 2.0,
      divisions: 15,
      label: "Pitch: $pitch",
      activeColor: Colors.red,
    );
  }

  Widget _rate() {
    return Slider(
      value: rate,
      onChanged: (newRate) {
        setState(() => rate = newRate);
      },
      min: 0.0,
      max: 1.0,
      divisions: 10,
      label: "Rate: $rate",
      activeColor: Colors.green,
    );
  }
}
