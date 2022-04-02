// AUTO GENERATED FILE, DO NOT EDIT.
// Generated by `flutter_rust_bridge`.

// ignore_for_file: non_constant_identifier_names, unused_element, duplicate_ignore, directives_ordering, curly_braces_in_flow_control_structures, unnecessary_lambdas, slash_for_doc_comments, prefer_const_literals_to_create_immutables, implicit_dynamic_list_literal, duplicate_import, unused_import, prefer_single_quotes

import 'dart:convert';
import 'dart:typed_data';

import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_rust_bridge/flutter_rust_bridge.dart';
import 'dart:ffi' as ffi;

abstract class Rgba {
  Future<void> loadRom({required Uint8List bytes, dynamic hint});

  Future<void> reset({required bool skipBios, dynamic hint});

  Future<void> keyPress({required KeyType key, dynamic hint});

  Future<void> keyRelease({required KeyType key, dynamic hint});

  Future<Uint8List> render({dynamic hint});
}

enum KeyType {
  A,
  B,
  L,
  R,
  Down,
  Up,
  Left,
  Right,
  Start,
  Select,
}

class RgbaImpl extends FlutterRustBridgeBase<RgbaWire> implements Rgba {
  factory RgbaImpl(ffi.DynamicLibrary dylib) => RgbaImpl.raw(RgbaWire(dylib));

  RgbaImpl.raw(RgbaWire inner) : super(inner);

  Future<void> loadRom({required Uint8List bytes, dynamic hint}) =>
      executeNormal(FlutterRustBridgeTask(
        callFfi: (port_) =>
            inner.wire_load_rom(port_, _api2wire_uint_8_list(bytes)),
        parseSuccessData: _wire2api_unit,
        constMeta: const FlutterRustBridgeTaskConstMeta(
          debugName: "load_rom",
          argNames: ["bytes"],
        ),
        argValues: [bytes],
        hint: hint,
      ));

  Future<void> reset({required bool skipBios, dynamic hint}) =>
      executeNormal(FlutterRustBridgeTask(
        callFfi: (port_) => inner.wire_reset(port_, skipBios),
        parseSuccessData: _wire2api_unit,
        constMeta: const FlutterRustBridgeTaskConstMeta(
          debugName: "reset",
          argNames: ["skipBios"],
        ),
        argValues: [skipBios],
        hint: hint,
      ));

  Future<void> keyPress({required KeyType key, dynamic hint}) =>
      executeNormal(FlutterRustBridgeTask(
        callFfi: (port_) =>
            inner.wire_key_press(port_, _api2wire_key_type(key)),
        parseSuccessData: _wire2api_unit,
        constMeta: const FlutterRustBridgeTaskConstMeta(
          debugName: "key_press",
          argNames: ["key"],
        ),
        argValues: [key],
        hint: hint,
      ));

  Future<void> keyRelease({required KeyType key, dynamic hint}) =>
      executeNormal(FlutterRustBridgeTask(
        callFfi: (port_) =>
            inner.wire_key_release(port_, _api2wire_key_type(key)),
        parseSuccessData: _wire2api_unit,
        constMeta: const FlutterRustBridgeTaskConstMeta(
          debugName: "key_release",
          argNames: ["key"],
        ),
        argValues: [key],
        hint: hint,
      ));

  Future<Uint8List> render({dynamic hint}) =>
      executeNormal(FlutterRustBridgeTask(
        callFfi: (port_) => inner.wire_render(port_),
        parseSuccessData: _wire2api_uint_8_list,
        constMeta: const FlutterRustBridgeTaskConstMeta(
          debugName: "render",
          argNames: [],
        ),
        argValues: [],
        hint: hint,
      ));

  // Section: api2wire
  int _api2wire_bool(bool raw) {
    return raw ? 1 : 0;
  }

  int _api2wire_key_type(KeyType raw) {
    return raw.index;
  }

  int _api2wire_u8(int raw) {
    return raw;
  }

  ffi.Pointer<wire_uint_8_list> _api2wire_uint_8_list(Uint8List raw) {
    final ans = inner.new_uint_8_list(raw.length);
    ans.ref.ptr.asTypedList(raw.length).setAll(0, raw);
    return ans;
  }

  // Section: api_fill_to_wire

}

// Section: wire2api
int _wire2api_u8(dynamic raw) {
  return raw as int;
}

Uint8List _wire2api_uint_8_list(dynamic raw) {
  return raw as Uint8List;
}

void _wire2api_unit(dynamic raw) {
  return;
}

// ignore_for_file: camel_case_types, non_constant_identifier_names, avoid_positional_boolean_parameters, annotate_overrides, constant_identifier_names

