#include "asn1_plugin.h"


struct xer_buffer {
    char *buffer;
    size_t buffer_size;
    size_t allocated_size;
};

int xer__buffer_append(const void *buffer, size_t size, void *app_key) {
    struct xer_buffer *xb = app_key;

    while(xb->buffer_size + size + 1 > xb->allocated_size) {
        size_t new_size = 2 * (xb->allocated_size ? xb->allocated_size : 64);
        char *new_buf = MALLOC(new_size);
        if(!new_buf) return -1;
        if (xb->buffer) {
            memcpy(new_buf, xb->buffer, xb->buffer_size);
        }
        FREEMEM(xb->buffer);
        xb->buffer = new_buf;
        xb->allocated_size = new_size;
    }

    memcpy(xb->buffer + xb->buffer_size, buffer, size);
    xb->buffer_size += size;
    xb->buffer[xb->buffer_size] = '\0';
    return 0;
}


int (*print)(char *);

FFI_PLUGIN_EXPORT void initialize(int (*printCallback)(char *)) {
    print = printCallback;
    print("C library initialized");
}