# flutter_baidutts

A new Flutter plugin for baidu tts

## Getting Started

### Config On Android
	-keep class com.baidu.tts.**{*;}
	-keep class com.baidu.speechsynthesizer.**{*;}

Add the obfuscated configuration to your file

### Config On IOS
	Just copy libBaiduSpeechSDK.a into your ios project

1.init config before use plugin


	FlutterBaidutts.instance.init(
		appId:'appId',
		appKey:'appKey',
		appSecret:'appSecret',
	);
	

2.just call speek function whatever you want to speek


	FlutterBaidutts.instance.speek('speekWords');
	
	
##	Future
1. Mode Of Mix On Android