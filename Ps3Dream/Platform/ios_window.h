// Ps3Dream iOS - Native Window Abstraction
// Bridges ANativeWindow API to CAMetalLayer on iOS

#pragma once

#import <QuartzCore/CAMetalLayer.h>
#import <UIKit/UIKit.h>

#ifdef __cplusplus
extern "C" {
#endif

// Minimal ANativeWindow-compatible interface for iOS
typedef struct Ps3DreamWindow {
    CAMetalLayer* metal_layer;
    int width;
    int height;
    int is_valid;
} Ps3DreamWindow;

// Global window state (replaces ae::window)
extern Ps3DreamWindow* g_ios_window;
extern int g_ios_window_width;
extern int g_ios_window_height;

// Called by Swift/ObjC when view resizes
void ios_window_resize(int width, int height);
void ios_window_set_layer(CAMetalLayer* layer);
void ios_window_release(void);

// Compatibility macros
#define ANativeWindow Ps3DreamWindow
#define ANativeWindow_getWidth(w) ((w)->width)
#define ANativeWindow_getHeight(w) ((w)->height)

#ifdef __cplusplus
}
#endif
