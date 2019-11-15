import 'package:flutter_test/flutter_test.dart';

import 'package:nat_info/nat_info.dart';

void main() {
  test('simulates no internet connection', () {
    final info = new NATInfo([null, null, null, null]);
    expect(info.connected, false);
    expect(info.publicAddress, null);
    expect(info.mappingCertainty, null);
    expect(info.natMapping, null);
  });
}
