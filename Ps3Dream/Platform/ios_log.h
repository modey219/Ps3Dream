// Ps3Dream iOS - Logging (replaces __android_log)
// Uses Apple's os_log system

#pragma once

#include <os/log.h>
#include <stdio.h>

#ifdef __cplusplus
extern "C" {
#endif

static os_log_t s_ps3_log = OS_LOG_DEFAULT;

#define LOGI(fmt, ...) os_log_info(s_ps3_log, "PS3DREAM: " fmt, ##__VA_ARGS__)
#define LOGW(fmt, ...) os_log_error(s_ps3_log, "PS3DREAM [WARN]: " fmt, ##__VA_ARGS__)
#define LOGE(fmt, ...) os_log_error(s_ps3_log, "PS3DREAM [ERROR]: " fmt, ##__VA_ARGS__)

#ifdef __cplusplus
}
#endif
