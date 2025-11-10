import 'package:flutter/material.dart';
import 'package:nextpay/export.dart';

class CustomCheckbox extends StatefulWidget {
  final String? text;
  final String? text2;
  final Color? textColor;
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? borderColor;
  final Color? checkColor;
  final Function(bool) onChanged;
  final bool? value;
  final bool useThemeColors;

  const CustomCheckbox({
    super.key,
    this.text,
    this.text2,
    this.textColor,
    this.activeColor,
    this.inactiveColor,
    this.borderColor,
    this.checkColor,
    required this.onChanged,
    this.value,
    this.useThemeColors = true,
  });

  @override
  _CustomCheckboxState createState() => _CustomCheckboxState();
}

class _CustomCheckboxState extends State<CustomCheckbox> {
  late bool _isChecked;

  @override
  void initState() {
    super.initState();
    _isChecked = widget.value ?? false;
  }

  @override
  void didUpdateWidget(CustomCheckbox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != null && widget.value != _isChecked) {
      setState(() {
        _isChecked = widget.value!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    /// Resolve colors using theme system
    final Color activeColor = widget.useThemeColors 
        ? context.primary
        : widget.activeColor ?? AppColors.primary;
    
    final Color inactiveColor = widget.useThemeColors
        ? context.surface
        : widget.inactiveColor ?? AppColors.surface;
    
    final Color borderColor = widget.useThemeColors
        ? context.border
        : widget.borderColor ?? AppColors.borderLight;
    
    final Color textColor = widget.useThemeColors
        ? context.text
        : widget.textColor ?? AppColors.textPrimary;
    
    final Color checkColor = widget.useThemeColors
        ? context.buttonText
        : widget.checkColor ?? Colors.white;

    final checkbox = Bounce(
      onTap: () {
        setState(() {
          _isChecked = !_isChecked;
        });
        widget.onChanged(_isChecked);
      },
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          color: _isChecked ? activeColor : inactiveColor,
          border: Border.all(
            color: _isChecked ? activeColor : borderColor,
            width: 1.5,
          ),
          boxShadow: _isChecked ? [
            BoxShadow(
              color: activeColor.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: _isChecked
            ? Icon(
                Icons.check,
                color: checkColor,
                size: 16,
              )
            : null,
      ),
    );

    // Build text widget with proper theme styling
    Widget? textWidget;
    if (widget.text != null || widget.text2 != null) {
      textWidget = Text.rich(
        TextSpan(
          children: [
            if (widget.text != null)
              TextSpan(
                text: widget.text,
                style: TextStyle(
                  fontSize: 14,
                  color: textColor,
                  fontWeight: FontWeight.w400,
                  height: 1.4,
                ),
              ),
            if (widget.text2 != null)
              TextSpan(
                text: widget.text2,
                style: TextStyle(
                  fontSize: 14,
                  color: textColor,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
              ),
          ],
        ),
        textAlign: TextAlign.start,
      );
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _isChecked = !_isChecked;
        });
        widget.onChanged(_isChecked);
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            checkbox,
            if (textWidget != null) ...[
              const SizedBox(width: 12),
              Expanded(
                child: textWidget,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Simplified version for common use cases
class ThemeCheckbox extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final String? secondaryText;

  const ThemeCheckbox({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.secondaryText,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCheckbox(
      text: label,
      text2: secondaryText,
      value: value,
      onChanged: onChanged,
      useThemeColors: true,
    );
  }
}