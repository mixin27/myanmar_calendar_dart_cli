import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:myanmar_calendar_dart/myanmar_calendar_dart.dart';

/// {@template holiday_command}
/// `mycal holiday`
/// A [Command] to list holidays for a specific date or month.
/// {@endtemplate}
class HolidayCommand extends Command<int> {
  /// {@macro holiday_command}
  HolidayCommand({required Logger logger}) : _logger = logger {
    argParser.addOption(
      'western',
      abbr: 'w',
      help: 'The date to check (YYYY-MM-DD). Defaults to today.',
    );
  }

  @override
  String get description => 'List holidays for a specific date.';

  @override
  String get name => 'holiday';

  final Logger _logger;

  @override
  Future<int> run() async {
    final dateStr = argResults?['western'] as String?;
    final mdt = _getDateTime(dateStr);

    if (mdt == null) {
      _logger.err('Invalid date format. Use YYYY-MM-DD.');
      return ExitCode.usage.code;
    }

    _logger
      ..info('')
      ..info(lightCyan.wrap('🎉 Holiday Information'))
      ..info('----------------------------------------')
      ..info(
        '  ${lightYellow.wrap('Date:')} ${mdt.formatWestern('%d %M %yyyy')}',
      )
      ..info('----------------------------------------');

    if (mdt.hasHolidays) {
      _logger.info('  ${lightGreen.wrap('Holidays found:')}');
      for (final holiday in mdt.allHolidays) {
        _logger.info('  - $holiday');
      }

      final publicHolidays = mdt.publicHolidays;
      if (publicHolidays.isNotEmpty) {
        _logger.info(
          '  ${lightBlue.wrap('Public Holidays:')} ${publicHolidays.join(', ')}',
        );
      }
    } else {
      _logger.info('  No holidays found for this date.');
    }

    _logger
      ..info('----------------------------------------')
      ..info('');

    return ExitCode.success.code;
  }

  MyanmarDateTime? _getDateTime(String? dateStr) {
    if (dateStr == null) return MyanmarDateTime.now();
    try {
      final parts = dateStr.split('-');
      if (parts.length != 3) return null;
      return MyanmarCalendar.fromWestern(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
    } catch (_) {
      return null;
    }
  }
}
