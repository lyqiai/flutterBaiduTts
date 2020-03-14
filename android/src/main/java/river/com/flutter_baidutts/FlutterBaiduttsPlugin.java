package river.com.flutter_baidutts;

import android.Manifest;
import android.app.Activity;
import android.content.Context;
import android.content.pm.PackageManager;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;

import com.baidu.tts.client.SpeechSynthesizer;
import com.baidu.tts.client.TtsMode;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * FlutterBaiduttsPlugin
 */
public class FlutterBaiduttsPlugin implements FlutterPlugin, MethodCallHandler, ActivityAware, PluginRegistry.RequestPermissionsResultListener, IOfflineResourceConst {
    private Context context;
    static Activity activity;

    private SpeechSynthesizer mSpeechSynthesizer;
    private String appId;
    private String appKey;
    private String appSecret;
    private TtsMode ttsMode = DEFAULT_OFFLINE_TTS_MODE;
    private OfflineResource offlineResource;
    private String TAG = "TTS";
    private int requestCode = 777;

    public FlutterBaiduttsPlugin() {
    }

    public FlutterBaiduttsPlugin(Context context) {
        this.context = context;
    }

    public FlutterBaiduttsPlugin(Context context, Activity activity) {
        this.context = context;
        this.activity = activity;
    }

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        final MethodChannel channel = new MethodChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), "flutter_baidutts");
        channel.setMethodCallHandler(new FlutterBaiduttsPlugin(flutterPluginBinding.getApplicationContext()));
    }

    public static void registerWith(Registrar registrar) {
        FlutterBaiduttsPlugin plugin = new FlutterBaiduttsPlugin(registrar.context(), registrar.activity());
        final MethodChannel channel = new MethodChannel(registrar.messenger(), "flutter_baidutts");
        registrar.addRequestPermissionsResultListener(plugin);
        channel.setMethodCallHandler(plugin);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        if (call.method.equals("init")) {
            init(call, result);
        } else if (call.method.equals("speak")) {
            speak(call, result);
        } else {
            result.notImplemented();
        }
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        mSpeechSynthesizer.release();
    }

    public void init(@NonNull MethodCall call, @NonNull Result result) {
        //获取鉴权信息
        appId = call.argument("appId");
        appKey = call.argument("appKey");
        appSecret = call.argument("appSecret");

        //初始化权限
        initPermission();

        //拷贝临时离线资源文件
        offlineResource = createOfflineResource(VOICE_MALE);

        boolean isMixOrOffline = ttsMode.equals(TtsMode.MIX);

        boolean isSuccess;

        if (isMixOrOffline) {
            // 检查2个离线资源是否可读
            isSuccess = checkOfflineResources();
            if (!isSuccess) {
                //将tts模式设置为在线模式
                ttsMode = TtsMode.ONLINE;
                isMixOrOffline = false;
            } else {
                print("离线资源存在并且可读, 目录：" + FileUtil.createTmpDir(context));
            }
        }

        // 1. 获取实例
        mSpeechSynthesizer = SpeechSynthesizer.getInstance();
        mSpeechSynthesizer.setContext(context);

        //设置回调事件
        MessageListener listener = new MessageListener();
        mSpeechSynthesizer.setSpeechSynthesizerListener(listener);

        // 2. 设置appId，appKey.secretKey
        mSpeechSynthesizer.setApiKey(appKey, appSecret);
        mSpeechSynthesizer.setAppId(appId);

        // 3. 支持离线的话，需要设置离线模型
        if (isMixOrOffline) {
            // 文本模型文件路径 (离线引擎使用)， 注意TEXT_FILENAME必须存在并且可读
            mSpeechSynthesizer.setParam(SpeechSynthesizer.PARAM_TTS_TEXT_MODEL_FILE, offlineResource.getTextFilename());
            // 声学模型文件路径 (离线引擎使用)， 注意TEXT_FILENAME必须存在并且可读
            mSpeechSynthesizer.setParam(SpeechSynthesizer.PARAM_TTS_SPEECH_MODEL_FILE, offlineResource.getModelFilename());
        }

        // 4. 以下setParam 参数选填。不填写则默认值生效
        // 设置在线发声音人： 0 普通女声（默认） 1 普通男声 2 特别男声 3 情感男声<度逍遥> 4 情感儿童声<度丫丫>
        mSpeechSynthesizer.setParam(SpeechSynthesizer.PARAM_SPEAKER, "0");
        // 设置合成的音量，0-15 ，默认 5
        mSpeechSynthesizer.setParam(SpeechSynthesizer.PARAM_VOLUME, "9");
        // 设置合成的语速，0-15 ，默认 5
        mSpeechSynthesizer.setParam(SpeechSynthesizer.PARAM_SPEED, "5");
        // 设置合成的语调，0-15 ，默认 5
        mSpeechSynthesizer.setParam(SpeechSynthesizer.PARAM_PITCH, "5");

        // 5. 初始化
        int code = mSpeechSynthesizer.initTts(ttsMode);
        print("百度语音初始化结果:" + code);

        result.success(code);
    }

    public void speak(@NonNull MethodCall call, @NonNull Result result) {
        String word = call.argument("word");
        int res = mSpeechSynthesizer.speak(word);

        result.success(res);
    }


    /**
     * 检查 TEXT_FILENAME, MODEL_FILENAME 这2个文件是否存在，不存在请自行从assets目录里手动复制
     *
     * @return 检测是否成功
     */
    private boolean checkOfflineResources() {
        if (offlineResource == null) {
            return  false;
        }
        String[] filenames = {offlineResource.getTextFilename(), offlineResource.getModelFilename()};
        for (String path : filenames) {
            File f = new File(path);
            if (!f.canRead()) {
                print("[ERROR] 文件不存在或者不可读取，请从demo的assets目录复制同名文件到："
                        + f.getAbsolutePath());
                print("[ERROR] 初始化失败！！！");
                return false;
            }
        }
        return true;
    }

    private void print(String message) {
        Log.i(TAG, message);
    }

    protected OfflineResource createOfflineResource(String voiceType) {
        OfflineResource offlineResource = null;
        try {
            offlineResource = new OfflineResource(context, voiceType);
        } catch (IOException e) {
            // IO 错误自行处理
            e.printStackTrace();
            print("【error】:copy files from assets failed." + e.getMessage());

            offlineResource = null;
        }
        return offlineResource;
    }


    private void initPermission() {
        String[] permissions = {
                Manifest.permission.INTERNET,
                Manifest.permission.ACCESS_NETWORK_STATE,
                Manifest.permission.MODIFY_AUDIO_SETTINGS,
                Manifest.permission.WRITE_SETTINGS,
                Manifest.permission.ACCESS_WIFI_STATE,
                Manifest.permission.CHANGE_WIFI_STATE,
                Manifest.permission.WRITE_EXTERNAL_STORAGE
        };

        ArrayList<String> toApplyList = new ArrayList<>();

        for (String perm : permissions) {
            if (PackageManager.PERMISSION_GRANTED != ContextCompat.checkSelfPermission(context, perm)) {
                toApplyList.add(perm);
                Log.i(TAG, "缺失权限: " + perm);
            }
        }
        String[] tmpList = new String[toApplyList.size()];
        if (!toApplyList.isEmpty()) {
            ActivityCompat.requestPermissions(activity, toApplyList.toArray(tmpList), requestCode);
        }

    }

    @Override
    public void onAttachedToActivity(ActivityPluginBinding activityPluginBinding) {
        this.activity = activityPluginBinding.getActivity();
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {

    }

    @Override
    public void onReattachedToActivityForConfigChanges(ActivityPluginBinding activityPluginBinding) {
        this.activity = activityPluginBinding.getActivity();
    }

    @Override
    public void onDetachedFromActivity() {
    }

    @Override
    public boolean onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
        //用户同意申请的权限
        if (requestCode == this.requestCode && permissions.length == grantResults.length) {
            Log.i(TAG, "onRequestPermissionsResult: 用户同意申请的权限");
        } else {
        }
        return false;
    }
}
