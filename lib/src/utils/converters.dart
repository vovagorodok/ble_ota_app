import 'dart:typed_data';

Uint8List uint8ToBytes(int value) =>
    Uint8List(1)..buffer.asByteData().setUint8(0, value);

Uint8List uint32ToBytes(int value) =>
    Uint8List(4)..buffer.asByteData().setUint32(0, value, Endian.little);

int bytesToUint8(Uint8List data, int offset) =>
    data.buffer.asByteData().getUint8(offset);

int bytesToUint32(Uint8List data, int offset) =>
    data.buffer.asByteData().getUint32(offset, Endian.little);
