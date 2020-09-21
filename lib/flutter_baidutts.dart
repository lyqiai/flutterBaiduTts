import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FlutterBaidutts {
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

  //合成语音
  Future<int> speak(String word) async {
    return _channel.invokeMethod<int>('speak', {
      'word': word,
    });
  }

  //设置音量
  Future<int> setVolume(double volume) async {
    assert(volume >= 0.0 && volume <= 1.0);
    
    return _channel.invokeMethod('setVolume', {
      'volume': volume,
    });
  }

  //暂停播放
  Future<int> pause() async {
    return _channel.invokeMethod('pause');
  }


  //恢复播放
  Future<int> resume() async {
    return _channel.invokeMethod('resume');
  }

  //停止合成并停止播放
  Future<int> stop() {
    return _channel.invokeMethod('stop');
  }
}
