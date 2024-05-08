import 'package:flutter/material.dart';

class DayItem extends StatelessWidget {
  const DayItem({
    super.key,
    required this.dayNumber,
    required this.shortName,
    required this.onTap,
    this.isSelected = false,
    this.dayColor,
    this.activeDayColor,
    this.inactiveDayNameColor,
    this.activeDayBackgroundColor,
    this.available = true,
    this.dayNameColor,
    this.shrink = false,
    this.disabledColor = Colors.white,
  });

  final int dayNumber;
  final String shortName;
  final bool isSelected;
  final Function onTap;
  final Color? dayColor;
  final Color? activeDayColor;
  final Color? inactiveDayNameColor;
  final Color? activeDayBackgroundColor;
  final bool available;
  final Color? dayNameColor;
  final bool shrink;
  final Color disabledColor;

  GestureDetector _buildDay(BuildContext context) {
    final textStyle = TextStyle(
      color: disabledColor,
      fontSize: shrink ? 14 : 32,
      fontWeight: FontWeight.normal,
      height: 0.8,
    );
    final selectedStyle = TextStyle(
      color: activeDayColor ?? disabledColor,
      fontSize: shrink ? 14 : 32,
      fontWeight: FontWeight.bold,
      height: 0.8,
    );

    return GestureDetector(
      onTap: available ? onTap as void Function()? : null,
      child: Container(
        decoration: isSelected
            ? BoxDecoration(
                color: activeDayBackgroundColor ?? Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              )
            : const BoxDecoration(color: Colors.transparent),
        height: shrink ? 40 : 70,
        width: shrink ? 33 : 60,
        child: Column(
          children: [
            Text(
              shortName,
              style: isSelected
                  ? TextStyle(
                      color: activeDayColor,
                      fontWeight: FontWeight.bold,
                      fontSize: shrink ? 9 : 14,
                    )
                  : TextStyle(
                      color: disabledColor,
                      fontWeight: FontWeight.bold,
                      fontSize: shrink ? 9 : 14,
                    ),
            ),
            const SizedBox(height: 10),
            Text(
              dayNumber.toString(),
              style: isSelected ? selectedStyle : textStyle,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildDay(context);
  }
}
