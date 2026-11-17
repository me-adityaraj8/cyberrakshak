import 'package:cyberrakshak/app/actions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('WhatsApp numbers get the Indian country code', () {
    expect(Act.whatsAppNumber('98123 45678'), '919812345678');
    expect(Act.whatsAppNumber('+91 98123-45678'), '919812345678');
    expect(Act.whatsAppNumber('09812345678'), '919812345678');
    expect(Act.whatsAppNumber(''), '');
  });
}
