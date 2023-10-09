#include <jni.h>
#include <assert.h>
#include "jeefo_pitch_detector.h"

#define UNUSED(x) (void)x

// init function implementation
JNIEXPORT void JNICALL
Java_jeefo_pitch_1detector_jeefo_1pitch_1detector_JeefoPitchDetectorPlugin_jpd_1init(JNIEnv *env, jobject obj, jint num_samples, jint sampling_frequency, jfloat threshold) {
  UNUSED(env); UNUSED(obj);
  jpd_init(num_samples, sampling_frequency, threshold);
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
  jfloat* out    = (*env)->GetFloatArrayElements(env, jValues, NULL);
  jshort* buffer = (*env)->GetShortArrayElements(env, audioData, NULL);
  assert(out != NULL && buffer != NULL);

  jpd_get_values_from_i16(buffer, out);

  // Release java data
  (*env)->ReleaseShortArrayElements(env, audioData, buffer, 0);
  (*env)->ReleaseFloatArrayElements(env, jValues, out, 0);
}

// get_pitch function implementation
JNIEXPORT void JNICALL
Java_jeefo_pitch_1detector_jeefo_1pitch_1detector_JeefoPitchDetectorPlugin_jpd_1set_1confidence_1threshold(JNIEnv *env, jobject obj, jfloat threshold) {
  UNUSED(env); UNUSED(obj);
  jpd_set_confidence_threshold(threshold);
}