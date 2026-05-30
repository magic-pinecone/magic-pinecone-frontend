class CourseShareCodec {
  const CourseShareCodec();

  static const maxCourseCount = 255;
  static const serialBitLength = 17;
  static const _countBitLength = 8;
  static const _maxSerialValue = (1 << serialBitLength) - 1;
  static const _alphabet =
      '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';

  String encodeSerialNos(Iterable<String> serialNos) {
    final serialValues = serialNos.map(_parseSerialNo).toList(growable: false);
    if (serialValues.length > maxCourseCount) {
      throw ArgumentError.value(
        serialValues.length,
        'serialNos',
        'Only up to $maxCourseCount courses can be shared.',
      );
    }

    var buffer = BigInt.from(serialValues.length);
    var bitLength = _countBitLength;
    for (final serialValue in serialValues) {
      buffer = (buffer << serialBitLength) | BigInt.from(serialValue);
      bitLength += serialBitLength;
    }

    final hexLength = (bitLength / 4).ceil();
    final hex = buffer.toRadixString(16).padLeft(hexLength, '0');
    return _hexToBase62(hex);
  }

  List<String> decodeSerialNos(String code) {
    final normalizedCode = code.trim();
    if (normalizedCode.isEmpty) {
      throw ArgumentError.value(code, 'code', 'Share code cannot be empty.');
    }

    final binary = _base62ToBigInt(normalizedCode).toRadixString(2);
    for (var count = 0; count <= maxCourseCount; count++) {
      final bitLength = _countBitLength + count * serialBitLength;
      if (binary.length > bitLength) continue;

      final candidate = binary.padLeft(bitLength, '0');
      final parsedCount = _parseBinary(candidate.substring(0, _countBitLength));
      if (parsedCount != count) continue;

      return [
        for (var index = 0; index < count; index++)
          _parseBinary(
            candidate.substring(
              _countBitLength + index * serialBitLength,
              _countBitLength + (index + 1) * serialBitLength,
            ),
          ).toString().padLeft(5, '0'),
      ];
    }

    throw ArgumentError.value(code, 'code', 'Share code is malformed.');
  }

  int _parseSerialNo(String serialNo) {
    final value = int.tryParse(serialNo.trim());
    if (value == null || value < 0 || value > _maxSerialValue) {
      throw ArgumentError.value(
        serialNo,
        'serialNo',
        'Serial number must fit in $serialBitLength bits.',
      );
    }
    return value;
  }

  int _parseBinary(String binary) {
    return int.parse(binary, radix: 2);
  }

  String _hexToBase62(String hex) {
    return _bigIntToBase62(BigInt.parse(hex, radix: 16));
  }

  String _bigIntToBase62(BigInt value) {
    if (value == BigInt.zero) return '0';

    final base = BigInt.from(_alphabet.length);
    final digits = <String>[];
    var remaining = value;
    while (remaining > BigInt.zero) {
      final remainder = (remaining % base).toInt();
      digits.add(_alphabet[remainder]);
      remaining = remaining ~/ base;
    }
    return digits.reversed.join();
  }

  BigInt _base62ToBigInt(String code) {
    final base = BigInt.from(_alphabet.length);
    var value = BigInt.zero;
    for (final codeUnit in code.codeUnits) {
      final digit = _alphabet.indexOf(String.fromCharCode(codeUnit));
      if (digit < 0) {
        throw ArgumentError.value(code, 'code', 'Share code is not base62.');
      }
      value = value * base + BigInt.from(digit);
    }
    return value;
  }
}
