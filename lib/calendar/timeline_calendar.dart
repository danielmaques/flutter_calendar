import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:timeline_calendar/extension/string_extension.dart';

import '../calendar_items/day_item.dart';
import '../calendar_items/year_item.dart';

typedef OnDateSelected = void Function(DateTime);

class TimelineCalendar extends StatefulWidget {
  TimelineCalendar({
    super.key,
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    required this.onDateSelected,
    this.selectableDayPredicate,
    this.leftMargin = 0,
    this.dayColor,
    this.activeDayColor,
    this.disabledColor = Colors.white,
    this.inactiveDayNameColor,
    this.activeBackgroundDayColor,
    this.monthColor,
    this.dayNameColor,
    this.shrink = false,
    this.locale,
    this.showYears = false,
  })  : assert(
          initialDate.difference(firstDate).inDays >= 0,
          'initialDate must be on or after firstDate',
        ),
        assert(
          !initialDate.isAfter(lastDate),
          'initialDate must be on or before lastDate',
        ),
        assert(
          !firstDate.isAfter(lastDate),
          'lastDate must be on or after firstDate',
        ),
        assert(
          selectableDayPredicate == null || selectableDayPredicate(initialDate),
          'Provided initialDate must satisfy provided selectableDayPredicate',
        ),
        assert(
          locale == null || dateTimeSymbolMap().containsKey(locale),
          "Provided locale value doesn't exist",
        );
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final SelectableDayPredicate? selectableDayPredicate;
  final OnDateSelected onDateSelected;
  final double leftMargin;
  final Color? dayColor;
  final Color? activeDayColor;
  final Color disabledColor;
  final Color? inactiveDayNameColor;
  final Color? activeBackgroundDayColor;
  final Color? monthColor;
  final Color? dayNameColor;
  final bool shrink;
  final String? locale;

  /// If true, it will show a separate row for the years.
  /// It defaults to false
  final bool showYears;

  @override
  State<TimelineCalendar> createState() => _TimelineCalendarState();
}

class _TimelineCalendarState extends State<TimelineCalendar> {
  final ItemScrollController _controllerYear = ItemScrollController();
  final ItemScrollController _controllerMonth = ItemScrollController();
  final ItemScrollController _controllerDay = ItemScrollController();

  int? _yearSelectedIndex;
  int? _monthSelectedIndex;
  int? _daySelectedIndex;
  late double _scrollAlignment;

  final List<DateTime> _years = [];
  final List<DateTime> _months = [];
  final List<DateTime> _days = [];
  late DateTime _selectedDate;

