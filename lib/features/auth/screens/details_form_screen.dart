// details_form_screen.dart
import 'dart:io';

import 'package:nextpay/core/navigation/navigate.dart';
import 'package:nextpay/core/navigation/route_transition.dart';
import 'package:nextpay/export.dart';
import 'package:nextpay/features/auth/screens/doc_scan_screen.dart';
import 'package:nextpay/features/screens/home/home_screen.dart';
import 'package:nextpay/providers/verification_provider.dart';
import 'package:country_pickers/country.dart';
import 'package:country_pickers/country_pickers.dart';
import 'package:nextpay/widget/common/dot-loader.dart';

class DetailsFormScreen extends StatefulWidget {
  const DetailsFormScreen({super.key});

  @override
  State<DetailsFormScreen> createState() => _DetailsFormScreenState();
}

class _DetailsFormScreenState extends State<DetailsFormScreen> {
  final PageController _pageController = PageController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _idNumberController = TextEditingController();
  final TextEditingController _countrySearchController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    final provider = context.read<VerificationProvider>();
    _fullNameController.text = provider.verificationData.fullName ?? '';
    _idNumberController.text = provider.verificationData.idNumber ?? '';

    _fullNameController.addListener(() {
      provider.updateFullName(_fullNameController.text);
    });

    _idNumberController.addListener(() {
      provider.updateIdNumber(_idNumberController.text);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fullNameController.dispose();
    _idNumberController.dispose();
    _countrySearchController.dispose();
    super.dispose();
  }

  void _nextStep() async {
    final provider = context.read<VerificationProvider>();

    if (!provider.canGoNext()) {
      final errorMessage = provider.getStepValidationMessage(
        provider.currentStep,
      );
      AppToast.show(
        errorMessage ?? 'Please complete this step',
        context,
        type: ToastType.error,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    // Move to next step normally
    if (provider.currentStep < provider.totalSteps - 1) {
      provider.nextStep();
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeVerification();
    }
  }

  void _previousStep() {
    final provider = context.read<VerificationProvider>();
    if (provider.currentStep > 0) {
      provider.previousStep();
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  Future<void> _completeVerification() async {
    final provider = context.read<VerificationProvider>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            NextPayLoader(),
            16.height,
            MyText(
              text: 'Verifying your information...',
              size: 18.0,
              color: context.text,
            ),
          ],
        ),
      ),
    );

    final success = await provider.submitVerification();

    if (!mounted) return;
    Navigator.of(context).pop();

    if (success) {
      Navigate.to(
        context: context,
        page: const HomeScreen(),
        transition: RouteTransition.rightToLeft,
      );
    } else {
      AppToast.show(
        provider.errorMessage ?? 'Verification failed. Please try again.',
        context,
        type: ToastType.error,
        duration: const Duration(seconds: 2),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<VerificationProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: context.scaffoldBackground,
          appBar: MyAppBar(
            title: provider.getAppBarTitle(),
            onBackPressed: _previousStep,
            centerTitle: false,
            showBackButton: true,
          ),
          body: Column(
            children: [
              // Progress Indicator
              _buildProgressIndicator(provider),

              // Form Content
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildAccountTypeStep(provider),
                    _buildNameStep(provider),
                    _buildCountryStep(provider),
                    _buildIdTypeSelectionStep(
                      provider,
                    ), // Step 3: Only ID type selection
                    _buildIdCaptureStep(provider), // Step 4: Capture ID
                    _buildSelfieWithIdStep(provider), // Step 5: Selfie with ID
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: provider.shouldShowButton
              ? _buildBottomButton(provider)
              : null,
        );
      },
    );
  }

  Widget _buildProgressIndicator(VerificationProvider provider) {
    return Container(
      padding: AppSizes.DEFAULT,
      child: Column(
        children: [
          // Progress Text
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              MyText(
                text:
                    'Step ${provider.currentStep + 1} of ${provider.totalSteps}',
                color: context.primary,
                size: 12.0,
                weight: FontWeight.w600,
              ),
              MyText(
                text:
                    '${((provider.currentStep + 1) / provider.totalSteps * 100).round()}% Complete',
                color: context.subtitle,
                size: 14.0,
              ),
            ],
          ),
          12.height,
          // Linear Progress Bar
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: context.card,
              borderRadius: BorderRadius.circular(6.0),
            ),
            child: Stack(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  height: 6,
                  width:
                      MediaQuery.of(context).size.width *
                      provider.progressValue,
                  decoration: BoxDecoration(
                    color: context.primary,
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton(VerificationProvider provider) {
    return Container(
      padding: const EdgeInsets.all(24),
      color: context.scaffoldBackground,
      child: MyButton(
        buttonText: provider.getButtonText(),
        onTap: _nextStep,
        mHoriz: 0,
        isLoading: provider.isLoading,
      ),
    );
  }

  // Step 1: Account Type Selection
  Widget _buildAccountTypeStep(VerificationProvider provider) {
    return SingleChildScrollView(
      padding: AppSizes.DEFAULT,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          20.height,
          MyText(
            text: 'What kind of account do you want to open?',
            color: context.text,
            size: 24.0,
            weight: FontWeight.bold,
          ),
          12.height,
          MyText(
            text: 'You can always add another account later.',
            color: context.subtitle,
            size: 16.0,
          ),
          32.height,
          // Personal Account Card
          _buildAccountTypeCard(
            icon: Icons.person,
            title: 'Personal Account',
            description:
                'Shop, send and receive money around the world at lower costs.',
            isSelected: provider.verificationData.accountType == 'Personal',
            onTap: () {
              provider.updateAccountType('Personal');
              Future.delayed(const Duration(milliseconds: 300), _nextStep);
            },
          ),
          16.height,
          // Business Account Card
          _buildAccountTypeCard(
            icon: Icons.business,
            title: 'Business Account',
            description: 'Grow your business with more advanced features.',
            isSelected: provider.verificationData.accountType == 'Business',
            onTap: () {
              provider.updateAccountType('Business');
              Future.delayed(const Duration(milliseconds: 300), _nextStep);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAccountTypeCard({
    required IconData icon,
    required String title,
    required String description,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: AppSizes.CARD_PADDING,
        decoration: BoxDecoration(
          color: isSelected ? context.primary.withOpacity(0.1) : context.card,
          border: Border.all(
            color: isSelected ? context.primary : context.border,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(30.0),
        ),
        child: Row(
          children: [
            Container(
              padding: AppSizes.CARD_PADDING,
              decoration: BoxDecoration(
                color: context.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(30.0),
              ),
              child: Icon(icon, color: context.primary, size: 24.0),
            ),
            16.width,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyText(
                    text: title,
                    color: context.text,
                    size: 18.0,
                    weight: FontWeight.w600,
                  ),
                  8.height,
                  MyText(
                    text: description,
                    color: context.subtitle,
                    size: 14.0,
                    maxLines: 3,
                  ),
                ],
              ),
            ),
            8.width,
            SvgPicture.asset(
              Assets.arrowforward,
              height: 16.0,
              color: context.icon,
            ),
          ],
        ),
      ),
    );
  }

  // Step 2: Full Name
  Widget _buildNameStep(VerificationProvider provider) {
    return SingleChildScrollView(
      padding: AppSizes.DEFAULT,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          20.height,
          MyText(
            text: 'What is your name?',
            color: context.text,
            size: 24.0,
            weight: FontWeight.bold,
          ),
          12.height,
          MyText(
            text: 'Enter your full legal name according to the identity card.',
            color: context.subtitle,
            size: 16.0,
          ),
          32.height,
          MyText(
            text: 'Full Name',
            color: context.text,
            size: 14.0,
            weight: FontWeight.w600,
          ),
          8.height,
          MyTextField(
            controller: _fullNameController,
            hint: 'Andrew Ainsley',
            prefix: SvgPicture.asset(
              Assets.personfilled,
              height: 16.0,
              color: context.icon,
            ),
          ),
        ],
      ),
    );
  }

  // Step 3: Country Selection
  Widget _buildCountryStep(VerificationProvider provider) {
    return Padding(
      padding: AppSizes.DEFAULT,
      child: Column(
        children: [
          12.height,
          MyText(
            text:
                'Enter your full Country name according to the identity card.',
            color: context.subtitle,
            size: 16.0,
          ),
          10.height, // Search Field
          MyTextField(
            hint: 'Canada',
            prefix: SvgPicture.asset(
              Assets.globe,
              height: 16.0,
              color: context.primary,
            ),
            controller: _countrySearchController,
            onChanged: (value) => setState(() {}),
            keyboardType: TextInputType.text,
          ),

          // Countries List
          Expanded(
            child: Consumer<VerificationProvider>(
              builder: (context, provider, child) {
                final searchedCountries = _countrySearchController.text.isEmpty
                    ? provider.countries
                    : provider.searchCountries(_countrySearchController.text);

                return ListView.builder(
                  itemCount: searchedCountries.length,
                  itemBuilder: (context, index) {
                    final country = searchedCountries[index];
                    return _buildCountryItem(country, provider);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountryItem(Country country, VerificationProvider provider) {
    final isSelected =
        provider.verificationData.country?.isoCode == country.isoCode;

    return GestureDetector(
      onTap: () => provider.updateCountry(country),
      child: Container(
        padding: AppSizes.CARD_PADDING,
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: context.border)),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? context.primary : context.subtitle,
                  width: 2,
                ),
                color: isSelected ? context.primary : Colors.transparent,
              ),
              child: isSelected
                  ? SvgPicture.asset(
                      Assets.check,
                      height: 12,
                      color: Colors.white,
                    )
                  : null,
            ),
            16.width,
            CountryPickerUtils.getDefaultFlagImage(country),
            12.width,
            Expanded(
              child: MyText(
                text: country.name,
                color: context.text,
                size: 16,
                weight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Step 3: ID Type Selection Only
  Widget _buildIdTypeSelectionStep(VerificationProvider provider) {
    return SingleChildScrollView(
      padding: AppSizes.DEFAULT,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          20.height,
          MyText(
            text: 'Select ID Type',
            color: context.text,
            size: 24,
            weight: FontWeight.bold,
          ),
          12.height,
          MyText(
            text:
                'Choose the type of identification document you will use for verification.',
            color: context.subtitle,
            size: 16,
          ),
          32.height,
          // ID Type Selection
          ...provider.idTypes.map(
            (idType) => _buildIdTypeItem(idType, provider),
          ),
        ],
      ),
    );
  }

  Widget _buildIdTypeItem(String idType, VerificationProvider provider) {
    final isSelected = provider.verificationData.idType == idType;

    return GestureDetector(
      onTap: () => provider.updateIdType(idType),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? context.primary.withOpacity(0.1) : context.card,
          border: Border.all(
            color: isSelected ? context.primary : context.border,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(30.0),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? context.primary : context.subtitle,
                  width: 2,
                ),
                color: isSelected ? context.primary : Colors.transparent,
              ),
              child: isSelected
                  ? SvgPicture.asset(
                      Assets.check,
                      color: Colors.white,
                      height: 16.0,
                    )
                  : null,
            ),
            16.width,
            MyText(
              text: idType,
              color: context.text,
              size: 16,
              weight: FontWeight.w500,
            ),
          ],
        ),
      ),
    );
  }

  // Step 4: ID Capture Step
  Widget _buildIdCaptureStep(VerificationProvider provider) {
    return SingleChildScrollView(
      padding: AppSizes.DEFAULT,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          20.height,
          MyText(
            text: 'Capture Your ${provider.verificationData.idType ?? 'ID'}',
            color: context.text,
            size: 24,
            weight: FontWeight.bold,
          ),
          12.height,
          MyText(
            text:
                'Capture both front and back sides of your ${provider.verificationData.idType?.toLowerCase() ?? 'ID'}',
            color: context.subtitle,
            size: 16,
          ),
          32.height,
          // ID Front Capture
          _buildIdCaptureCard(
            title: 'Front Side',
            imagePath: provider.verificationData.idFrontImagePath,
            onTap: () async {
              final imagePath = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ScanScreen(
                    title: 'Capture ${provider.verificationData.idType} Front',
                    isSelfie: false,
                  ),
                ),
              );
              if (imagePath != null) {
                provider.updateIdFrontImage(imagePath);
              }
            },
          ),

          24.height,
          // ID Back Capture
          _buildIdCaptureCard(
            title: 'Back Side',
            imagePath: provider.verificationData.idBackImagePath,
            onTap: () async {
              final imagePath = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ScanScreen(
                    title: 'Capture ${provider.verificationData.idType} Back',
                    isSelfie: false,
                  ),
                ),
              );
              if (imagePath != null) {
                provider.updateIdBackImage(imagePath);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildIdCaptureCard({
    required String title,
    required String? imagePath,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyText(
          text: title,
          color: context.text,
          size: 14,
          weight: FontWeight.w600,
        ),
        8.height,
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              color: context.card,
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(
                color: imagePath != null ? context.primary : context.border,
                width: imagePath != null ? 2 : 1,
              ),
            ),
            child: imagePath != null && File(imagePath).existsSync()
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(18.0),
                    child: Image.file(File(imagePath), fit: BoxFit.cover),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        Assets.camera,
                        color: context.icon,
                        height: 30.0,
                      ),
                      8.height,
                      MyText(
                        text: 'Tap to Capture $title',
                        color: context.subtitle,
                        size: 14.0,
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  // Step 5: Selfie with ID Step
  Widget _buildSelfieWithIdStep(VerificationProvider provider) {
    return SingleChildScrollView(
      padding: AppSizes.DEFAULT,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          MyText(
            text: 'Take Selfie with ${provider.verificationData.idType}',
            color: context.text,
            size: 18.0,
            weight: FontWeight.bold,
          ),
          12.height,
          
          // // Instructions
          // Container(
          //   padding: AppSizes.DEFAULT,
          //   decoration: BoxDecoration(
          //     color: context.primary.withOpacity(0.1),
          //     borderRadius: BorderRadius.circular(16.0),
          //   ),
          //   child: Column(
          //     children: [
          //       SvgPicture.asset(
          //         Assets.info,
          //         color: context.icon,
          //         height: 16.0,
          //       ),
          //       8.height,
          //       MyText(
          //         text:
          //             'Make sure:\n• Your face is clearly visible\n• ${provider.verificationData.idType} is readable\n• Both are in the frame',
          //         color: context.text,
          //         size: 16.0,
          //         textAlign: TextAlign.center,
          //       ),
          //     ],
          //   ),
          // ),
          // 24.height,
          // Display captured selfie
if (provider.verificationData.selfieWithIdImagePath != null)
  Container(
    width: 200, // Width of oval
    height: 250, // Height of oval
    decoration: BoxDecoration(
      shape: BoxShape.circle, // For perfect circle
      border: Border.all(color: context.primary, width: 2),
      // If you want an oval instead of circle, use borderRadius:
      // borderRadius: BorderRadius.circular(125),
    ),
    child: ClipOval(
      child: Image.file(
        File(provider.verificationData.selfieWithIdImagePath!),
        fit: BoxFit.cover,
      ),
    ),
  ),

          24.height,
          // Take Selfie Button
          MyButton(
            buttonText: provider.verificationData.selfieWithIdImagePath != null
                ? 'Retake Selfie with ID'
                : 'Take Selfie with ID',
            onTap: () async {
              final selfiePath = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ScanScreen(
                    title:
                        'Take Selfie with ${provider.verificationData.idType}',
                    isSelfie: true,
                  ),
                ),
              );

              if (selfiePath != null) {
                provider.updateSelfieWithId(selfiePath);
              }
            },
          ),

          16.height,
          // ID Details Section for modification
          if (provider.verificationData.idFrontImagePath != null)
            _buildIdDetailsSection(provider),
        ],
      ),
    );
  }

  Widget _buildIdDetailsSection(VerificationProvider provider) {
    return Container(
      width: double.infinity,
      padding: AppSizes.CARD_PADDING,
      decoration: BoxDecoration(
        color: context.card,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: context.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyText(
            text: 'ID Details (Optional)',
            color: context.text,
            size: 16,
            weight: FontWeight.w600,
          ),
          16.height,
          // ID Number Input
          MyText(
            text: 'ID Number',
            color: context.text,
            size: 14,
            weight: FontWeight.w500,
          ),
          8.height,
          MyTextField(hint: 'ID Number', controller: _idNumberController),

          // Issue and Expiry Dates
          Row(
            children: [
              Expanded(
                child: _buildDateField(
                  label: 'Issued Date',
                  date: provider.verificationData.issueDate,
                  onTap: () => _selectDate(context, true, provider),
                ),
              ),
              12.width,
              Expanded(
                child: _buildDateField(
                  label: 'Expiry Date',
                  date: provider.verificationData.expiryDate,
                  onTap: () => _selectDate(context, false, provider),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyText(
          text: label,
          color: context.text,
          size: 14,
          weight: FontWeight.w500,
        ),
        8.height,
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: AppSizes.CARD_PADDING,
            decoration: BoxDecoration(
              color: context.scaffoldBackground,
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(color: context.border),
            ),
            child: Row(
              children: [
                SvgPicture.asset(
                  Assets.info,
                  color: context.icon,
                  height: 16.0,
                ),
                8.width,
                MyText(
                  text: date != null
                      ? '${date.day}/${date.month}/${date.year}'
                      : 'Select date',
                  color: date != null ? context.text : context.subtitle,
                  size: 14,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(
    BuildContext context,
    bool isIssueDate,
    VerificationProvider provider,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      if (isIssueDate) {
        provider.updateIssueDate(picked);
      } else {
        provider.updateExpiryDate(picked);
      }
    }
  }
}
