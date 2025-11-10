import 'package:nextpay/export.dart';
class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final Color? titleColor;
  final double elevation;
  final double? height;
  final TextStyle? titleStyle;
  final bool centerTitle;
  final PreferredSizeWidget? bottom;
  final Widget? leading;
  final double? leadingWidth;
  final bool automaticallyImplyLeading;

  const MyAppBar({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.onBackPressed,
    this.actions,
    this.backgroundColor,
    this.titleColor,
    this.elevation = 0,
    this.height,
    this.titleStyle,
    this.centerTitle = true,
    this.bottom,
    this.leading,
    this.leadingWidth,
    this.automaticallyImplyLeading = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor ?? ThemeColors.appBarBackground(context),
      elevation: elevation,
      centerTitle: centerTitle,
      automaticallyImplyLeading: false,
      toolbarHeight: height ?? 46,
      leadingWidth: leadingWidth ?? 46,
      leading: leading ??
          (showBackButton && automaticallyImplyLeading
              ? _buildBackButton(context)
              : null),
      title: MyText(
        text: title,
        color: titleColor ?? ThemeColors.appBarText(context),
        size: 18,
        weight: FontWeight.w600,
      ),
      actions: actions,
      bottom: bottom,
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return InkWell(
      onTap: onBackPressed ?? () => Navigator.of(context).pop(),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Icon(
          Icons.arrow_back_ios_new,
          color: ThemeColors.appBarText(context),
          size: 20,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height ?? 56);
}

// Extended version with more features
class MyAppBarExtended extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final double elevation;
  final double? height;
  final bool centerTitle;
  final Widget? leading;
  final VoidCallback? onLeadingPressed;
  final bool hasSearchBar;
  final TextEditingController? searchController;
  final Function(String)? onSearchChanged;
  final bool showDivider;

  const MyAppBarExtended({
    super.key,
    required this.title,
    this.subtitle,
    this.showBackButton = true,
    this.onBackPressed,
    this.actions,
    this.backgroundColor,
    this.elevation = 0.5,
    this.height,
    this.centerTitle = false,
    this.leading,
    this.onLeadingPressed,
    this.hasSearchBar = false,
    this.searchController,
    this.onSearchChanged,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppBar(
          backgroundColor:
              backgroundColor ?? ThemeColors.appBarBackground(context),
          elevation: elevation,
          centerTitle: centerTitle,
          automaticallyImplyLeading: false,
          toolbarHeight: height ?? (subtitle != null ? 70 : 56),
          leadingWidth: 56,
          leading: leading ??
              (showBackButton
                  ? InkWell(
                      onTap: onLeadingPressed ??
                          onBackPressed ??
                          () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Icon(
                          Icons.arrow_back_ios_new,
                          color: ThemeColors.appBarText(context),
                          size: 20,
                        ),
                      ),
                    )
                  : null),
          title: Column(
            crossAxisAlignment: centerTitle
                ? CrossAxisAlignment.center
                : CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MyText(
                text: title,
                color: ThemeColors.appBarText(context),
                size: 18,
                weight: FontWeight.w600,
              ),
              if (subtitle != null) ...[
                4.height,
                MyText(
                  text: subtitle!,
                  color: ThemeColors.subtitle(context),
                  size: 12,
                  weight: FontWeight.w400,
                ),
              ],
            ],
          ),
          actions: actions,
        ),
        if (hasSearchBar)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: _buildSearchBar(context),
          ),
        if (showDivider)
          Divider(
            color: ThemeColors.divider(context),
            height: 1,
            thickness: 0.5,
          ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return TextField(
      controller: searchController,
      onChanged: onSearchChanged,
      decoration: InputDecoration(
        hintText: 'Search...',
        hintStyle: TextStyle(color: ThemeColors.hint(context)),
        prefixIcon: Icon(
          Icons.search,
          color: ThemeColors.hint(context),
          size: 20,
        ),
        suffixIcon: searchController?.text.isNotEmpty ?? false
            ? InkWell(
                onTap: () {
                  searchController?.clear();
                  onSearchChanged?.call('');
                },
                child: Icon(
                  Icons.close,
                  color: ThemeColors.hint(context),
                  size: 20,
                ),
              )
            : null,
        filled: true,
        fillColor: ThemeColors.inputBackground(context),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: ThemeColors.inputBorder(context),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: ThemeColors.inputBorder(context),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: ThemeColors.focused(context),
            width: 1.5,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  @override
  Size get preferredSize {
    double baseHeight = height ?? (subtitle != null ? 70 : 56);
    if (hasSearchBar) baseHeight += 56;
    if (showDivider) baseHeight += 1;
    return Size.fromHeight(baseHeight);
  }
}