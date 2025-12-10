#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

#include "generated-files/2024/asn_application.h"
#include "generated-files/2024/asn_internal.h"


// The Tum message defines a field called EncryptedTumData which is just an uper encoded String.
// Since the contents of that string must also be ASN.1 encoded, they must be encoded separately to build the TUM message
// This import pulls in the additional methods required to encoded / decode the subfields of TumData
#include "generated-files/2024/TumData.h"

#include "generated-files/2024/MessageFrame.h"

#if _WIN32
#include <windows.h>
#else
#include <pthread.h>
#include <unistd.h>
#endif

#if _WIN32
#define FFI_PLUGIN_EXPORT __declspec(dllexport)
#else
#define FFI_PLUGIN_EXPORT
#endif

FFI_PLUGIN_EXPORT void initialize(int (*printCallback)(char *));

int (*print)(char *);

void printNumber(int number);