// AUTO GENERATED FILE, DO NOT EDIT.
//
// Generated by `package:ffigen`.

/// generated by flutter_rust_bridge
class RgbaWire implements FlutterRustBridgeWireBase {
  /// Holds the symbol lookup function.
  final ffi.Pointer<T> Function<T extends ffi.NativeType>(String symbolName)
      _lookup;

  /// The symbols are looked up in [dynamicLibrary].
  RgbaWire(ffi.DynamicLibrary dynamicLibrary) : _lookup = dynamicLibrary.lookup;

  /// The symbols are looked up with [lookup].
  RgbaWire.fromLookup(
      ffi.Pointer<T> Function<T extends ffi.NativeType>(String symbolName)
          lookup)
      : _lookup = lookup;

  void wire_load_rom(
    int port_,
    ffi.Pointer<wire_uint_8_list> bytes,
  ) {
    return _wire_load_rom(
      port_,
      bytes,
    );
  }

  late final _wire_load_romPtr = _lookup<
      ffi.NativeFunction<
          ffi.Void Function(
              ffi.Int64, ffi.Pointer<wire_uint_8_list>)>>('wire_load_rom');
  late final _wire_load_rom = _wire_load_romPtr
      .asFunction<void Function(int, ffi.Pointer<wire_uint_8_list>)>();

  void wire_reset(
    int port_,
    bool skip_bios,
  ) {
    return _wire_reset(
      port_,
      skip_bios ? 1 : 0,
    );
  }

  late final _wire_resetPtr =
      _lookup<ffi.NativeFunction<ffi.Void Function(ffi.Int64, ffi.Uint8)>>(
          'wire_reset');
  late final _wire_reset = _wire_resetPtr.asFunction<void Function(int, int)>();

  void wire_key_press(
    int port_,
    int key,
  ) {
    return _wire_key_press(
      port_,
      key,
    );
  }

  late final _wire_key_pressPtr =
      _lookup<ffi.NativeFunction<ffi.Void Function(ffi.Int64, ffi.Int32)>>(
          'wire_key_press');
  late final _wire_key_press =
      _wire_key_pressPtr.asFunction<void Function(int, int)>();

  void wire_key_release(
    int port_,
    int key,
  ) {
    return _wire_key_release(
      port_,
      key,
    );
  }

  late final _wire_key_releasePtr =
      _lookup<ffi.NativeFunction<ffi.Void Function(ffi.Int64, ffi.Int32)>>(
          'wire_key_release');
  late final _wire_key_release =
      _wire_key_releasePtr.asFunction<void Function(int, int)>();

  void wire_render(
    int port_,
  ) {
    return _wire_render(
      port_,
    );
  }

  late final _wire_renderPtr =
      _lookup<ffi.NativeFunction<ffi.Void Function(ffi.Int64)>>('wire_render');
  late final _wire_render = _wire_renderPtr.asFunction<void Function(int)>();

  ffi.Pointer<wire_uint_8_list> new_uint_8_list(
    int len,
  ) {
    return _new_uint_8_list(
      len,
    );
  }

  late final _new_uint_8_listPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<wire_uint_8_list> Function(
              ffi.Int32)>>('new_uint_8_list');
  late final _new_uint_8_list = _new_uint_8_listPtr
      .asFunction<ffi.Pointer<wire_uint_8_list> Function(int)>();

  void free_WireSyncReturnStruct(
    WireSyncReturnStruct val,
  ) {
    return _free_WireSyncReturnStruct(
      val,
    );
  }

  late final _free_WireSyncReturnStructPtr =
      _lookup<ffi.NativeFunction<ffi.Void Function(WireSyncReturnStruct)>>(
          'free_WireSyncReturnStruct');
  late final _free_WireSyncReturnStruct = _free_WireSyncReturnStructPtr
      .asFunction<void Function(WireSyncReturnStruct)>();

  void store_dart_post_cobject(
    DartPostCObjectFnType ptr,
  ) {
    return _store_dart_post_cobject(
      ptr,
    );
  }

  late final _store_dart_post_cobjectPtr =
      _lookup<ffi.NativeFunction<ffi.Void Function(DartPostCObjectFnType)>>(
          'store_dart_post_cobject');
  late final _store_dart_post_cobject = _store_dart_post_cobjectPtr
      .asFunction<void Function(DartPostCObjectFnType)>();
}

class wire_uint_8_list extends ffi.Struct {
  external ffi.Pointer<ffi.Uint8> ptr;

  @ffi.Int32()
  external int len;
}

typedef DartPostCObjectFnType = ffi.Pointer<
    ffi.NativeFunction<ffi.Uint8 Function(DartPort, ffi.Pointer<ffi.Void>)>>;
typedef DartPort = ffi.Int64;