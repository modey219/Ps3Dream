#pragma once
// Stub android/native_window_jni.h for iOS

#include <stdint.h>

struct ANativeWindow {
    void* _native_window;
    int width;
    int height;
};

typedef struct ANativeWindow ANativeWindow;

static inline ANativeWindow* ANativeWindow_fromSurface(void* env, void* surface) {
    (void)env; (void)surface;
    return nullptr;
}

static inline void ANativeWindow_acquire(ANativeWindow* window) { (void)window; }
static inline void ANativeWindow_release(ANativeWindow* window) { (void)window; }
static inline int ANativeWindow_getWidth(ANativeWindow* window) { return window ? window->width : 0; }
static inline int ANativeWindow_getHeight(ANativeWindow* window) { return window ? window->height : 0; }
