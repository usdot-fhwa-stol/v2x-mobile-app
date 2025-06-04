import 'dart:ffi' as ffi;

class ManualNativeBindings {

  final ffi.Pointer<T> Function<T extends ffi.NativeType>(String symbolName)
      _lookup;

  /// The symbols are looked up in [dynamicLibrary].
  ManualNativeBindings(ffi.DynamicLibrary dynamicLibrary)
      : _lookup = dynamicLibrary.lookup;

  /// The symbols are looked up with [lookup].
  ManualNativeBindings.fromLookup(
      ffi.Pointer<T> Function<T extends ffi.NativeType>(String symbolName)
          lookup)
      : _lookup = lookup;


  int xer__buffer_append(
    ffi.Pointer<ffi.Void> buffer,
    int size,
    ffi.Pointer<ffi.Void> appKey
  ) {
    return _xer__buffer_append(
      buffer,
      size,
      appKey
    );
  }

  late final _xer__buffer_appendPtr = _lookup<
      ffi.NativeFunction<
          ffi.Int Function(
              ffi.Pointer<ffi.Void>,
              ffi.Size,
              ffi.Pointer<ffi.Void>)>>('xer__buffer_append');

  late final _xer__buffer_append = _xer__buffer_appendPtr.asFunction<
      int Function(
          ffi.Pointer<ffi.Void>,
          int,
          ffi.Pointer<ffi.Void>)>();

  get_buffer_append(){
    return _xer__buffer_appendPtr;
  }

  

}

final class XerBuffer extends ffi.Struct {
  external ffi.Pointer<ffi.Int8> buffer;

  @ffi.Size()
  external int buffer_size;

  @ffi.Size()
  external int allocated_size;
}