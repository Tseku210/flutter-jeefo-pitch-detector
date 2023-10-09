package jeefo.pitch_detector.jeefo_pitch_detector;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;

import android.Manifest;
import android.app.Activity;
import android.content.pm.PackageManager;
import android.media.AudioFormat;
import android.media.AudioRecord;
import android.media.MediaRecorder;
import android.os.Build;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.RequiresApi;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;

import java.util.Arrays;
import java.util.List;

/** JeefoPitchDetectorPlugin */
public class JeefoPitchDetectorPlugin implements FlutterPlugin, MethodCallHandler, ActivityAware, PluginRegistry.RequestPermissionsResultListener {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel channel;
  private static final String channel_name = "jeefo.pitch_detector";
  private boolean is_library_loaded = false;

  private static final int SAMPLING_FREQUENCY = 44100;
  private static final int NUM_SAMPLES = 1024;
  private double pitch      = 0;
  private double confidence = 0;
  private boolean is_activated = false;

  // AudioEngine
  private Activity activity;
  private AudioRecord audioRecord;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), channel_name);
    channel.setMethodCallHandler(this);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    switch (call.method) {
      case "activate":
        double threshold = call.argument("threshold");
        activate(threshold);
        result.success(null);
        break;
      case "deactivate":
        deactivate();
        result.success(null);
        break;
      case "get_values":
        List<Double> values = Arrays.asList(pitch, confidence);
        result.success(values);
        break;
      case "set_confidence_threshold":
        double th = call.argument("threshold");
        jpd_set_confidence_threshold((float) th);
        result.success(null);
        break;
      default:
        result.notImplemented();
        break;
    }
  }


  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }

  private void activate_audio_engine() {
    if (ContextCompat.checkSelfPermission(activity, Manifest.permission.RECORD_AUDIO) != PackageManager.PERMISSION_GRANTED) {
      ActivityCompat.requestPermissions(activity, new String[]{Manifest.permission.RECORD_AUDIO}, 1);
      return;
    }

    audioRecord = new AudioRecord(MediaRecorder.AudioSource.MIC, SAMPLING_FREQUENCY, AudioFormat.CHANNEL_IN_MONO,
            AudioFormat.ENCODING_PCM_16BIT, NUM_SAMPLES * 2);

    if (audioRecord.getState() == AudioRecord.STATE_UNINITIALIZED) {
      Log.e("JeefoPitchDetector", "Failed to initialize audio recorder");
      return;
    }

    audioRecord.setPositionNotificationPeriod(NUM_SAMPLES);
    audioRecord.setRecordPositionUpdateListener(new AudioRecord.OnRecordPositionUpdateListener() {
      @Override
      public void onMarkerReached(AudioRecord recorder) {
      }

      @RequiresApi(api = Build.VERSION_CODES.M)
      @Override
      public void onPeriodicNotification(AudioRecord recorder) {
        if (!is_activated) return;
        short[] audioBuffer = new short[NUM_SAMPLES];
        int bytes_read = audioRecord.read(audioBuffer, 0, NUM_SAMPLES);
        if (bytes_read != AudioRecord.ERROR_INVALID_OPERATION && bytes_read != AudioRecord.ERROR_BAD_VALUE) {
          float[] values = new float[10];
          jpd_get_values_from_i16(audioBuffer, values);
          pitch      = values[0];
          confidence = values[1];
        }
      }
    });
    audioRecord.startRecording();
  }

  private void activate(double threshold) {
    if (!is_library_loaded) {
      System.loadLibrary("jeefo-pitch-detector");
      is_library_loaded = true;
    }
    jpd_init(NUM_SAMPLES, SAMPLING_FREQUENCY, (float)threshold);
    if (audioRecord == null) {
      activate_audio_engine();
    }
    is_activated = true;
  }

  private void deactivate() {
    if (audioRecord != null) {
      audioRecord.stop();
      audioRecord.release();
      audioRecord = null;
    }
    jpd_destroy();
    is_activated = false;
  }

  @Override
  public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
    activity = binding.getActivity();
    binding.addRequestPermissionsResultListener(this);
  }

  @Override
  public void onDetachedFromActivity() {
    activity = null;
  }

  @Override
  public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
    activity = binding.getActivity();
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {
    activity = null;
  }

  @Override
  public boolean onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
    if (requestCode == 1 && grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
      activate_audio_engine(); // Re-run the audio engine code
      return true;
    }
    return false;
  }

  private native void jpd_init(int num_samples, int sampling_frequency, float threshold);
  private native void jpd_destroy();
  private native void jpd_get_values_from_i16(short[] buffer, float[] out);
  private native void jpd_set_confidence_threshold(float threshold);
}
