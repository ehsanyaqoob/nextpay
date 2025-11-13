// details_form_screen.dart
import 'dart:io';
import 'package:nextpay/core/navigation/navigate.dart';
import 'package:nextpay/core/navigation/route_transition.dart';
import 'package:nextpay/export.dart';
import 'package:nextpay/features/auth/screens/doc_scan_screen.dart';
import 'package:nextpay/features/screens/home/home_screen.dart';
import 'package:nextpay/features/auth/screens/set_pin_screen.dart';
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
  final TextEditingController _countrySearchController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeData();
  }
void _initializeData() {
  final provider = context.read<VerificationProvider>();
  _fullNameController.text = provider.verificationData.fullName ?? '';
  
  // Pre-fill phone number and date of birth if they exist
  _phoneController.text = provider.verificationData.phoneNumber ?? '';
  if (provider.verificationData.dateOfBirth != null) {
    final dob = provider.verificationData.dateOfBirth!;
    _dobController.text = '${dob.day}/${dob.month}/${dob.year}';
  } else {
    _dobController.text = '';
  }

  _fullNameController.addListener(() {
    provider.updateFullName(_fullNameController.text);
  });

  // Listen to phone number changes
  _phoneController.addListener(() {
    provider.updatePhoneNumber(_phoneController.text);
  });
}
  @override
  void dispose() {
    _pageController.dispose();
    _fullNameController.dispose();
    _countrySearchController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    super.dispose();
  }// Update _nextStep method to handle step 6 validation differently
