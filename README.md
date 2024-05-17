# Timeline Calendar

The **Timeline Calendar** is a Flutter package that displays a calendar in a
timeline format, providing an intuitive and visually appealing way to view dates
throughout the month.

![image](img.png)

## Key Features

- Timeline-style calendar display.
- Easy and quick integration into existing Flutter apps.

## Installation

To install **Timeline Calendar** in your Flutter project, follow these steps:

1. Add the `timeline_calendar` dependency to your project's `pubspec.yaml` file:

```yaml
dependencies:
  flutter:
    sdk: flutter
  timeline_calendar: ^1.0.2
```

2. Run the `flutter pub get` command in the terminal to install the dependency.

## Basic Usage

```dart
TimelineCalendar(
initialDate: DateTime.now(),
firstDate: DateTime.now().subtract(const Duration(days: 365)),
lastDate: DateTime.now().add(const Duration(days: 365)),
onDateSelected: (date) => print(date),
leftMargin: 20,
activeDayColor: Colors.white,
disabledColor: Colors.black54,
activeBackgroundDayColor: Colors.black,
locale: '
pt
'
,
),
```

## Customization

You can customize the **Timeline Calendar** according to your needs. Some
examples of customization include:

- Customizing the calendar header style.
- Specifying the date range to be displayed.

## FAQ

### How do I add events to the calendar?

This feature is currently under development.

### Can I customize the calendar style?

Yes, you can customize the calendar style by providing your own style
configurations to the corresponding parameters of the `TimelineCalendar`
component.

## Contribution

Contributions are welcome! Feel free to open an issue or submit a pull request
to suggest improvements, bug fixes, or new features.

## License

This package is licensed under the [MIT](LICENSE).