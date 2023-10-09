#include <assert.h>
#include <stdio.h>
#include <stdbool.h>
#include "include/jeefo_pitch_detector.h"
#include "include/yin.h"

static Yin yin;
static bool is_initialized = false;

static inline void write_output(float pitch, float* out) {
  out[0] = pitch;
  out[1] = yin.probability;
  out[2] = 0;
  out[3] = yin.num_samples;
  out[4] = yin.sampling_frequency;
  out[5] = yin.threshold;
}

void jpd_init(
  size_t num_samples,
  float sampling_frequency,
  float threshold
) {
  assert(!is_initialized);
  yin_init(&yin, num_samples, sampling_frequency, 1.0f - threshold);
  is_initialized = true;
}

void jpd_destroy(void) {
  is_initialized = false;
  destroy_yin(&yin);
}

void jpd_set_confidence_threshold(float threshold) {
  yin.threshold = 1.0f - threshold;
}

void jpd_get_values(const float* buffer, float* out) {
  int16_t short_buffer[yin.num_samples];
  for (int i = 0; i < yin.num_samples; ++i) {
    short_buffer[i]  = (short)(buffer[i] * 32767);
  }
  float pitch = yin_get_pitch(&yin, short_buffer);
  write_output(pitch, out);
}

void jpd_get_values_from_i16(int16_t* buffer, float* out) {
  float pitch = yin_get_pitch(&yin, buffer);
  write_output(pitch, out);
}