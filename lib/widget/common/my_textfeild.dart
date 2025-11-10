import 'package:nextpay/export.dart';

class MyTextField extends StatefulWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final bool? isObSecure;
  final bool? haveLabel;
  final bool? isReadOnly;
  final double? marginBottom;
  final double? radius;
  final int? maxLines;
  final double? labelSize;
  final double? hintsize;
  final FocusNode? focusNode;
  final Color? filledColor;
  final Color? focusedFillColor;
  final bool? autoFocus;
  final Color? bordercolor;
  final Color? hintColor;
  final Color? labelColor;
  final Color? focusBorderColor;
  final Widget? prefix;
  final Widget? suffix;
  final FontWeight? labelWeight;
  final FontWeight? hintWeight;
  final VoidCallback? onTap;
  final TextInputType? keyboardType;
  final double? height;
  final double? width;
  final String? Function(String?)? validator;
  final bool? showPasswordToggle;
  final bool? isPin;
  final List<TextInputFormatter>? inputFormatters;
  final String? obscuringCharacter;
  final TextStyle? style;
  final TextAlign? textAlign;

  const MyTextField({
    super.key,
    this.controller,
    this.hint,
    this.label,
    this.onChanged,
    this.isObSecure = false,
    this.marginBottom = 18.0,
    this.maxLines = 1,
    this.filledColor,
    this.focusedFillColor,
    this.hintColor,
    this.labelColor,
    this.haveLabel = true,
    this.labelSize,
    this.hintsize,
    this.prefix,
    this.suffix,
    this.autoFocus = false,
    this.labelWeight,
    this.hintWeight,
    this.keyboardType,
    this.isReadOnly = false,
    this.onTap,
    this.bordercolor,
    this.focusBorderColor,
    this.focusNode,
    this.radius = 18.0,
    this.height = 56,
    this.width,
    this.validator,
    this.showPasswordToggle = false,
    this.isPin = false,
    this.inputFormatters,
    this.obscuringCharacter = '•',
    this.style,
    this.textAlign,
  });

  @override
  State<MyTextField> createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {
  bool _isFocused = false;
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode?.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() => _isFocused = widget.focusNode?.hasFocus ?? false);
  }

  @override
  void dispose() {
    widget.focusNode?.removeListener(_onFocusChange);
    super.dispose();
  }

  Widget _buildPasswordToggle(BuildContext context) {
    return IconButton(
      icon: Icon(
        _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
        color: ThemeColors.inputHint(context),
        size: 20,
      ),
      onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
    );
  }

  @override
  Widget build(BuildContext context) {
    final defaultFilledColor = ThemeColors.inputBackground(context);
    final defaultFocusedFillColor = ThemeColors.inputBackground(context);
    // final defaultBorderColor = ThemeColors.inputBorder(context);
    final defaultFocusBorderColor = ThemeColors.focused(context);
    final defaultHintColor = ThemeColors.inputHint(context);
    final defaultLabelColor = ThemeColors.hint(context);
    final defaultTextColor = ThemeColors.text(context);
    final defaultErrorColor = ThemeColors.error(context);

    return Padding(
      padding: EdgeInsets.only(bottom: widget.marginBottom ?? 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.label != null && widget.haveLabel == true)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: MyText(
                text: widget.label ?? '',
                size: widget.labelSize ?? 14,
                color: widget.labelColor ?? defaultLabelColor,
                weight: widget.labelWeight ?? FontWeight.w600,
              ),
            ),
          Container(
            width: widget.width ?? double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.radius ?? 12.0),
              color: _isFocused
                  ? widget.focusedFillColor ?? defaultFocusedFillColor
                  : widget.filledColor ?? defaultFilledColor,
            ),
            child: TextFormField(
              focusNode: widget.focusNode,
              onTap: widget.onTap,
              textAlignVertical: TextAlignVertical.center,
              keyboardType: widget.isPin == true
                  ? TextInputType.number
                  : widget.keyboardType,
              inputFormatters: widget.isPin == true
                  ? [
                      LengthLimitingTextInputFormatter(1),
                      FilteringTextInputFormatter.digitsOnly,
                    ]
                  : widget.inputFormatters,
              obscureText: (widget.isObSecure ?? false) && !_isPasswordVisible,
              obscuringCharacter: widget.obscuringCharacter ?? '•',
              textAlign: widget.textAlign ?? TextAlign.start,
              style:
                  widget.style ??
                  TextStyle(
                    fontSize: widget.isPin == true ? 18 : 16,
                    fontWeight: widget.isPin == true
                        ? FontWeight.bold
                        : FontWeight.w500,
                    color: defaultTextColor,
                  ),
              maxLines: widget.maxLines ?? 1,
              readOnly: widget.isReadOnly ?? false,
              controller: widget.controller,
              autofocus: widget.autoFocus ?? false,
              onTapOutside: (_) =>
                  FocusManager.instance.primaryFocus?.unfocus(),
              onChanged: widget.onChanged,
              validator: widget.validator,
              decoration: InputDecoration(
                filled: true,
                fillColor: _isFocused
                    ? widget.focusedFillColor ?? defaultFocusedFillColor
                    : widget.filledColor ?? defaultFilledColor,
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(widget.radius ?? 12.0),
                  borderSide: BorderSide(
                    color: widget.focusBorderColor ?? defaultFocusBorderColor,
                    width: 2,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(widget.radius ?? 12.0),
                  // borderSide: BorderSide(
                  //   color: widget.bordercolor ?? defaultBorderColor,
                  //   width: 1,
                  // ),
                ),
                prefixIcon: widget.prefix != null
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: widget.prefix,
                      )
                    : null,
                prefixIconConstraints: const BoxConstraints(
                  minWidth: 40,
                  minHeight: 40,
                ),
                suffixIcon: widget.showPasswordToggle == true
                    ? _buildPasswordToggle(context)
                    : widget.suffix != null
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: widget.suffix,
                      )
                    : null,
                suffixIconConstraints: const BoxConstraints(
                  minWidth: 40,
                  minHeight: 40,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                hintText: widget.hint,
                hintStyle: TextStyle(
                  fontSize: widget.hintsize ?? 14,
                  color: widget.hintColor ?? defaultHintColor,
                  fontWeight: widget.hintWeight ?? FontWeight.w400,
                ),
                errorStyle: const TextStyle(
                  height: 0,
                  fontSize: 0,
                ), // key change
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(widget.radius ?? 12.0),
                  borderSide: BorderSide(width: 1.5, color: defaultErrorColor),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(widget.radius ?? 12.0),
                  borderSide: BorderSide(width: 2, color: defaultErrorColor),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ========== CONVENIENCE CONSTRUCTORS ==========

extension MyTextFieldPresets on MyTextField {
  // Email field
  static MyTextField email({
    BuildContext? context,
    TextEditingController? controller,
    String? hint = 'Email address',
    ValueChanged<String>? onChanged,
    String? Function(String?)? validator,
  }) => MyTextField(
    controller: controller,
    label: 'Email',
    hint: hint,
    keyboardType: TextInputType.emailAddress,
    onChanged: onChanged,
    validator: validator,
    prefix: SvgPicture.asset(
      Assets.emailfilled,
      height: 16.0,
      color: context?.icon,
    ),
    showPasswordToggle: false,
  );

  // Password field
  static MyTextField password({
    BuildContext? context,
    TextEditingController? controller,
    String? hint = 'Password',
    ValueChanged<String>? onChanged,
    String? Function(String?)? validator,
    bool showToggle = true,
  }) => MyTextField(
    controller: controller,
    label: 'Password',
    hint: hint,
    isObSecure: true,
    showPasswordToggle: showToggle,
    onChanged: onChanged,
    validator: validator,
    prefix: SvgPicture.asset(
      Assets.lockfilled,
      height: 16.0,
      color: context?.icon,
    ),
  );

  // Search field
  static MyTextField search({
    BuildContext? context,
    TextEditingController? controller,
    String? hint = 'Search...',
    ValueChanged<String>? onChanged,
  }) => MyTextField(
    controller: controller,
    hint: hint,
    onChanged: onChanged,
    haveLabel: false,
    prefix: SvgPicture.asset(
      Assets.searchunfilled,
      height: 16.0,
      color: context?.icon,
    ),
  );

  // Name field
  static MyTextField name({
    BuildContext? context,
    TextEditingController? controller,
    String? hint = 'Full name',
    ValueChanged<String>? onChanged,
    String? Function(String?)? validator,
  }) => MyTextField(
    controller: controller,
    label: 'Full Name',
    hint: hint,
    keyboardType: TextInputType.name,
    onChanged: onChanged,
    validator: validator,
    prefix: SvgPicture.asset(
      Assets.personfilled,
      height: 16.0,
      color: context?.icon,
    ),
  );

  // Phone field
  static MyTextField phone({
    BuildContext? context,
    TextEditingController? controller,
    String? hint = 'Phone number',
    ValueChanged<String>? onChanged,
    String? Function(String?)? validator,
  }) => MyTextField(
    controller: controller,
    label: 'Phone',
    hint: hint,
    keyboardType: TextInputType.phone,
    onChanged: onChanged,
    validator: validator,
    prefix: SvgPicture.asset(
      Assets.phonefilled,
      height: 16.0,
      color: context?.icon,
    ),
  );

  // Multiline field
  static MyTextField multiline({
    BuildContext? context,
    TextEditingController? controller,
    String? label = 'Message',
    String? hint = 'Write something...',
    ValueChanged<String>? onChanged,
    String? Function(String?)? validator,
    int maxLines = 4,
  }) => MyTextField(
    controller: controller,
    label: label,
    hint: hint,
    maxLines: maxLines,
    keyboardType: TextInputType.multiline,
    onChanged: onChanged,
    validator: validator,
  );

  // PIN field
  static MyTextField pin({
    BuildContext? context,
    TextEditingController? controller,
    String? hint = '0',
    ValueChanged<String>? onChanged,
    String? Function(String?)? validator,
  }) => MyTextField(
    controller: controller,
    hint: hint,
    isPin: true,
    haveLabel: false,
    keyboardType: TextInputType.number,
    onChanged: onChanged,
    validator: validator,
    textAlign: TextAlign.center,
  );

  // Amount field
  static MyTextField amount({
    BuildContext? context,
    TextEditingController? controller,
    String? hint = '0.00',
    ValueChanged<String>? onChanged,
    String? Function(String?)? validator,
  }) => MyTextField(
    controller: controller,
    label: 'Amount',
    hint: hint,
    keyboardType: TextInputType.numberWithOptions(decimal: true),
    onChanged: onChanged,
    validator: validator,
    prefix: SvgPicture.asset(Assets.money, height: 16.0, color: context?.icon),
  );
}
