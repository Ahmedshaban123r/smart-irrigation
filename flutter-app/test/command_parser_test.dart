import 'package:flutter_test/flutter_test.dart';
import 'package:irrigation_app/utils/command_parser.dart';

void main() {
  group('CommandParser.parse', () {
    test('recognizes emergency stop phrases', () {
      expect(CommandParser.parse('emergency stop').type, CommandType.emergencyStop);
      expect(CommandParser.parse('stop everything').type, CommandType.emergencyStop);
      expect(CommandParser.parse('stop all').type, CommandType.emergencyStop);
    });

    test('recognizes pump on phrases', () {
      expect(CommandParser.parse('pump on').type, CommandType.pumpOn);
      expect(CommandParser.parse('turn on pump').type, CommandType.pumpOn);
      expect(CommandParser.parse('start pump').type, CommandType.pumpOn);
    });

    test('recognizes pump off phrases', () {
      expect(CommandParser.parse('pump off').type, CommandType.pumpOff);
      expect(CommandParser.parse('turn off pump').type, CommandType.pumpOff);
    });

    test('extracts plant index from pump commands', () {
      expect(CommandParser.parse('pump on plant 1').plant, 1);
      expect(CommandParser.parse('pump on p1').plant, 1);
      expect(CommandParser.parse('pump on').plant, 0);
    });

    test('returns unknown for unrecognized input', () {
      expect(CommandParser.parse('hello world').type, CommandType.unknown);
      expect(CommandParser.parse('').type, CommandType.unknown);
    });

    test('is case insensitive', () {
      expect(CommandParser.parse('PUMP ON').type, CommandType.pumpOn);
      expect(CommandParser.parse('Emergency Stop').type, CommandType.emergencyStop);
    });

    test('emergency stop has highest priority over pump phrases', () {
      expect(CommandParser.parse('stop everything now').type, CommandType.emergencyStop);
    });

    test('description is non-empty for recognized commands', () {
      expect(CommandParser.parse('pump on').description, isNotEmpty);
      expect(CommandParser.parse('emergency stop').description, isNotEmpty);
    });
  });
}
