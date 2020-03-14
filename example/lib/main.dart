import 'package:flutter/material.dart';
import 'package:flutter_baidutts/flutter_baidutts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  var res = await FlutterBaidutts.instance.init(
    appId: '18808984',
    appKey: 'MRt4YINZiHV60GtPM1lohgCC',
    appSecret: 'Hdhum6GovTHXSEKShwl7rVemuYqLYO8w',
  );

  print('init code: $res');

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
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
                  var flag = await FlutterBaidutts.instance.speak('你好，我是刘艳琦，英文名字是river');
                  print(flag);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
