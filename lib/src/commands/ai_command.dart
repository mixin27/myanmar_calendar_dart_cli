import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:myanmar_calendar_dart/myanmar_calendar_dart.dart';

/// {@template ai_command}
/// `mycal ai`
/// A [Command] to generate AI prompts for horoscopes, fortune telling, or divination.
/// {@endtemplate}
class AiCommand extends Command<int> {
  /// {@macro ai_command}
  AiCommand({required Logger logger}) : _logger = logger {
    argParser
      ..addOption(
        'western',
        abbr: 'w',
        help:
            'The date to generate prompt for (YYYY-MM-DD). Defaults to today.',
      )
      ..addOption(
        'type',
        abbr: 't',
        help: 'The type of prompt to generate.',
        allowed: ['horoscope', 'fortune', 'divination'],
        defaultsTo: 'horoscope',
      );
  }

  @override
  String get description => 'Generate AI prompts for astrological information.';

  @override
  String get name => 'ai';

  final Logger _logger;

  @override
  Future<int> run() async {
    final dateStr = argResults?['western'] as String?;
    final typeStr = argResults?['type'] as String;

    final mdt = _getDateTime(dateStr);
    if (mdt == null) {
      _logger.err('Invalid date format. Use YYYY-MM-DD.');
      return ExitCode.usage.code;
    }

    final type = _getPromptType(typeStr);
    final completeDate = MyanmarCalendar.getCompleteDate(
      DateTime(mdt.westernYear, mdt.westernMonth, mdt.westernDay),
    );
    final prompt = MyanmarCalendar.generateAIPrompt(
      completeDate,
      language: Language.english,
      type: type,
    );

    _logger
      ..info('')
      ..info(lightCyan.wrap('🤖 AI Prompt Generated ($typeStr)'))
      ..info('----------------------------------------')
      ..info(prompt)
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

  AIPromptType _getPromptType(String type) {
    switch (type) {
      case 'fortune':
        return AIPromptType.fortuneTelling;
      case 'divination':
        return AIPromptType.divination;
      case 'horoscope':
      default:
        return AIPromptType.horoscope;
    }
  }
}
