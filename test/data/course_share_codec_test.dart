import 'package:flutter_test/flutter_test.dart';
import 'package:magic_pinecone/features/course_selection/data/course_share_codec.dart';

void main() {
  const codec = CourseShareCodec();

  test('encodes empty selection', () {
    expect(codec.encodeSerialNos(const []), '0');
    expect(codec.decodeSerialNos('0'), isEmpty);
  });

  test('round trips padded serial numbers', () {
    final code = codec.encodeSerialNos(const ['00001', '00003', '12345']);

    expect(code, matches(RegExp(r'^[0-9A-Za-z]+$')));
    expect(codec.decodeSerialNos(code), ['00001', '00003', '12345']);
  });

  test('rejects serials that do not fit in 17 bits', () {
    expect(() => codec.encodeSerialNos(const ['131072']), throwsArgumentError);
  });

  test('rejects malformed base62 code', () {
    expect(() => codec.decodeSerialNos('bad!'), throwsArgumentError);
  });
}