void _nextStep() async {
  final provider = context.read<VerificationProvider>();

  // Special handling for step 5 (selfie step) - allow proceeding to review
  if (provider.currentStep == 5) {
    // Allow moving to review even if selfie is not perfect
    provider.nextStep();
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    return;
  }

  // For other steps, validate normally
  if (provider.currentStep != 6 && !provider.canGoNext()) {
    final errorMessage = provider.getStepValidationMessage(provider.currentStep);
    AppToast.show(
      errorMessage ?? 'Please complete this step',
      context,
      type: ToastType.error,
      duration: const Duration(seconds: 2),
    );
    return;
  }

  if (provider.currentStep < provider.totalSteps - 1) {
    provider.nextStep();
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  } else {
    _submitVerification();
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

  Future<void> _submitVerification() async {
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
        page: const SetPinScreen(),
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
              _buildProgressIndicator(provider),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildAccountTypeStep(provider),
                    _buildNameStep(provider),
                    _buildCountryStep(provider),
                    _buildIdTypeStep(provider),
                    _buildIdCaptureReviewStep(provider),
                    _buildSelfieWithIdReviewStep(provider),
                    _buildCompleteProfileStep(provider),
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            MyText(
              text: 'Step ${provider.currentStep + 1} of ${provider.totalSteps}',
              color: context.primary,
              size: 12.0,
              weight: FontWeight.w600,
            ),
            MyText(
              text: '${((provider.currentStep + 1) / provider.totalSteps * 100).round()}% Complete',
              color: context.subtitle,
              size: 14.0,
            ),
          ],
        ),
        12.height,
        Container(
          height: 6,
          decoration: BoxDecoration(
            color: context.card,
            borderRadius: BorderRadius.circular(6.0),
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            height: 6,
            width: MediaQuery.of(context).size.width * ((provider.currentStep + 1) / provider.totalSteps),
            decoration: BoxDecoration(
              color: context.primary,
              borderRadius: BorderRadius.circular(6.0),
            ),
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

  // Step 1: Account Type
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
          _buildAccountTypeCard(
            icon: Icons.person,
            title: 'Personal Account',
            description: 'Shop, send and receive money around the world at lower costs.',
            isSelected: provider.verificationData.accountType == 'Personal',
            onTap: () {
              provider.updateAccountType('Personal');
              Future.delayed(const Duration(milliseconds: 300), _nextStep);
            },
          ),
          16.height,
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
            text: 'Where do you come from?',
            color: context.text,
            size: 24.0,
            weight: FontWeight.bold,
          ),
          12.height,
          MyText(
            text: 'Select your country of origin. We will verify your identity in the next step.',
            color: context.subtitle,
            size: 14.0,
          ),
          20.height,
          MyTextField(
            hint: 'United States',
            prefix: Icon(Icons.search, color: context.primary, size: 20),
            controller: _countrySearchController,
            onChanged: (value) => setState(() {}),
            keyboardType: TextInputType.text,
            suffix: _countrySearchController.text.isNotEmpty
                ? GestureDetector(
                    onTap: () {
                      _countrySearchController.clear();
                      setState(() {});
                    },
                    child: Icon(Icons.close, color: context.subtitle, size: 20),
                  )
                : null,
          ),
          16.height,
          Expanded(
            child: Consumer<VerificationProvider>(
              builder: (context, provider, child) {
                final searchedCountries = _countrySearchController.text.isEmpty
                    ? provider.countries
                    : provider.searchCountries(_countrySearchController.text);

                return ListView.builder(
                  itemCount: searchedCountries.length,
                  padding: EdgeInsets.zero,
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
    final isSelected = provider.verificationData.country?.isoCode == country.isoCode;

    return GestureDetector(
      onTap: () => provider.updateCountry(country),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? context.primary.withOpacity(0.08) : Colors.transparent,
          border: Border.all(
            color: isSelected ? context.primary : context.border,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: CountryPickerUtils.getDefaultFlagImage(country),
            ),
            16.width,
            Expanded(
              child: MyText(
                text: country.name,
                color: context.text,
                size: 16,
                weight: FontWeight.w500,
              ),
            ),
            if (isSelected) Icon(Icons.check, color: context.primary, size: 24),
          ],
        ),
      ),
    );
  }

  // Step 4: ID Type Selection
  Widget _buildIdTypeStep(VerificationProvider provider) {
    return SingleChildScrollView(
      padding: AppSizes.DEFAULT,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          20.height,
          MyText(
            text: 'What type of ID do you have?',
            color: context.text,
            size: 24,
            weight: FontWeight.bold,
          ),
          12.height,
          MyText(
            text: 'Choose the type of identification document you will use for verification.',
            color: context.subtitle,
            size: 14,
          ),
          32.height,
          ...provider.idTypes.map((idType) => _buildIdTypeItem(idType, provider)),
          40.height,
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
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? context.primary.withOpacity(0.08) : Colors.transparent,
          border: Border.all(
            color: isSelected ? context.primary : context.border,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              Assets.visa,
              color: isSelected ? context.primary : context.icon,
              height: 24,
              width: 24,
            ),
            16.width,
            Expanded(
              child: MyText(
                text: idType,
                color: context.text,
                size: 16,
                weight: FontWeight.w500,
              ),
            ),
            if (isSelected) Icon(Icons.check, color: context.primary, size: 24),
          ],
        ),
      ),
    );
  }

  // Step 5: ID Capture with Review
  Widget _buildIdCaptureReviewStep(VerificationProvider provider) {
    return SingleChildScrollView(
      padding: AppSizes.DEFAULT,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
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
            text: 'Capture the front side of your ${provider.verificationData.idType?.toLowerCase() ?? 'ID'}',
            color: context.subtitle,
            size: 14,
            textAlign: TextAlign.center,
          ),
          32.height,

          if (provider.verificationData.idFrontImagePath != null &&
              File(provider.verificationData.idFrontImagePath!).existsSync())
            Column(
              children: [
                Container(
                  width: double.infinity,
                  height: 240,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: context.primary, width: 2),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.file(
                      File(provider.verificationData.idFrontImagePath!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                20.height,
                GestureDetector(
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
                  child: MyText(
                    text: 'Retake',
                    color: context.primary,
                    size: 16.0,
                    weight: FontWeight.w700,
                  ),
                ),
              ],
            )
          else
            GestureDetector(
              onTap: () async {
// In _buildIdCaptureReviewStep method
final imagePath = await Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => ScanScreen(
      title: 'Capture ${provider.verificationData.idType}',
      isSelfie: false,
      requiredIdType: provider.verificationData.idType, // Pass the selected ID type
    ),
  ),
);
                if (imagePath != null) {
                  provider.updateIdFrontImage(imagePath);
                }
              },
              child: Container(
                width: double.infinity,
                height: 240,
                decoration: BoxDecoration(
                  color: context.card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: context.border),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      Assets.camera,
                      color: context.icon,
                      height: 50,
                    ),
                    16.height,
                    MyText(
                      text: 'Tap to Capture Front',
                      color: context.subtitle,
                      size: 14,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Step 6: Selfie with ID Review
  Widget _buildSelfieWithIdReviewStep(VerificationProvider provider) {
    return SingleChildScrollView(
      padding: AppSizes.DEFAULT,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          20.height,
          MyText(
            text: 'Selfie with ID Card',
            color: context.text,
            size: 24,
            weight: FontWeight.bold,
          ),
          12.height,
          MyText(
            text: 'But wait, you gotta take a selfie with ID card 🤳',
            color: context.subtitle,
            size: 14,
            textAlign: TextAlign.center,
          ),
          12.height,
          MyText(
            text: 'Make sure your face is clearly visible. Hold your ID card with a selfie.',
            color: context.subtitle,
            size: 13,
            textAlign: TextAlign.center,
          ),
          40.height,

          if (provider.verificationData.selfieWithIdImagePath != null &&
              File(provider.verificationData.selfieWithIdImagePath!).existsSync())
            Column(
              children: [
                Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: context.primary, width: 3),
                  ),
                  child: ClipOval(
                    child: Image.file(
                      File(provider.verificationData.selfieWithIdImagePath!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                40.height,
                GestureDetector(
                  onTap: () async {
                   // In _buildSelfieWithIdReviewStep method
final selfiePath = await Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => ScanScreen(
      title: 'Selfie with ${provider.verificationData.idType}',
      isSelfie: true,
      requiredIdType: provider.verificationData.idType, // Pass the selected ID type
    ),
  ),
);
                    if (selfiePath != null) {
                      provider.updateSelfieWithId(selfiePath);
                    }
                  },
                  child: MyText(
                    text: 'Retake',
                    color: context.primary,
                    size: 16.0,
                    weight: FontWeight.w700,
                  ),
                ),
              ],
            )
          else
            MyButton(
              buttonText: 'Take a Selfie',
              onTap: () async {
                final selfiePath = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ScanScreen(
                      title: 'Selfie with ${provider.verificationData.idType}',
                      isSelfie: true,
                    ),
                  ),
                );
                if (selfiePath != null) {
                  provider.updateSelfieWithId(selfiePath);
                }
              },
            ),
        ],
      ),
    );
  }

  // Step 7: Complete Profile (Review & Edit All Data)
