import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:myanmar_calendar_dart/myanmar_calendar_dart.dart';

/// {@template today_command}
/// `mycal today`
/// A [Command] to display the current Myanmar and Western date.
/// {@endtemplate}
class TodayCommand extends Command<int> {
  /// {@macro today_command}
  TodayCommand({required Logger logger}) : _logger = logger;

  @override
  String get description => 'Display the current Myanmar and Western date.';

  @override
  String get name => 'today';

  final Logger _logger;

  @override
  Future<int> run() async {
    final today = MyanmarDateTime.now();

    _logger
      ..info('')
      ..info(lightCyan.wrap('📅 Myanmar Calendar - Today'))
      ..info(divider)
      ..info(
        '  ${lightYellow.wrap('Western Date:')} ${today.formatWestern('%d %M %yyyy')}',
      )
      ..info(
        '  ${lightYellow.wrap('Myanmar Date:')} ${today.formatMyanmar('&y &M &P &ff')}',
      )
      ..info('  ${lightYellow.wrap('Moon Phase:')}   ${today.moonPhase}');

    if (today.isSabbath) {
      _logger.info('  ${lightRed.wrap('✨ Today is Sabbath Day!')}');
    } else if (today.isSabbathEve) {
      _logger.info('  ${lightRed.wrap('✨ Today is Sabbath Eve!')}');
    }

    if (today.hasHolidays) {
      _logger.info(
        '  ${lightGreen.wrap('🎉 Holidays:')}    ${today.allHolidays.join(', ')}',
      );
    }

    _logger
      ..info(divider)
      ..info('');

    return ExitCode.success.code;
  }

  String get divider => '----------------------------------------';
}
