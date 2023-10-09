#ifndef __JEEFO_PITCH_DETECTOR__
#define __JEEFO_PITCH_DETECTOR__

#include <stddef.h>
#include <stdint.h>

void jpd_init(
  size_t num_samples,
  float  sampling_frequency,
  float  threshold
);
void jpd_destroy(void);
void jpd_set_confidence_threshold(float threshold);
void jpd_get_values(const float* buffer, float* out);
void jpd_get_values_from_i16(int16_t* buffer, float* out);

#endif