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
      )
      ..addOption(
        'day',
        abbr: 'd',
        help: 'The Myanmar day of month to display (1-30).',
      )
      ..addOption(
        'western',
        abbr: 'w',
        help: 'The Western date to display (YYYY-MM-DD).',
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

    // Parse arguments
    final yearArg = argResults?['year'] as String?;
    final monthArg = argResults?['month'] as String?;
    final dayArg = argResults?['day'] as String?;
    final westernArg = argResults?['western'] as String?;

    var year = int.tryParse(yearArg ?? '') ?? now.myanmarYear;
    var month = int.tryParse(monthArg ?? '') ?? now.myanmarMonth;
    var day = int.tryParse(dayArg ?? '') ?? now.myanmarDay;

    if (westernArg != null) {
      try {
        final parts = westernArg.split('-');
        if (parts.length != 3) throw const FormatException();
        final dt = DateTime(
          int.parse(parts[0]),
          int.parse(parts[1]),
          int.parse(parts[2]),
        );
        final mdtFromWestern = MyanmarCalendar.fromDateTime(dt);
        year = mdtFromWestern.myanmarYear;
        month = mdtFromWestern.myanmarMonth;
        day = mdtFromWestern.myanmarDay;
      } catch (_) {
        _logger.err('Invalid western date format. Use YYYY-MM-DD.');
        return ExitCode.usage.code;
      }
    }

    // Handle month out of range if necessary (package might throw)
    if (month < 0 || month > 14) {
      _logger.err(
        'Invalid month index. Use 1-12 (or 0, 13, 14 for intercalary months).',
      );
      return ExitCode.usage.code;
    }

    final mdt = MyanmarCalendar.fromMyanmar(year, month, day);
    final title = mdt.formatMyanmar();
    final westernDate = '${mdt.formatWestern('%d %M')} ${mdt.westernYear}';

    _logger
      ..info('')
      ..info(lightCyan.wrap('📅 Myanmar Calendar'))
      ..info('  ${lightYellow.wrap('Myanmar:')} $title')
      ..info('  ${lightYellow.wrap('Western:')} $westernDate')
      ..info('--------------------------------------------')
      ..info('${lightYellow.wrap('  Sun  Mon  Tue  Wed  Thu  Fri  Sat')}')
      ..info('--------------------------------------------');

    final monthData = MyanmarCalendar.getMyanmarMonth(year, month);
    if (monthData.isEmpty) {
      _logger.err('No data found for the given month.');
      return ExitCode.usage.code;
    }

    final firstMdt = MyanmarCalendar.fromMyanmar(year, month, 1);
    final firstDt = DateTime(
      firstMdt.westernYear,
      firstMdt.westernMonth,
      firstMdt.westernDay,
    );
    final firstWeekday = firstDt.weekday % 7;

    final buffer = StringBuffer();
    for (var i = 0; i < firstWeekday; i++) {
      buffer.write('     ');
    }

    final todayMdt = MyanmarDateTime.now();

    for (final date in monthData) {
      final currentMdt = MyanmarCalendar.fromMyanmar(year, month, date.day);
      final dt = DateTime(
        currentMdt.westernYear,
        currentMdt.westernMonth,
        currentMdt.westernDay,
      );
      final currentWeekday = dt.weekday % 7;

      final isCurrent =
          year == mdt.myanmarYear &&
          month == mdt.myanmarMonth &&
          date.day == mdt.myanmarDay;

      final isToday =
          year == todayMdt.myanmarYear &&
          month == todayMdt.myanmarMonth &&
          date.day == todayMdt.myanmarDay;

      var dayStr = date.day.toString().padLeft(2);
      if (currentMdt.isSabbath) {
        dayStr = lightRed.wrap(dayStr)!;
      } else if (currentMdt.isFullMoon) {
        dayStr = lightCyan.wrap(dayStr)!;
      } else if (currentMdt.isNewMoon) {
        dayStr = lightMagenta.wrap(dayStr)!;
      }

      if (isCurrent) {
        buffer.write('[$dayStr] ');
      } else if (isToday) {
        buffer.write('*$dayStr* ');
      } else {
        buffer.write(' $dayStr  ');
      }

      if (currentWeekday == 6) {
        _logger.info(buffer.toString());
        buffer.clear();
      }
    }

    if (buffer.isNotEmpty) {
      _logger.info(buffer.toString());
    }

    _logger
      ..info('--------------------------------------------')
      ..info(
        '  ${lightCyan.wrap('●')}: Full Moon   ${lightMagenta.wrap('●')}: New Moon   ${lightRed.wrap('●')}: Sabbath',
      )
      ..info('  [ ]: Selected    * *: Today')
      ..info('');

    return ExitCode.success.code;
  }
}
