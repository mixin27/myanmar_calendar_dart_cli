import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:myanmar_calendar_dart/myanmar_calendar_dart.dart';

/// {@template convert_command}
/// `mycal convert`
/// A [Command] to convert dates between Western and Myanmar calendars.
/// {@endtemplate}
class ConvertCommand extends Command<int> {
  /// {@macro convert_command}
  ConvertCommand({required Logger logger}) : _logger = logger {
    argParser
      ..addOption(
        'western',
        abbr: 'w',
        help: 'The Western date to convert (YYYY-MM-DD).',
      )
      ..addOption(
        'myanmar',
        abbr: 'm',
        help: 'The Myanmar date to convert (YYYY-MM-DD or YYYY-MM-DD-P-F).',
      );
  }

  @override
  String get description =>
      'Convert dates between Western and Myanmar calendars.';

  @override
  String get name => 'convert';

  final Logger _logger;

  @override
  Future<int> run() async {
    final westernDate = argResults?['western'] as String?;
    final myanmarDate = argResults?['myanmar'] as String?;

    if (westernDate != null) {
      return _convertWesternToMyanmar(westernDate);
    } else if (myanmarDate != null) {
      return _convertMyanmarToWestern(myanmarDate);
    } else {
      _logger.err('Please provide either --western or --myanmar date.');
      printUsage();
      return ExitCode.usage.code;
    }
  }

  Future<int> _convertWesternToMyanmar(String dateStr) async {
    try {
      final parts = dateStr.split('-');
      if (parts.length != 3) {
        _logger.err('Invalid date format. Use YYYY-MM-DD.');
        return ExitCode.usage.code;
      }
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final day = int.parse(parts[2]);

      final mdt = MyanmarCalendar.fromWestern(year, month, day);
      _displayResult(mdt);
      return ExitCode.success.code;
    } catch (e) {
      _logger.err('Error parsing Western date: $e');
      return ExitCode.usage.code;
    }
  }

  Future<int> _convertMyanmarToWestern(String dateStr) async {
    try {
      final parts = dateStr.split('-');
      if (parts.length < 3) {
        _logger.err('Invalid Myanmar date format. Use YYYY-MM-DD.');
        return ExitCode.usage.code;
      }
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final day = int.parse(parts[2]);

      final mdt = MyanmarCalendar.fromMyanmar(year, month, day);
      _displayResult(mdt);
      return ExitCode.success.code;
    } catch (e) {
      _logger.err('Error parsing Myanmar date: $e');
      return ExitCode.usage.code;
    }
  }

  void _displayResult(MyanmarDateTime mdt) {
    _logger
      ..info('')
      ..info(lightCyan.wrap('📅 Conversion Result'))
      ..info('----------------------------------------')
      ..info(
        '  ${lightYellow.wrap('Western Date:')} ${mdt.formatWestern('%d %M %yyyy')}',
      )
      ..info(
        '  ${lightYellow.wrap('Myanmar Date:')} ${mdt.formatMyanmar('&y &M &P &ff')}',
      )
      ..info('  ${lightYellow.wrap('Moon Phase:')}   ${mdt.moonPhase}');

    if (mdt.hasHolidays) {
      _logger.info(
        '  ${lightGreen.wrap('🎉 Holidays:')}    ${mdt.allHolidays.join(', ')}',
      );
    }
    _logger
      ..info('----------------------------------------')
      ..info('');
  }
}
