// Ps3Dream iOS - Native Window Abstraction
// Bridges ANativeWindow API to CAMetalLayer on iOS

#pragma once

#if defined(__OBJC__)
#import <QuartzCore/CAMetalLayer.h>
#import <UIKit/UIKit.h>
#else
@class CAMetalLayer;
#endif

#ifdef __cplusplus
extern "C" {
#endif

typedef struct Ps3DreamWindow {
#if defined(__OBJC__)
    CAMetalLayer* metal_layer;
#else
    void* metal_layer;
#endif
    int width;
    int height;
    int is_valid;
} Ps3DreamWindow;

extern Ps3DreamWindow* g_ios_window;
extern int g_ios_window_width;
extern int g_ios_window_height;

void ios_window_resize(int width, int height);
void ios_window_set_layer(void* layer);
void ios_window_release(void);

#define ANativeWindow Ps3DreamWindow
#define ANativeWindow_getWidth(w) ((w)->width)
#define ANativeWindow_getHeight(w) ((w)->height)

#ifdef __cplusplus
}
#endif
