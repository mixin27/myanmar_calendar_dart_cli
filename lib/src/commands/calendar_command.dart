import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:myanmar_calendar_dart/myanmar_calendar_dart.dart';

/// {@template calendar_command}
/// `mycal calendar`
/// A [Command] to display a monthly Myanmar calendar.
/// {@endtemplate}
class CalendarCommand extends Command<int> {
  /// {@macro calendar_command}
  CalendarCommand({required Logger logger}) : _logger = logger {
    argParser
      ..addOption(
        'year',
        abbr: 'y',
        help: 'The Myanmar year to display.',
      )
      ..addOption(
        'month',
        abbr: 'm',
        help: 'The Myanmar month to display (1-12).',
      );
  }

  @override
  String get description => 'Display a monthly Myanmar calendar.';

  @override
  String get name => 'calendar';

  final Logger _logger;

  @override
  Future<int> run() async {
    final now = MyanmarDateTime.now();
    final year =
        int.tryParse(argResults?['year'] as String? ?? '') ?? now.myanmarYear;
    final month =
        int.tryParse(argResults?['month'] as String? ?? '') ?? now.myanmarMonth;

    if (month < 1 || month > 12) {
      _logger.err('Invalid month. Use 1-12.');
      return ExitCode.usage.code;
    }

    final monthData = MyanmarCalendar.getMyanmarMonth(year, month);

    _logger
      ..info('')
      ..info(lightCyan.wrap('📅 Myanmar Calendar - $year Month $month'))
      ..info('----------------------------------------')
      ..info('${lightYellow.wrap('Sun  Mon  Tue  Wed  Thu  Fri  Sat')}')
      ..info('----------------------------------------');

    // Basic grid implementation
    // We'll just list the dates for now as a full grid calculation might be complex
    // for a simple CLI without knowing the first day of the month easily.

    for (final date in monthData) {
      final mdt = MyanmarCalendar.fromMyanmar(year, month, date.day);
      final dayStr = mdt.myanmarDay.toString().padLeft(2);
      final phase = mdt.moonPhase == 1
          ? '🌕'
          : (mdt.moonPhase == 3 ? '🌑' : '  ');
      final sabbath = mdt.isSabbath ? '✨' : '  ';

      _logger.info(
        '  $dayStr $phase $sabbath | Western: ${mdt.formatWestern('%d %M')}',
      );
    }

    _logger
      ..info('----------------------------------------')
      ..info('');

    return ExitCode.success.code;
  }
}
