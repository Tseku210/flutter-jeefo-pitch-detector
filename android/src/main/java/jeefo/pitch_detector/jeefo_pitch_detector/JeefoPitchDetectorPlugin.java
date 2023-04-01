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
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;

/** JeefoPitchDetectorPlugin */
public class JeefoPitchDetectorPlugin implements FlutterPlugin, MethodCallHandler, ActivityAware, PluginRegistry.RequestPermissionsResultListener {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel channel;
  private static final String channel_name = "jeefo.pitch_detector";
  private boolean is_library_loaded = false;

  private static final int SAMPLE_RATE = 44000;
  private static final int BUFFER_SIZE = 1024;
  private long zt_data_ptr   = 0; // Pointer to the C data structure
  private long zt_ptrack_ptr = 0; // Pointer to the C data structure
  private int peak_count = 20;
  private int hop_size   = BUFFER_SIZE;
  private  double pitch = 0;

  // AudioEngine
  private Activity activity;
  private @NonNull Result result;
  private AudioRecord audioRecord;
  private short[] audioBuffer;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), channel_name);
    channel.setMethodCallHandler(this);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    switch (call.method) {
      case "activate"  : activate(result); break;
      case "deactivate": deactivate(); result.success(null); break;
      case "get_pitch" : result.success(pitch); break;
      default: result.notImplemented(); break;
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
    audioBuffer = new short[BUFFER_SIZE];

    audioRecord = new AudioRecord(MediaRecorder.AudioSource.MIC, SAMPLE_RATE, AudioFormat.CHANNEL_IN_MONO,
            AudioFormat.ENCODING_PCM_16BIT, BUFFER_SIZE * 2);

    if (audioRecord.getState() == AudioRecord.STATE_UNINITIALIZED) {
      Log.e("JeefoPitchDetector", "Failed to initialize audio recorder");
      return;
    }

    audioRecord.setPositionNotificationPeriod(BUFFER_SIZE);
    audioRecord.setRecordPositionUpdateListener(new AudioRecord.OnRecordPositionUpdateListener() {
      @Override
      public void onMarkerReached(AudioRecord recorder) {
      }

      @Override
      public void onPeriodicNotification(AudioRecord recorder) {
        audioRecord.read(audioBuffer, 0, BUFFER_SIZE);
        pitch = get_pitch(audioBuffer, 0);
      }
    });
    audioRecord.startRecording();
    result.success(null);
    result = null;
  }

  private void activate(@NonNull Result result) {
    if (!is_library_loaded) {
      System.loadLibrary("jeefo-pitch-detector");
      is_library_loaded = true;
    }
    if (zt_data_ptr == 0) {
      zt_data_ptr = zt_create();
      zt_data_set_sr(zt_data_ptr, SAMPLE_RATE);
    }
    if (zt_ptrack_ptr == 0) {
      zt_ptrack_ptr = zt_ptrack_create();
      zt_ptrack_init(zt_data_ptr, zt_ptrack_ptr, hop_size, peak_count);
    }
    if (audioRecord == null) {
      this.result = result;
      activate_audio_engine();
    }
  }

  private void deactivate() {
    if (audioRecord != null) {
      audioRecord.stop();
      audioRecord.release();
      audioRecord = null;
    }
    if (zt_data_ptr != 0) {
      zt_destroy(zt_data_ptr);
      zt_data_ptr = 0;
    }
    if (zt_ptrack_ptr != 0) {
      zt_ptrack_destroy(zt_ptrack_ptr);
      zt_ptrack_ptr = 0;
    }
  }

  private double get_pitch(short[] audioData, double amplitudeThreshold) {
    float frame[]      = new float[1];
    float fpitch[]     = new float[1];
    float famplitude[] = new float[1];

    for (int i = 0; i < audioData.length; ++i) {
      frame[0] = audioData[i] / 32768f;
      zt_ptrack_compute(zt_data_ptr, zt_ptrack_ptr, frame, fpitch, famplitude);
    }

    double pitch = fpitch[0];
    double amplitude = famplitude[0];

    return (amplitude > amplitudeThreshold && pitch > 0) ? pitch : -1;
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

  private native long zt_create();
  private native void zt_destroy(long data_ptr);
  private native long zt_ptrack_create();
  private native void zt_ptrack_destroy(long ptrack_ptr);
  private native void zt_data_set_sr(long data_ptr, int sr);
  private native void zt_ptrack_init(long data_ptr, long ptrack_ptr, int hop_size, int peak_count);
  public native void zt_ptrack_compute(long dataPtr, long ptrackPtr, float[] input, float[] outputFreq, float[] outputAmp);
}