Widget _buildCompleteProfileStep(VerificationProvider provider) {
  return SingleChildScrollView(
    padding: AppSizes.DEFAULT,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        20.height,
        MyText(
          text: 'Review Your Information 👤',
          color: context.text,
          size: 24,
          weight: FontWeight.bold,
        ),
        12.height,
        MyText(
          text: 'Please review all your information before submission. Your data remains safe and private.',
          color: context.subtitle,
          size: 14,
        ),
        32.height,

        // Profile Picture Section
        _buildProfilePictureSection(provider),
        24.height,

        // Account Type
        _buildDisplayField(
          label: 'Account Type',
          value: provider.verificationData.accountType ?? 'Not selected',
          icon: Icons.account_balance,
        ),
        16.height,

        // Full Name
        _buildDisplayField(
          label: 'Full Name',
          value: provider.verificationData.fullName ?? 'Not provided',
          icon: Icons.person,
        ),
        16.height,

        // Country
        _buildDisplayField(
          label: 'Country',
          value: provider.verificationData.country?.name ?? 'Not selected',
          icon: Icons.location_on,
        ),
        16.height,

        // ID Type
        _buildDisplayField(
          label: 'ID Type',
          value: provider.verificationData.idType ?? 'Not selected',
          icon: Icons.badge,
        ),
        16.height,

        // ID Verification Status
        _buildVerificationStatus(
          label: 'ID Document',
          isVerified: provider.verificationData.idFrontImagePath != null &&
              File(provider.verificationData.idFrontImagePath!).existsSync(),
        ),
        16.height,

        // Selfie Verification Status
        _buildVerificationStatus(
          label: 'Selfie with ID',
          isVerified: provider.verificationData.selfieWithIdImagePath != null &&
              File(provider.verificationData.selfieWithIdImagePath!).existsSync(),
        ),
        16.height,

        // Phone Number (Editable)
        _buildEditableField(
          label: 'Phone Number',
          hint: '+1 111 467 378 399',
          controller: _phoneController,
          icon: Icons.phone,
          onChanged: (value) {
            provider.updatePhoneNumber(value);
          },
        ),
        16.height,

        // Date of Birth (Editable)
        _buildDateField(
          label: 'Date of Birth',
          controller: _dobController,
          onDateSelected: (date) {
            provider.updateDateOfBirth(date);
          },
        ),

        40.height,

        // Additional Information
        _buildAdditionalInfo(),
      ],
    ),
  );
}

