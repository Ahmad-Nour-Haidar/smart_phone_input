import 'package:flutter_test/flutter_test.dart';
import 'package:smart_phone_input/smart_phone_input.dart';

void main() {
  group('PhoneNumber()', () {
    test('keeps only the digits, converting Arabic digits', () {
      final number = PhoneNumber(isoCode: 'ps', digits: '٠٥٩٩ ١٢٣-٤٥٦');

      expect(number.isoCode, 'PS');
      expect(number.dialCode, '+970');
      expect(number.digits, '0599123456');
    });

    test('validates numbers with or without the national prefix', () {
      expect(
        PhoneNumber(isoCode: 'PS', digits: '0599123456').e164,
        '+970599123456',
      );
      expect(
        PhoneNumber(isoCode: 'PS', digits: '599123456').e164,
        '+970599123456',
      );
    });

    test('validates numbers after a dial code with an area code', () {
      expect(
        PhoneNumber(isoCode: 'AI', digits: '2351234').e164,
        '+12642351234',
      );
    });

    test('has no E.164 form when invalid', () {
      final number = PhoneNumber(isoCode: 'PS', digits: '123');

      expect(number.isValid, isFalse);
      expect(number.e164, isNull);
      expect(number.type, PhoneNumberType.unknown);
    });

    test('is empty without digits', () {
      final number = PhoneNumber(isoCode: 'PS');

      expect(number.isEmpty, isTrue);
      expect(number.isValid, isFalse);
    });

    test('validates Vatican City numbers after +39', () {
      final number = PhoneNumber(isoCode: 'VA', digits: '0669812345');

      expect(number.dialCode, '+39');
      expect(number.e164, '+390669812345');
    });

    test('validates Saint Helena, Ascension and Tristan da Cunha', () {
      expect(PhoneNumber(isoCode: 'SH', digits: '22158').e164, '+29022158');
      expect(PhoneNumber(isoCode: 'AC', digits: '62889').e164, '+24762889');
      expect(PhoneNumber(isoCode: 'TA', digits: '8999').e164, '+2908999');
    });

    test('validates territories without numbering data of their own by the '
        'plan of their dial code', () {
      // Norway, Réunion, New Zealand, the Falklands and Norfolk Island.
      expect(
        PhoneNumber(isoCode: 'BV', digits: '41234567').e164,
        '+4741234567',
      );
      expect(
        PhoneNumber(isoCode: 'TF', digits: '0692123456').e164,
        '+262692123456',
      );
      expect(
        PhoneNumber(isoCode: 'PN', digits: '0211234567').e164,
        '+64211234567',
      );
      expect(PhoneNumber(isoCode: 'GS', digits: '51234').e164, '+50051234');
      expect(PhoneNumber(isoCode: 'AQ', digits: '381234').e164, '+672381234');
      expect(PhoneNumber(isoCode: 'HM', digits: '381234').e164, '+672381234');
    });

    test('throws for unknown countries', () {
      expect(() => PhoneNumber(isoCode: 'XX'), throwsArgumentError);
    });
  });

  group('tryParse', () {
    PhoneNumber? parse(String text, {String? isoCode}) =>
        PhoneNumber.tryParse(text, isoCode: isoCode);

    test('detects the country of an international number', () {
      final number = parse('+966 50 123 4567')!;

      expect(number.isoCode, 'SA');
      expect(number.digits, '501234567');
      expect(number.isValid, isTrue);
    });

    test('accepts the 00 prefix and Arabic digits', () {
      expect(parse('00966501234567')?.e164, '+966501234567');
      expect(parse('+٩٦٦٥٠١٢٣٤٥٦٧')?.e164, '+966501234567');
    });

    test('detects countries whose dial code includes an area code', () {
      final number = parse('+12642351234')!;

      expect(number.isoCode, 'AI');
      expect(number.digits, '2351234');
    });

    test('detects Sint Maarten and Western Sahara', () {
      final sintMaarten = parse('+17215205678')!;
      expect(sintMaarten.isoCode, 'SX');
      expect(sintMaarten.digits, '5205678');
      expect(sintMaarten.isValid, isTrue);

      // libphonenumber lists Morocco first for numbers valid in both.
      expect(parse('+212528812345')?.isoCode, 'MA');
      final westernSahara = parse('+212528812345', isoCode: 'EH')!;
      expect(westernSahara.isoCode, 'EH');
      expect(westernSahara.isValid, isTrue);
    });

    test('keeps a preferred country only when the number is valid there', () {
      expect(parse('+16135550123', isoCode: 'US')?.isoCode, 'CA');
      expect(parse('+12015550123', isoCode: 'CA')?.isoCode, 'US');
    });

    test('keeps a preferred territory without numbering data of its own', () {
      expect(parse('+4741234567')?.isoCode, 'NO');
      final bouvet = parse('+4741234567', isoCode: 'BV')!;
      expect(bouvet.isoCode, 'BV');
      expect(bouvet.isValid, isTrue);
    });

    test('detects Ascension and Tristan da Cunha', () {
      expect(parse('+24762889')?.isoCode, 'AC');
      expect(parse('+2908999')?.isoCode, 'TA');
      expect(parse('+29022158')?.isoCode, 'SH');
    });

    test('keeps a preferred country that shares the dial code', () {
      expect(parse('+1', isoCode: 'CA')?.isoCode, 'CA');
      expect(parse('+1')?.isoCode, 'US');
    });

    test('returns an invalid number when only the calling code is known', () {
      final number = parse('+96650')!;

      expect(number.isoCode, 'SA');
      expect(number.isValid, isFalse);
    });

    test('parses national numbers of the given country', () {
      expect(parse('0599123456', isoCode: 'PS')?.e164, '+970599123456');
    });

    test('returns null when the country is unknown', () {
      expect(parse('+999123'), isNull);
      expect(parse('0599123456'), isNull);
      expect(parse(''), isNull);
    });
  });

  group('format', () {
    final number = PhoneNumber(isoCode: 'PS', digits: '0599123456');

    test('writes valid numbers in every format', () {
      expect(number.format(), '+970 599 123 456');
      expect(number.format(PhoneNumberFormat.national), '0599 123 456');
      expect(number.format(PhoneNumberFormat.e164), '+970599123456');
    });

    test('returns invalid numbers as typed', () {
      final invalid = PhoneNumber(isoCode: 'PS', digits: '123');

      expect(invalid.format(), '+970123');
      expect(invalid.format(PhoneNumberFormat.national), '123');
    });
  });

  test('type detects mobile and toll-free numbers', () {
    expect(
      PhoneNumber(isoCode: 'SA', digits: '0501234567').type,
      PhoneNumberType.mobile,
    );
    expect(
      PhoneNumber(isoCode: 'US', digits: '8002345678').type,
      PhoneNumberType.tollFree,
    );
  });

  test('numbers are equal by country and digits', () {
    final number = PhoneNumber(isoCode: 'PS', digits: '0599123456');

    expect(number, PhoneNumber(isoCode: 'PS', digits: '0599 123 456'));
    expect(
      number.hashCode,
      PhoneNumber(isoCode: 'PS', digits: '0599123456').hashCode,
    );
    expect(number, isNot(PhoneNumber(isoCode: 'PS', digits: '599123456')));
    expect(number, isNot(PhoneNumber(isoCode: 'LB', digits: '0599123456')));
  });

  test('copyWith replaces the country or the digits', () {
    final number = PhoneNumber(isoCode: 'PS', digits: '0599123456');

    expect(number.copyWith(isoCode: 'LB').isoCode, 'LB');
    expect(number.copyWith(digits: '1').digits, '1');
  });

  test('toString shows the country, digits and validity', () {
    expect(
      PhoneNumber(isoCode: 'PS', digits: '0599123456').toString(),
      'PhoneNumber(PS, +970 0599123456, valid: +970599123456)',
    );
  });
}
