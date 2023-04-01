#include <jni.h>
#include "FFTPitchAnalyser.h"

#define UNUSED(x) (void)x

JNIEXPORT jlong JNICALL
Java_jeefo_pitch_1detector_jeefo_1pitch_1detector_JeefoPitchDetectorPlugin_zt_1create(JNIEnv* e, jobject o) {
    UNUSED(e); UNUSED(o);
    zt_data *data;
    zt_create(&data);
    return (jlong) data;
}

JNIEXPORT void JNICALL
Java_jeefo_pitch_1detector_jeefo_1pitch_1detector_JeefoPitchDetectorPlugin_zt_1destroy(JNIEnv* e, jobject o, jlong data_ptr) {
    UNUSED(e); UNUSED(o);
    zt_data **spp = (zt_data **) data_ptr;
    zt_destroy(spp);
}

JNIEXPORT jlong JNICALL
Java_jeefo_pitch_1detector_jeefo_1pitch_1detector_JeefoPitchDetectorPlugin_zt_1ptrack_1create(JNIEnv* e, jobject o) {
    UNUSED(e); UNUSED(o);
    zt_ptrack *ptrack;
    zt_ptrack_create(&ptrack);
    return (jlong) ptrack;
}

JNIEXPORT void JNICALL
Java_jeefo_pitch_1detector_jeefo_1pitch_1detector_JeefoPitchDetectorPlugin_zt_1data_1set_1sr(JNIEnv* e, jobject o, jlong data_ptr, jint sr) {
    UNUSED(e); UNUSED(o);
    zt_data *data = (zt_data *) data_ptr;
    data->sr = sr;
}

JNIEXPORT void JNICALL
Java_jeefo_pitch_1detector_jeefo_1pitch_1detector_JeefoPitchDetectorPlugin_zt_1ptrack_1init(JNIEnv* e, jobject o, jlong data_ptr, jlong ptrack_ptr, jint hop_size, jint peak_count) {
    UNUSED(e); UNUSED(o);
    zt_data *data = (zt_data *) data_ptr;
    zt_ptrack *ptrack = (zt_ptrack *) ptrack_ptr;
    zt_ptrack_init(data, ptrack, hop_size, peak_count);
}

JNIEXPORT void JNICALL
Java_jeefo_pitch_1detector_jeefo_1pitch_1detector_JeefoPitchDetectorPlugin_zt_1ptrack_1destroy(JNIEnv* e, jobject o, jlong ptrack_ptr) {
    UNUSED(e); UNUSED(o);
    zt_ptrack **p = (zt_ptrack **) ptrack_ptr;
    zt_ptrack_destroy(p);
}

JNIEXPORT void JNICALL
Java_jeefo_pitch_1detector_jeefo_1pitch_1detector_JeefoPitchDetectorPlugin_zt_1ptrack_1compute(JNIEnv* env, jobject o, jlong data_ptr, jlong ptrack_ptr, jfloatArray in, jfloatArray out_freq, jfloatArray out_amp) {
    UNUSED(env); UNUSED(o);
    zt_data *data = (zt_data *) data_ptr;
    zt_ptrack *ptrack = (zt_ptrack *) ptrack_ptr;
    jfloat *in_data = (*env)->GetFloatArrayElements(env, in, NULL);
    jfloat *out_freq_data = (*env)->GetFloatArrayElements(env, out_freq, NULL);
    jfloat *out_amp_data = (*env)->GetFloatArrayElements(env, out_amp, NULL);
    zt_ptrack_compute(data, ptrack, in_data, out_freq_data, out_amp_data);
    (*env)->ReleaseFloatArrayElements(env, in, in_data, 0);
    (*env)->ReleaseFloatArrayElements(env, out_freq, out_freq_data, 0);
    (*env)->ReleaseFloatArrayElements(env, out_amp, out_amp_data, 0);
}