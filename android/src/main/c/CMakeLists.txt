cmake_minimum_required(VERSION 3.2.1)

project(hello_world)

add_library(jeefo-pitch-detector
            SHARED
            jni_wrapper.c
            ../../../../ios/Classes/FFTPitchAnalyser/fft.c
            ../../../../ios/Classes/FFTPitchAnalyser/base.c
            ../../../../ios/Classes/FFTPitchAnalyser/ptrack.c
            ../../../../ios/Classes/FFTPitchAnalyser/jeefo_pitch_detector.c)

include_directories(../../../../ios/Classes/FFTPitchAnalyser/include)

target_link_libraries(jeefo-pitch-detector m)

target_compile_options(jeefo-pitch-detector PRIVATE -O3)