Widget _buildProfilePictureSection(VerificationProvider provider) {
  final hasSelfie = provider.verificationData.selfieWithIdImagePath != null &&
      File(provider.verificationData.selfieWithIdImagePath!).existsSync();

  return Center(
    child: Column(
      children: [
        Stack(
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: hasSelfie ? context.primary : context.border,
                  width: 3,
                ),
              ),
              child: ClipOval(
                child: hasSelfie
                    ? Image.file(
                        File(provider.verificationData.selfieWithIdImagePath!),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildPlaceholderAvatar();
                        },
                      )
                    : _buildPlaceholderAvatar(),
              ),
            ),
            if (hasSelfie)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: context.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: context.scaffoldBackground, width: 2),
                  ),
                  child: Icon(Icons.check, color: Colors.white, size: 16),
                ),
              ),
          ],
        ),
        12.height,
        MyText(
          text: hasSelfie ? 'Profile Photo Verified' : 'No Profile Photo',
          color: hasSelfie ? context.primary : context.subtitle,
          size: 14,
          weight: FontWeight.w600,
        ),
      ],
    ),
  );
}

Widget _buildPlaceholderAvatar() {
  return Container(
    color: context.card,
    child: Icon(
      Icons.person,
      color: context.subtitle,
      size: 40,
    ),
  );
}

Widget _buildDisplayField({
  required String label,
  required String value,
  required IconData icon,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Icon(icon, color: context.primary, size: 16),
          8.width,
          MyText(
            text: label,
            color: context.text,
            size: 14,
            weight: FontWeight.w600,
          ),
        ],
      ),
      8.height,
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: context.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.border),
        ),
        child: MyText(
          text: value,
          color: context.text,
          size: 14,
          weight: FontWeight.w500,
        ),
      ),
    ],
  );
}

Widget _buildVerificationStatus({
  required String label,
  required bool isVerified,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      MyText(
        text: label,
        color: context.text,
        size: 14,
        weight: FontWeight.w600,
      ),
      8.height,
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isVerified ? context.primary.withOpacity(0.1) : context.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isVerified ? context.primary : context.border,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isVerified ? Icons.check_circle : Icons.watch_later,
              color: isVerified ? context.primary : context.subtitle,
              size: 20,
            ),
            12.width,
            Expanded(
              child: MyText(
                text: isVerified ? 'Verified' : 'Pending',
                color: isVerified ? context.primary : context.subtitle,
                size: 14,
                weight: FontWeight.w500,
              ),
            ),
            if (isVerified)
              Icon(Icons.verified, color: context.primary, size: 20),
          ],
        ),
      ),
    ],
  );
}

Widget _buildEditableField({
  required String label,
  required String hint,
  required TextEditingController controller,
  required IconData icon,
  required ValueChanged<String> onChanged,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Icon(icon, color: context.primary, size: 16),
          8.width,
          MyText(
            text: label,
            color: context.text,
            size: 14,
            weight: FontWeight.w600,
          ),
        ],
      ),
      8.height,
      MyTextField(
        controller: controller,
        hint: hint,
        onChanged: onChanged,
        keyboardType: TextInputType.phone,
      ),
    ],
  );
}

Widget _buildDateField({
  required String label,
  required TextEditingController controller,
  required ValueChanged<DateTime> onDateSelected,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Icon(Icons.calendar_today, color: context.primary, size: 16),
          8.width,
          MyText(
            text: label,
            color: context.text,
            size: 14,
            weight: FontWeight.w600,
          ),
        ],
      ),
      8.height,
      GestureDetector(
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(1900),
            lastDate: DateTime.now(),
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: ColorScheme.light(primary: context.primary),
                ),
                child: child!,
              );
            },
          );
          if (picked != null) {
            final formattedDate = '${picked.day}/${picked.month}/${picked.year}';
            controller.text = formattedDate;
            onDateSelected(picked);
          }
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: context.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.border),
          ),
          child: Row(
            children: [
              Icon(Icons.calendar_today, color: context.icon, size: 16),
              12.width,
              MyText(
                text: controller.text.isEmpty ? 'Select your date of birth' : controller.text,
                color: controller.text.isEmpty ? context.subtitle : context.text,
                size: 14,
                weight: FontWeight.w500,
              ),
              const Spacer(),
              if (controller.text.isNotEmpty)
                Icon(Icons.check_circle, color: context.primary, size: 16),
            ],
          ),
        ),
      ),
    ],
  );
}

Widget _buildAdditionalInfo() {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: context.primary.withOpacity(0.05),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: context.primary.withOpacity(0.2)),
    ),
    child: Row(
      children: [
        Icon(Icons.security, color: context.primary, size: 20),
        12.width,
        Expanded(
          child: MyText(
            text: 'Your information is encrypted and secure. We protect your privacy according to our data protection policy.',
            color: context.subtitle,
            size: 12,
          ),
        ),
      ],
    ),
  );
}
}