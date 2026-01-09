Myanmar calendar Dart CLI package supporting ai prompt, convert and date information tools.
version: 0.0.1

[![License: MIT][license_badge]][license_link]

## Getting Started 🚀

If the CLI application is available on [pub](https://pub.dev), activate globally via:

```sh
dart pub global activate myanmar_calendar_dart_cli
```

Or locally via:

```sh
dart pub global activate --source=path <path to this package>
```

## Usage

```sh
# Calendar command
$ mycal calendar

# Calendar command option
$ mycal calendar --western 1997-01-27

# Show CLI version
$ mycal --version

# Show usage help
$ mycal --help
```

### Available Options

- `ai` - A command to generate AI prompts for horoscopes, fortune telling, or divination.
- `astro` - A command to display detailed astrological information for a given date.
- `calendar` - A command to display a monthly Myanmar calendar.
- `convert` - A command to convert dates between Western and Myanmar calendars.
- `holiday` - A command to list holidays for a specific date or month.
- `today` - A command to display the current Myanmar and Western date.
- `update` - A command which updates the CLI.

[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg
[license_link]: https://opensource.org/licenses/MIT
