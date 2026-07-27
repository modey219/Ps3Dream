// Ps3Dream iOS - Native Window Implementation

#include "ios_window.h"
#include <stdlib.h>

Ps3DreamWindow* g_ios_window = nullptr;
int g_ios_window_width = 1280;
int g_ios_window_height = 720;

void ios_window_resize(int width, int height) {
    if (g_ios_window) {
        g_ios_window->width = width;
        g_ios_window->height = height;
    }
    g_ios_window_width = width;
    g_ios_window_height = height;
}

void ios_window_set_layer(void* layer) {
    if (!g_ios_window) {
        g_ios_window = (Ps3DreamWindow*)calloc(1, sizeof(Ps3DreamWindow));
    }
    g_ios_window->metal_layer = layer;
    g_ios_window->is_valid = 1;
}

void ios_window_release(void) {
    if (g_ios_window) {
        free(g_ios_window);
        g_ios_window = nullptr;
    }
}
