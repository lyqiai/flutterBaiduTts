import 'package:flutter/material.dart';
import 'package:flutter_baidutts/flutter_baidutts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  var res = await FlutterBaidutts.instance.init(
    appId: 'xxxxx',
    appKey: 'xxxxx',
    appSecret: 'xxxxx',
  );

  print('init code: $res');

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  double volume = 1.0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            children: <Widget>[
              FlatButton(
                child: Text('speek'),
                onPressed: () async {
                  final res = await FlutterBaidutts.instance.speak('你好，傻逼');
                  print("speek:$res");
                },
              ),
              Row(
                children: [
                  Text('volume'),
                  Expanded(
                    child: Slider(
                      value: volume,
                      onChanged: (value) {
                        setState(() {
                          volume = value;
                        });

                        FlutterBaidutts.instance.setVolume(volume);
                      },
                    ),
                  ),
                ],
              ),
              FlatButton(
                child: Text('pause'),
                onPressed: () async {
                  FlutterBaidutts.instance.pause();
                },
              ),
              FlatButton(
                child: Text('resume'),
                onPressed: () async {
                  FlutterBaidutts.instance.resume();
                },
              ),
              FlatButton(
                child: Text('stop'),
                onPressed: () async {
                  FlutterBaidutts.instance.stop();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
