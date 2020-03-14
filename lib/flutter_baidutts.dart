import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class FlutterBaidutts {
  static const MethodChannel _channel = const MethodChannel('flutter_baidutts');
  String appId;
  String appKey;
  String appSecret;

  Future<int> init({
    @required String appId,
    @required String appKey,
    @required String appSecret,
  }) {
    return _channel.invokeMethod<int>('init', {
      'appId': appId,
      'appKey': appKey,
      'appSecret': appSecret,
    });
  }

  Future<int> speak(String word) async {
    return _channel.invokeMethod<int>('speak', {
      'word': word,
    });
  }

  factory FlutterBaidutts() => _getInstance();

  static FlutterBaidutts get instance => _getInstance();

  static FlutterBaidutts _instance;

  FlutterBaidutts._internal() {}

  static FlutterBaidutts _getInstance() {
    if (_instance == null) {
      _instance = new FlutterBaidutts._internal();
    }

    return _instance;
  }
}
