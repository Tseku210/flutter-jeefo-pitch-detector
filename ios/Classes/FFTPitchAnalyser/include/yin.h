#ifndef __YIN_H__
#define __YIN_H__

#include <stdint.h>

#define YIN_DEFAULT_THRESHOLD 0.15f

#ifndef PTR
  #define PTR(name) name[static 1]
#endif

/**
 * breif	Object to encapsulate the parameters
 */
typedef struct {
  uint16_t num_samples;
  uint16_t half_num_samples;
  float*   buffer;
  float*   auto_correlation_buffer;
  int      correlation_index;
  float    probability;
  float    threshold;
  float    sampling_frequency;
} Yin;

/**
* Initialise the Yin pitch detection object
* @param threshold   Allowed uncertainty
*                    (e.g 0.05 will return a pitch with ~95% probability)
*/
void yin_init(
  Yin*   yin,
  uint16_t num_samples,
  float    sampling_frequency,
  float    threshold
);
void destroy_yin(Yin PTR(yin));
float yin_get_pitch(Yin PTR(yin), int16_t PTR(buffer));

#endif