  late String _locale;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initCalendar();
  }

  @override
  void didUpdateWidget(TimelineCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialDate != _selectedDate ||
        widget.showYears != oldWidget.showYears) {
      _initCalendar();
    }
  }

  void _initCalendar() {
    _locale = widget.locale ?? Localizations.localeOf(context).languageCode;
    initializeDateFormatting(_locale);
    _selectedDate = widget.initialDate;
    if (widget.showYears) {
      _generateYears();
      _selectedYearIndex();
      _moveToYearIndex(_yearSelectedIndex ?? 0);
    }
    _generateMonths(_selectedDate);
    _selectedMonthIndex();
    _moveToMonthIndex(_monthSelectedIndex ?? 0);
    _generateDays(_selectedDate);
    _selectedDayIndex();
    _moveToDayIndex(_daySelectedIndex ?? 0);
  }

  void _generateYears() {
    _years.clear();
    var date = widget.firstDate;
    while (date.isBefore(widget.lastDate)) {
      _years.add(date);
      date = DateTime(date.year + 1);
    }
  }

  void _generateMonths(DateTime? selectedDate) {
    _months.clear();
    if (widget.showYears) {
      final month = selectedDate!.year == widget.firstDate.year
          ? widget.firstDate.month
          : 1;
      var date = DateTime(selectedDate.year, month);
      while (date.isBefore(DateTime(selectedDate.year + 1)) &&
          date.isBefore(widget.lastDate)) {
        _months.add(date);
        date = DateTime(date.year, date.month + 1);
      }
    } else {
      var date = DateTime(widget.firstDate.year, widget.firstDate.month);
      while (date.isBefore(widget.lastDate)) {
        _months.add(date);
        date = DateTime(date.year, date.month + 1);
      }
    }
  }

  void _generateDays(DateTime? selectedDate) {
    _days.clear();
    for (var i = 1; i <= 31; i++) {
      final day = DateTime(selectedDate!.year, selectedDate.month, i);
      if (day.difference(widget.firstDate).inDays < 0) continue;
      if (day.month != selectedDate.month || day.isAfter(widget.lastDate)) {
        break;
      }
      _days.add(day);
    }
  }

  void _selectedYearIndex() {
    _yearSelectedIndex = _years.indexOf(
      _years.firstWhere((yearDate) => yearDate.year == _selectedDate.year),
    );
  }

  void _selectedMonthIndex() {
    if (widget.showYears) {
      _monthSelectedIndex = _months.indexOf(
        _months
            .firstWhere((monthDate) => monthDate.month == _selectedDate.month),
      );
    } else {
      _monthSelectedIndex = _months.indexOf(
        _months.firstWhere(
          (monthDate) =>
              monthDate.year == _selectedDate.year &&
              monthDate.month == _selectedDate.month,
        ),
      );
    }
  }

  void _selectedDayIndex() {
    _daySelectedIndex = _days.indexOf(
      _days.firstWhere((dayDate) => dayDate.day == _selectedDate.day),
    );
  }

  /// Scroll to index year
  void _moveToYearIndex(int index) {
    if (_controllerYear.isAttached) {
      _controllerYear.scrollTo(
        index: index,
        alignment: _scrollAlignment,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeIn,
      );
    }
  }

  /// Scroll to index month
  void _moveToMonthIndex(int index) {
    if (_controllerMonth.isAttached) {
      _controllerMonth.scrollTo(
        index: index,
        alignment: _scrollAlignment,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeIn,
      );
    }
  }

  /// Scroll to index day
  void _moveToDayIndex(int index) {
    if (_controllerDay.isAttached) {
      _controllerDay.scrollTo(
        index: index,
        alignment: _scrollAlignment,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeIn,
      );
    }
  }

  void _onSelectDay(int index) {
    // Move to selected day
    _daySelectedIndex = index;
    _moveToDayIndex(index);
    setState(() {});

    // Notify to callback
    _selectedDate = _days[index];
    widget.onDateSelected(_selectedDate);
  }

  bool _isSelectedDay(int index) =>
      _monthSelectedIndex != null &&
      (index == _daySelectedIndex || index == _indexOfDay(_selectedDate));

  int _indexOfDay(DateTime date) {
    try {
      return _days.indexOf(
        _days.firstWhere(
          (dayDate) =>
              dayDate.day == date.day &&
              dayDate.month == date.month &&
              dayDate.year == date.year,
        ),
      );
    } catch (_) {
      return -1;
    }
  }

  @override
  Widget build(BuildContext context) {
    _scrollAlignment = widget.leftMargin / MediaQuery.of(context).size.width;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (widget.showYears)
          // _buildYearList(),
          _buildMonthList(),
        _buildDayList(),
      ],
    );
  }

  Widget _buildMonthList() {
    return SizedBox(
      height: 30,
      child: ScrollablePositionedList.builder(
        initialScrollIndex: _monthSelectedIndex ?? 0,
        initialAlignment: _scrollAlignment,
        itemScrollController: _controllerMonth,
        padding: EdgeInsets.only(left: widget.leftMargin),
        scrollDirection: Axis.horizontal,
        itemCount: _months.length,
        itemBuilder: (BuildContext context, int index) {
          final currentDate = _months[index];
          final monthName = DateFormat.MMMM(_locale).format(currentDate);

          return Padding(
            padding: const EdgeInsets.only(right: 12, left: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                if (widget.firstDate.year != currentDate.year &&
                    currentDate.month == 1 &&
                    !widget.showYears)
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: YearItem(
                      name: DateFormat.y(_locale).format(currentDate),
                      color: widget.monthColor,
                      onTap: () {},
                      shrink: widget.shrink,
                    ),
                  ),
                if (index == _months.length - 1)
                  // Last element to take space to do scroll to left side
                  SizedBox(
                    width: MediaQuery.of(context).size.width -
                        widget.leftMargin -
                        (monthName.length * 10),
                  )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDayList() {
    return SizedBox(
      key: const Key('ScrollableDayList'),
      height: 70,
      child: ScrollablePositionedList.builder(
        itemScrollController: _controllerDay,
        initialScrollIndex: _daySelectedIndex ?? 0,
        initialAlignment: _scrollAlignment,
        scrollDirection: Axis.horizontal,
        itemCount: _days.length,
        padding: EdgeInsets.only(left: widget.leftMargin, right: 6),
        itemBuilder: (BuildContext context, int index) {
          final currentDay = _days[index];
          final shortName =
              DateFormat.E(_locale).format(currentDay).capitalize();
          return Row(
            children: <Widget>[
              DayItem(
                isSelected: _isSelectedDay(index),
                dayNumber: currentDay.day,
                shortName: shortName.length > 3
                    ? shortName.substring(0, 3)
                    : shortName,
                onTap: () => _onSelectDay(index),
                available: widget.selectableDayPredicate == null ||
                    widget.selectableDayPredicate!(currentDay),
                dayColor: widget.dayColor,
                activeDayColor: widget.activeDayColor,
                disabledColor: widget.disabledColor,
                inactiveDayNameColor: widget.inactiveDayNameColor,
                activeDayBackgroundColor: widget.activeBackgroundDayColor,
                dayNameColor: widget.dayNameColor,
                shrink: widget.shrink,
              ),
              if (index == _days.length - 1)
                // Last element to take space to do scroll to left side
                SizedBox(
                  width: MediaQuery.of(context).size.width -
                      widget.leftMargin -
                      65,
                )
            ],
          );
        },
      ),
    );
  }
}
