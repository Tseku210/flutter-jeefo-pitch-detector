#include <jni.h>
#include <assert.h>
#include "FFTPitchAnalyser.h"

#define UNUSED(x) (void)x

// init function implementation
JNIEXPORT void JNICALL
Java_jeefo_pitch_1detector_jeefo_1pitch_1detector_JeefoPitchDetectorPlugin_jpd_1init(JNIEnv *env, jobject obj, jint hop_size, jint peak_count) {
  UNUSED(env); UNUSED(obj);
  jpd_init(hop_size, peak_count);
}

// destroy function implementation
JNIEXPORT void JNICALL
Java_jeefo_pitch_1detector_jeefo_1pitch_1detector_JeefoPitchDetectorPlugin_jpd_1destroy(JNIEnv *env, jobject obj) {
  UNUSED(env); UNUSED(obj);
  jpd_destroy();
}

// get_pitch function implementation
JNIEXPORT void JNICALL
Java_jeefo_pitch_1detector_jeefo_1pitch_1detector_JeefoPitchDetectorPlugin_jpd_1get_1values_1from_1i16(JNIEnv *env, jobject obj, jshortArray audioData, jfloatArray jValues) {
  UNUSED(obj);
  jfloat* values = (*env)->GetFloatArrayElements(env, jValues, NULL);
  jsize length = (*env)->GetArrayLength(env, audioData);
  jshort *audioBuffer = (*env)->GetShortArrayElements(env, audioData, NULL);
  assert(values != NULL && audioBuffer != NULL);

  jpd_get_values_from_i16(audioBuffer, length, values);

  // Release java data
  (*env)->ReleaseShortArrayElements(env, audioData, audioBuffer, 0);
  (*env)->ReleaseFloatArrayElements(env, jValues, values, 0);
}

// set_sample_rate function implementation
JNIEXPORT void JNICALL
Java_jeefo_pitch_1detector_jeefo_1pitch_1detector_JeefoPitchDetectorPlugin_jpd_1set_1sample_1rate(JNIEnv* e, jobject o, jint sr) {
  UNUSED(e); UNUSED(o);
  jpd_set_sample_rate(sr);
}