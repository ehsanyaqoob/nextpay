import 'package:nextpay/core/navigation/navigate.dart';
import 'package:nextpay/core/navigation/route_transition.dart';
import 'package:nextpay/export.dart';
import 'package:nextpay/features/screens/home/home_screen.dart';

class DetailsFormScreen extends StatefulWidget {
  const DetailsFormScreen({super.key});

  @override
  State<DetailsFormScreen> createState() => _DetailsFormScreenState();
}

class _DetailsFormScreenState extends State<DetailsFormScreen> {
  final PageController _pageController = PageController();

  // Form data
  String? selectedAccountType;
  final fullNameController = TextEditingController();
  String? selectedCountry;
  String? selectedIdType;
  final idNumberController = TextEditingController();
  DateTime? idIssueDate;
  DateTime? idExpiryDate;

  int _currentStep = 0;
  final int _totalSteps = 5;

  // Countries list
  final List<String> countries = [
    'Australia',
    'Belgium',
    'Brazil',
    'Canada',
    'China',
    'United Arab Emirates',
    'United Kingdom',
    'United States of America',
  ];

  // ID Types
  final List<String> idTypes = [
    'National Identity Card',
    'Passport',
    'Driver License',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    fullNameController.dispose();
    idNumberController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeVerification();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  void _completeVerification() {
    // Handle verification completion
    final verificationData = {
      'accountType': selectedAccountType,
      'fullName': fullNameController.text,
      'country': selectedCountry,
      'idType': selectedIdType,
      'idNumber': idNumberController.text,
      'issueDate': idIssueDate,
      'expiryDate': idExpiryDate,
    };

    print('Verification Data: $verificationData');

    // Navigate to home screen
    Navigate.to(
      context: context,
      page: const HomeScreen(),
      transition: RouteTransition.rightToLeft,
    );
  }

  double get _progressValue {
    return (_currentStep + 1) / _totalSteps;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBackground,
      appBar: MyAppBar(
        title: _getAppBarTitle(),
        onBackPressed: _previousStep,
        centerTitle: false,
        showBackButton: true,
      ),
      body: Column(
        children: [
          // Progress Indicator
          Container(
            padding: AppSizes.DEFAULT,
            child: Column(
              children: [
                // Progress Text
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    MyText(
                      text: 'Step ${_currentStep + 1} of $_totalSteps',
                      color: context.primary,
                      size: 14,
                      weight: FontWeight.w600,
                    ),
                    MyText(
                      text: '${((_currentStep + 1) / _totalSteps * 100).round()}% Complete',
                      color: context.subtitle,
                      size: 14,
                    ),
                  ],
                ),
                const Gap(12),
                // Linear Progress Bar
                Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: context.card,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Stack(
                    children: [
                      // Background
                      Container(
                        height: 6,
                        decoration: BoxDecoration(
                          color: context.card,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      // Progress
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        height: 6,
                        width: MediaQuery.of(context).size.width * _progressValue,
                        decoration: BoxDecoration(
                          color: context.primary,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Form Content
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                // Step 1: Account Type Selection
                _buildAccountTypeStep(),

                // Step 2: Full Name
                _buildNameStep(),

                // Step 3: Country Selection
                _buildCountryStep(),

                // Step 4: ID Type Selection
                _buildIdTypeStep(),

                // Step 5: ID Details
                _buildIdDetailsStep(),
              ],
            ),
          ),

          // Navigation Buttons - Only show for steps that need them
          if (_currentStep > 0) // Show buttons only from step 2 onwards
            Container(
              padding: const EdgeInsets.all(24),
              child: MyButton(
                buttonText: _currentStep == _totalSteps - 1 ? 'Complete Verification' : 'Continue',
                onTap: _nextStep,
                mHoriz: 0,
              ),
            ),
        ],
      ),
    );
  }

  String _getAppBarTitle() {
    switch (_currentStep) {
      case 0:
        return 'Account Type';
      case 1:
        return 'Your Name';
      case 2:
        return 'Country';
      case 3:
        return 'ID Verification';
      case 4:
        return 'ID Details';
      default:
        return 'Complete Profile';
    }
  }

  Widget _buildAccountTypeStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Gap(20),
          MyText(
            text: 'What kind of account do you want to open?',
            color: context.text,
            size: 24,
            weight: FontWeight.bold,
          ),
          const Gap(12),
          MyText(
            text: 'You can always add another account later.',
            color: context.subtitle,
            size: 16,
          ),
          const Gap(32),

          // Personal Account Card
          _buildAccountTypeCard(
            title: 'Personal Account',
            description: 'Shop, send and receive money around the world at lower costs.',
            isSelected: selectedAccountType == 'Personal',
            onTap: () {
              setState(() => selectedAccountType = 'Personal');
              // Auto navigate to next step after selection
              Future.delayed(const Duration(milliseconds: 300), () {
                _nextStep();
              });
            },
          ),
          const Gap(16),

          // Business Account Card
          _buildAccountTypeCard(
            title: 'Business Account',
            description: 'Grow your business with more advanced features.',
            isSelected: selectedAccountType == 'Business',
            onTap: () {
              setState(() => selectedAccountType = 'Business');
              // Auto navigate to next step after selection
              Future.delayed(const Duration(milliseconds: 300), () {
                _nextStep();
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAccountTypeCard({
    required String title,
    required String description,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? context.primary.withOpacity(0.1) : context.card,
          border: Border.all(
            color: isSelected ? context.primary : context.border,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MyText(
              text: title,
              color: context.text,
              size: 18,
              weight: FontWeight.w600,
            ),
            const Gap(8),
            MyText(
              text: description,
              color: context.subtitle,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNameStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Gap(20),
          MyText(
            text: 'What is your name?',
            color: context.text,
            size: 24,
            weight: FontWeight.bold,
          ),
          const Gap(12),
          MyText(
            text: 'Enter your full legal name according to the identity card.',
            color: context.subtitle,
            size: 16,
          ),
          const Gap(8),
          MyText(
            text: 'Full Name',
            color: context.text,
            size: 14,
            weight: FontWeight.w600,
          ),
          const Gap(32),

          // Full Name Input
          MyTextFieldPresets.name(
            context: context,
            controller: fullNameController,
            hint: 'Andrew Ainsley',
          ),
        ],
      ),
    );
  }

  Widget _buildCountryStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Gap(20),
          MyText(
            text: 'Where do you come from?',
            color: context.text,
            size: 24,
            weight: FontWeight.bold,
          ),
          const Gap(12),
          MyText(
            text: 'Select your country of origin. We will verify your identity in the next step of your residence.',
            color: context.subtitle,
            size: 16,
          ),
          const Gap(32),

          // Search Field
          TextField(
            decoration: InputDecoration(
              hintText: 'Search country',
              prefixIcon: Icon(Icons.search, color: context.subtitle),
              filled: true,
              fillColor: context.card,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: context.border),
              ),
            ),
          ),
          const Gap(16),

          // Countries List
          ...countries.map((country) => _buildCountryItem(country)).toList(),
        ],
      ),
    );
  }

  Widget _buildCountryItem(String country) {
    final isSelected = selectedCountry == country;
    return GestureDetector(
      onTap: () => setState(() => selectedCountry = country),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: context.border),
          ),
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
                  ? Icon(Icons.check, size: 12, color: context.icon)
                  : null,
            ),
            const Gap(16),
            MyText(
              text: country,
              color: context.text,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIdTypeStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Gap(20),
          MyText(
            text: 'Proof of residency',
            color: context.text,
            size: 24,
            weight: FontWeight.bold,
          ),
          const Gap(12),
          MyText(
            text: 'Choose a verification method. You will be asked for photo proof of residence in the next step.',
            color: context.subtitle,
            size: 16,
          ),
          const Gap(32),

          // ID Types
          ...idTypes.map((idType) => _buildIdTypeItem(idType)).toList(),
        ],
      ),
    );
  }

  Widget _buildIdTypeItem(String idType) {
    final isSelected = selectedIdType == idType;
    return GestureDetector(
      onTap: () => setState(() => selectedIdType = idType),
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
          borderRadius: BorderRadius.circular(12),
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
                  ? Icon(Icons.check, size: 12, color: context.icon)
                  : null,
            ),
            const Gap(16),
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

  Widget _buildIdDetailsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Gap(20),
          MyText(
            text: 'IDENTIFICATION CARD',
            color: context.text,
            size: 18,
            weight: FontWeight.bold,
          ),
          const Gap(24),

          // ID Preview Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: context.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildIdDetailRow('Name', fullNameController.text.isNotEmpty ? fullNameController.text : 'Andrew Ainsley'),
                _buildIdDetailRow('ID Number', idNumberController.text.isNotEmpty ? idNumberController.text : '573183659'),
                _buildIdDetailRow('Country', selectedCountry ?? 'United States'),
                _buildIdDetailRow('Issued', idIssueDate != null ? 'Dec ${idIssueDate!.year}' : 'Dec 2023'),
                _buildIdDetailRow('Expires', idExpiryDate != null ? 'Nov ${idExpiryDate!.year}' : 'Nov 2026'),
              ],
            ),
          ),
          const Gap(32),

          // ID Number Input
          MyTextFieldPresets.name(
            context: context,
            controller: idNumberController,
            hint: 'Enter ID Number',
          ),
          const Gap(16),

          // Issue and Expiry Dates
          Row(
            children: [
              Expanded(
                child: _buildDateField(
                  label: 'Issued Date',
                  date: idIssueDate,
                  onTap: () => _selectDate(context, true),
                ),
              ),
              const Gap(12),
              Expanded(
                child: _buildDateField(
                  label: 'Expiry Date',
                  date: idExpiryDate,
                  onTap: () => _selectDate(context, false),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIdDetailRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          MyText(
            text: label,
            color: context.subtitle,
            size: 14,
          ),
          MyText(
            text: value,
            color: context.text,
            size: 14,
            weight: FontWeight.w500,
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
        const Gap(8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            decoration: BoxDecoration(
              color: context.card,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: context.border),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: context.subtitle,
                  size: 20,
                ),
                const Gap(12),
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

  Future<void> _selectDate(BuildContext context, bool isIssueDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isIssueDate) {
          idIssueDate = picked;
        } else {
          idExpiryDate = picked;
        }
      });
    }
  }
}