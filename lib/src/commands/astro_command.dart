import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:myanmar_calendar_dart/myanmar_calendar_dart.dart';

/// {@template astro_command}
/// `mycal astro`
/// A [Command] to display detailed astrological information for a given date.
/// {@endtemplate}
class AstroCommand extends Command<int> {
  /// {@macro astro_command}
  AstroCommand({required Logger logger}) : _logger = logger {
    argParser.addOption(
      'date',
      abbr: 'd',
      help: 'The date to check (YYYY-MM-DD). Defaults to today.',
    );
  }

  @override
  String get description => 'Display detailed astrological information.';

  @override
  String get name => 'astro';

  final Logger _logger;

  @override
  Future<int> run() async {
    final dateStr = argResults?['date'] as String?;
    final mdt = _getDateTime(dateStr);

    if (mdt == null) {
      _logger.err('Invalid date format. Use YYYY-MM-DD.');
      return ExitCode.usage.code;
    }

    _logger
      ..info('')
      ..info(lightCyan.wrap('✨ Astrological Information'))
      ..info('----------------------------------------')
      ..info(
        '  ${lightYellow.wrap('Date:')} ${mdt.formatWestern('%d %M')} ${mdt.westernYear}',
      )
      ..info('  ${lightYellow.wrap('Myanmar Year:')} ${mdt.myanmarYear}')
      ..info('  ${lightYellow.wrap('Sasana Year:')}  ${mdt.sasanaYear}')
      ..info('----------------------------------------')
      ..info('  ${lightMagenta.wrap('Moon Phase:')}   ${mdt.moonPhase}')
      ..info(
        '  ${lightMagenta.wrap('Is Sabbath:')}   ${mdt.isSabbath ? 'Yes' : 'No'}',
      )
      ..info(
        '  ${lightMagenta.wrap('Year Type:')}    ${_getYearType(mdt.yearType)}',
      )
      ..info('----------------------------------------')
      ..info('  ${lightBlue.wrap('Yatyaza:')}    ${mdt.yatyaza}')
      ..info('  ${lightBlue.wrap('Pyathada:')}   ${mdt.pyathada}')
      ..info('  ${lightBlue.wrap('Nagahle:')}    ${mdt.nagahle}')
      ..info('  ${lightBlue.wrap('Mahabote:')}   ${mdt.mahabote}')
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

  String _getYearType(int type) {
    switch (type) {
      case 0:
        return 'Common Year';
      case 1:
        return 'Little Watat Year';
      case 2:
        return 'Big Watat Year';
      default:
        return 'Unknown';
    }
  }
}
