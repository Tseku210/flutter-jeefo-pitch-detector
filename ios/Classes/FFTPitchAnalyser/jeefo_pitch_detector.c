#include "FFTPitchAnalyser.h"
#include <assert.h>
#include <stdio.h>

zt_data*   zt_data_ptr   = NULL;
zt_ptrack* zt_ptrack_ptr = NULL;

void jpd_init(int hop_size, int peak_count) {
  assert(zt_data_ptr == NULL && zt_ptrack_ptr == NULL);
  zt_create(&zt_data_ptr);
  zt_ptrack_create(&zt_ptrack_ptr);
  zt_ptrack_init(zt_data_ptr, zt_ptrack_ptr, hop_size, peak_count);
}

void jpd_destroy(void) {
  if (zt_data_ptr == NULL && zt_ptrack_ptr == NULL) return;
  zt_destroy(&zt_data_ptr);
  zt_ptrack_destroy(&zt_ptrack_ptr);
  zt_data_ptr   = NULL;
  zt_ptrack_ptr = NULL;
}

void jpd_set_sample_rate(int sample_rate) {
  assert(zt_data_ptr != NULL);
  zt_data_ptr->sr = sample_rate;
}

void jpd_get_values(float* frames, size_t length, float* values) {
  float pitch              = 0;
  float amplitude          = 0;
  float amplitudeThreshold = values[2];

  for (size_t i = 0; i < length; ++i) {
    zt_ptrack_compute(zt_data_ptr, zt_ptrack_ptr, &frames[i], &pitch, &amplitude);
  }

  values[0] = (amplitude > amplitudeThreshold && pitch > 0) ? pitch : -1;
  values[1] = amplitude;
}

void jpd_get_values_from_i16(int16_t* data, size_t length, float* values) {
  float frames[length];

  for (size_t i = 0; i < length; ++i) {
    frames[i] = (float)data[i] / 32768.0f;
  }
  jpd_get_values(frames, length, values);
}