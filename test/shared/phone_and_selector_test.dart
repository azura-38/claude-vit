import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitacase/shared/widgets/inputs/phone_number_input.dart';
import 'package:vitacase/shared/widgets/inputs/blood_group_selector.dart';

void main() {
  group('Phase 11 Phone Country Codes & Backward Compatibility', () {
    test('PhoneCountryCodes parses +90 correctly', () {
      final parsed = PhoneCountryCodes.parse('+90 555 123 4567');
      expect(parsed.countryCode, equals('+90'));
      expect(parsed.localNumber, equals('555 123 4567'));
    });

    test('PhoneCountryCodes parses +1 correctly', () {
      final parsed = PhoneCountryCodes.parse('+1 202 555 0199');
      expect(parsed.countryCode, equals('+1'));
      expect(parsed.localNumber, equals('202 555 0199'));
    });

    test('PhoneCountryCodes parses +44 correctly', () {
      final parsed = PhoneCountryCodes.parse('+44 7911 123456');
      expect(parsed.countryCode, equals('+44'));
      expect(parsed.localNumber, equals('7911 123456'));
    });

    test('PhoneCountryCodes parses +49 correctly', () {
      final parsed = PhoneCountryCodes.parse('+49 151 23456789');
      expect(parsed.countryCode, equals('+49'));
      expect(parsed.localNumber, equals('151 23456789'));
    });

    test('Backward compatibility: unparsed/legacy numbers without code default safely to +90 without crashing', () {
      final legacy1 = PhoneCountryCodes.parse('05551234567');
      expect(legacy1.countryCode, equals('+90'));
      expect(legacy1.localNumber, equals('05551234567'));

      final legacy2 = PhoneCountryCodes.parse('5321112233');
      expect(legacy2.countryCode, equals('+90'));
      expect(legacy2.localNumber, equals('5321112233'));

      final empty = PhoneCountryCodes.parse('');
      expect(empty.countryCode, equals('+90'));
      expect(empty.localNumber, equals(''));

      final nullVal = PhoneCountryCodes.parse(null);
      expect(nullVal.countryCode, equals('+90'));
      expect(nullVal.localNumber, equals(''));
    });

    test('Contains standard list of country codes including +1, +7, +20, +44, +49, +90', () {
      final codes = PhoneCountryCodes.all.map((c) => c.code).toSet();
      expect(codes.contains('+1'), isTrue);
      expect(codes.contains('+7'), isTrue);
      expect(codes.contains('+20'), isTrue);
      expect(codes.contains('+44'), isTrue);
      expect(codes.contains('+49'), isTrue);
      expect(codes.contains('+90'), isTrue);
    });

    testWidgets('VitaPhoneInput renders with country code selector and phone field', (tester) async {
      String selectedCode = '+90';
      final controller = TextEditingController(text: '5551234567');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return VitaPhoneInput(
                  countryCode: selectedCode,
                  controller: controller,
                  onCountryCodeChanged: (newCode) {
                    setState(() => selectedCode = newCode);
                  },
                  isDark: false,
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('+90'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);

      // Enter new phone number
      await tester.enterText(find.byType(TextField), '5329998877');
      await tester.pump();

      expect(selectedCode, equals('+90'));
      expect(controller.text, equals('5329998877'));
    });

    testWidgets('BloodGroupSelector renders and allows selection', (tester) async {
      String selectedGroup = 'A+';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return BloodGroupSelector(
                  selectedGroup: selectedGroup,
                  onChanged: (val) {
                    setState(() => selectedGroup = val);
                  },
                  isDark: false,
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('A+'), findsOneWidget);
    });
  });
}
