import '../services/firebase_service.dart';
import 'app_logger.dart';

enum CommandType { emergencyStop, pumpOn, pumpOff, unknown }

class ParsedCommand {
  final CommandType type;
  final int? plant;
  final String description;

  const ParsedCommand({
    required this.type,
    this.plant,
    required this.description,
  });
}

class CommandParser {
  static ParsedCommand parse(String text) {
    final lower = text.toLowerCase().trim();

    if (_matches(lower, ['emergency stop', 'stop everything', 'stop all'])) {
      return const ParsedCommand(
        type: CommandType.emergencyStop,
        description: 'Emergency stop triggered',
      );
    }
    if (_matches(lower, ['pump on', 'turn on pump', 'start pump', 'switch pump on'])) {
      final plant = _extractPlant(lower);
      return ParsedCommand(
        type: CommandType.pumpOn,
        plant: plant,
        description: 'Pump ON → plant $plant',
      );
    }
    if (_matches(lower, ['pump off', 'turn off pump', 'stop pump', 'switch pump off'])) {
      final plant = _extractPlant(lower);
      return ParsedCommand(
        type: CommandType.pumpOff,
        plant: plant,
        description: 'Pump OFF → plant $plant',
      );
    }

    return const ParsedCommand(
      type: CommandType.unknown,
      description: 'Command not recognized',
    );
  }

  static Future<void> execute(ParsedCommand cmd) async {
    log.i('Voice command: ${cmd.description}');
    switch (cmd.type) {
      case CommandType.emergencyStop:
        await FirebaseService.writeEmergencyStop();
      case CommandType.pumpOn:
        await FirebaseService.writePumpAction(
          state: 'ON',
          plant: cmd.plant ?? 0,
        );
      case CommandType.pumpOff:
        await FirebaseService.writePumpAction(
          state: 'OFF',
          plant: cmd.plant ?? 0,
        );
      case CommandType.unknown:
        break;
    }
  }

  static int _extractPlant(String input) {
    if (input.contains('plant 1') || input.contains('p1')) return 1;
    return 0;
  }

  static bool _matches(String input, List<String> phrases) =>
      phrases.any((p) => input.contains(p));
}
