// verification_provider.dart
import 'dart:io';

import 'package:country_pickers/country.dart';
import 'package:country_pickers/country_pickers.dart';
import 'package:flutter/foundation.dart';

class VerificationData {
  final String? accountType;
  final String? fullName;
  final Country? country;
  final String? idType;
  final String? idNumber;
  final DateTime? issueDate;
  final DateTime? expiryDate;
  final String? idFrontImagePath;
  final String? selfieWithIdImagePath;
  String? phoneNumber;
  DateTime? dateOfBirth;

  VerificationData({
    this.accountType,
    this.fullName,
    this.country,
    this.idType,
    this.idNumber,
    this.issueDate,
    this.expiryDate,
    this.idFrontImagePath,
    this.selfieWithIdImagePath,
    this.dateOfBirth,
    this.phoneNumber,
  });

  VerificationData copyWith({
    String? accountType,
    String? fullName,
    Country? country,
    String? idType,
    String? idNumber,
    DateTime? issueDate,
    DateTime? expiryDate,
    String? idFrontImagePath,
    String? selfieWithIdImagePath,
    String? phoneNumber,
    DateTime? dateOfBirth,
  }) {
    return VerificationData(
      accountType: accountType ?? this.accountType,
      fullName: fullName ?? this.fullName,
      country: country ?? this.country,
      idType: idType ?? this.idType,
      idNumber: idNumber ?? this.idNumber,
      issueDate: issueDate ?? this.issueDate,
      expiryDate: expiryDate ?? this.expiryDate,
      idFrontImagePath: idFrontImagePath ?? this.idFrontImagePath,
      selfieWithIdImagePath:
          selfieWithIdImagePath ?? this.selfieWithIdImagePath,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'accountType': accountType,
      'fullName': fullName,
      'country': country?.name,
      'countryCode': country?.isoCode,
      'idType': idType,
      'idNumber': idNumber,
      'issueDate': issueDate?.toIso8601String(),
      'expiryDate': expiryDate?.toIso8601String(),
      'idFrontImagePath': idFrontImagePath,
      'selfieWithIdImagePath': selfieWithIdImagePath,
    };
  }
}

class VerificationProvider with ChangeNotifier {
  VerificationData _verificationData = VerificationData();
  int _currentStep = 0;
  final int _totalSteps = 7; // Changed from 6 to 7 to include the review step
  bool _isLoading = false;
  String? _errorMessage;

  VerificationData get verificationData => _verificationData;
  int get currentStep => _currentStep;
  int get totalSteps => _totalSteps;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  static const List<String> _isoCodes = [
    'AF',
    'AX',
    'AL',
    'DZ',
    'AS',
    'AD',
    'AO',
    'AI',
    'AQ',
    'AG',
    'AR',
    'AM',
    'AW',
    'AU',
    'AT',
    'AZ',
    'BS',
    'BH',
    'BD',
    'BB',
    'BY',
    'BE',
    'BZ',
    'BJ',
    'BM',
    'BT',
    'BO',
    'BQ',
    'BA',
    'BW',
    'BV',
    'BR',
    'IO',
    'BN',
    'BG',
    'BF',
    'BI',
    'CV',
    'KH',
    'CM',
    'CA',
    'KY',
    'CF',
    'TD',
    'CL',
    'CN',
    'CX',
    'CC',
    'CO',
    'KM',
    'CG',
    'CD',
    'CK',
    'CR',
    'CI',
    'HR',
    'CU',
    'CW',
    'CY',
    'CZ',
    'DK',
    'DJ',
    'DM',
    'DO',
    'EC',
    'EG',
    'SV',
    'GQ',
    'ER',
    'EE',
    'SZ',
    'ET',
    'FK',
    'FO',
    'FJ',
    'FI',
    'FR',
    'GF',
    'PF',
    'TF',
    'GA',
    'GM',
    'GE',
    'DE',
    'GH',
    'GI',
    'GR',
    'GL',
    'GD',
    'GP',
    'GU',
    'GT',
    'GG',
    'GN',
    'GW',
    'GY',
    'HT',
    'HM',
    'VA',
    'HN',
    'HK',
    'HU',
    'IS',
    'IN',
    'ID',
    'IR',
    'IQ',
    'IE',
    'IM',
    'IL',
    'IT',
    'JM',
    'JP',
    'JE',
    'JO',
    'KZ',
    'KE',
    'KI',
    'KP',
    'KR',
    'KW',
    'KG',
    'LA',
    'LV',
    'LB',
    'LS',
    'LR',
    'LY',
    'LI',
    'LT',
    'LU',
    'MO',
    'MG',
    'MW',
    'MY',
    'MV',
    'ML',
    'MT',
    'MH',
    'MQ',
    'MR',
    'MU',
    'YT',
    'MX',
    'FM',
    'MD',
    'MC',
    'MN',
    'ME',
    'MS',
    'MA',
    'MZ',
    'MM',
    'NA',
    'NR',
    'NP',
    'NL',
    'NC',
    'NZ',
    'NI',
    'NE',
    'NG',
    'NU',
    'NF',
    'MK',
    'MP',
    'NO',
    'OM',
    'PK',
    'PW',
    'PS',
    'PA',
    'PG',
    'PY',
    'PE',
    'PH',
    'PN',
    'PL',
    'PT',
    'PR',
    'QA',
    'RE',
    'RO',
    'RU',
    'RW',
    'BL',
    'SH',
    'KN',
    'LC',
    'MF',
    'PM',
    'VC',
    'WS',
    'SM',
    'ST',
    'SA',
    'SN',
    'RS',
    'SC',
    'SL',
    'SG',
    'SX',
    'SK',
    'SI',
    'SB',
    'SO',
    'ZA',
    'GS',
    'SS',
    'ES',
    'LK',
    'SD',
    'SR',
    'SJ',
    'SE',
    'CH',
    'SY',
    'TW',
    'TJ',
    'TZ',
    'TH',
    'TL',
    'TG',
    'TK',
    'TO',
    'TT',
    'TN',
    'TR',
    'TM',
    'TC',
    'TV',
    'UG',
    'UA',
    'AE',
    'GB',
    'US',
    'UM',
    'UY',
    'UZ',
    'VU',
    'VE',
    'VN',
    'VG',
    'VI',
    'WF',
    'EH',
    'YE',
    'ZM',
    'ZW',
  ];

  List<Country> get countries => _isoCodes
      .map((code) => CountryPickerUtils.getCountryByIsoCode(code))
      .toList();

  final List<String> idTypes = [
    'National Identity Card',
    'Passport',
    'Driver License',
  ];
  // Add these methods to VerificationProvider class
  Future<bool> validateImageQuality(String? imagePath, bool isSelfie) async {
    if (imagePath == null || !File(imagePath).existsSync()) return false;

    try {
      final file = File(imagePath);
      final stat = file.statSync();
      final minSize = isSelfie ? 25000 : 20000;

      if (stat.size < minSize) {
        _errorMessage = isSelfie
            ? 'Selfie quality too low. Please ensure both face and ID are clearly visible.'
            : 'Document image quality too low. Please capture a clear image.';
        return false;
      }

      return true;
    } catch (e) {
      _errorMessage = 'Error validating image: $e';
      return false;
    }
  }

  // Update existing validation methods
  String? validateIdFrontImage(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please capture the front of your ID';
    }

    // Basic file check
    if (!File(value).existsSync()) {
      return 'Invalid image file. Please capture again.';
    }

    return null;
  }

  String? validateSelfieWithId(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please take a selfie with your ID';
    }

    if (!File(value).existsSync()) {
      return 'Invalid selfie image. Please capture again.';
    }

    return null;
  }

  // Validation methods
  String? validateAccountType(String? value) {
    if (value == null || value.isEmpty) return 'Please select an account type';
    return null;
  }

  String? validateFullName(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your full name';
    if (value.length < 2) return 'Name must be at least 2 characters long';
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value))
      return 'Name can only contain letters and spaces';
    return null;
  }

  String? validateCountry(Country? value) {
    if (value == null) return 'Please select your country';
    return null;
  }

  String? validateIdType(String? value) {
    if (value == null || value.isEmpty) return 'Please select an ID type';
    return null;
  }

  String? validateIdNumber(String? value) {
    if (value == null || value.isEmpty) return 'ID number is optional';
    if (value.length < 3) return 'ID number must be at least 3 characters long';
    return null;
  }

  String? validateIssueDate(DateTime? value) {
    if (value == null) return 'Issue date is optional';
    if (value.isAfter(DateTime.now()))
      return 'Issue date cannot be in the future';
    return null;
  }

  String? validateExpiryDate(DateTime? value, DateTime? issueDate) {
    if (value == null) return 'Expiry date is optional';
    if (issueDate != null && value.isBefore(issueDate))
      return 'Expiry date must be after issue date';
    if (value.isBefore(DateTime.now())) return 'ID has expired';
    return null;
  }

  bool validateStep(int step) {
    switch (step) {
      case 0:
        return validateAccountType(_verificationData.accountType) == null;
      case 1:
        return validateFullName(_verificationData.fullName) == null;
      case 2:
        return validateCountry(_verificationData.country) == null;
      case 3:
        return validateIdType(_verificationData.idType) == null;
      case 4:
        return validateIdFrontImage(_verificationData.idFrontImagePath) == null;
      case 5:
        return validateSelfieWithId(_verificationData.selfieWithIdImagePath) ==
            null;
      case 6:
        // Review step - always valid since it's just reviewing collected data
        return true;
      default:
        return false;
    }
  }

  String? getStepValidationMessage(int step) {
    switch (step) {
      case 0:
        return validateAccountType(_verificationData.accountType);
      case 1:
        return validateFullName(_verificationData.fullName);
      case 2:
        return validateCountry(_verificationData.country);
      case 3:
        return validateIdType(_verificationData.idType);
      case 4:
        return validateIdFrontImage(_verificationData.idFrontImagePath);
      case 5:
        return validateSelfieWithId(_verificationData.selfieWithIdImagePath);
      case 6:
        return null; // Review step has no validation
      default:
        return 'Please complete this step';
    }
  }

  String getAppBarTitle() {
    switch (_currentStep) {
      case 0:
        return 'Account Type';
      case 1:
        return 'Your Name';
      case 2:
        return 'Country';
      case 3:
        return 'Select ID Type';
      case 4:
        return 'Capture ID';
      case 5:
        return 'Selfie with ID';
      case 6:
        return 'Review Information'; // Added for step 7
      default:
        return 'Complete Profile';
    }
  }

  // Add these methods to your VerificationProvider class
  void updatePhoneNumber(String phoneNumber) {
    _verificationData.phoneNumber = phoneNumber;
    notifyListeners();
  }

  void updateDateOfBirth(DateTime dateOfBirth) {
    _verificationData.dateOfBirth = dateOfBirth;
    notifyListeners();
  }

  void updateAccountType(String accountType) {
    _verificationData = _verificationData.copyWith(accountType: accountType);
    notifyListeners();
  }

  void updateFullName(String fullName) {
    _verificationData = _verificationData.copyWith(fullName: fullName);
    notifyListeners();
  }

  void updateCountry(Country country) {
    _verificationData = _verificationData.copyWith(country: country);
    notifyListeners();
  }

  void updateIdType(String idType) {
    _verificationData = _verificationData.copyWith(idType: idType);
    notifyListeners();
  }

  void updateIdNumber(String idNumber) {
    _verificationData = _verificationData.copyWith(idNumber: idNumber);
    notifyListeners();
  }

  void updateIssueDate(DateTime issueDate) {
    _verificationData = _verificationData.copyWith(issueDate: issueDate);
    notifyListeners();
  }

  void updateExpiryDate(DateTime expiryDate) {
    _verificationData = _verificationData.copyWith(expiryDate: expiryDate);
    notifyListeners();
  }

  void updateIdFrontImage(String path) {
    _verificationData = _verificationData.copyWith(idFrontImagePath: path);
    notifyListeners();
  }

  void updateSelfieWithId(String path) {
    _verificationData = _verificationData.copyWith(selfieWithIdImagePath: path);
    notifyListeners();
  }

  void nextStep() {
    if (_currentStep < _totalSteps - 1) {
      _currentStep++;
      notifyListeners();
    }
  }

  void previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      notifyListeners();
    }
  }

  void setStep(int step) {
    if (step >= 0 && step < _totalSteps) {
      _currentStep = step;
      notifyListeners();
    }
  }

  bool canGoNext() => validateStep(_currentStep);

  List<Country> searchCountries(String query) {
    if (query.isEmpty) return countries;
    return countries
        .where((c) => c.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  // In your submitVerification method, add image quality validation
  Future<bool> submitVerification() async {
    // Validate all steps first
    for (int i = 0; i < _totalSteps; i++) {
      if (!validateStep(i)) {
        _errorMessage = getStepValidationMessage(i);
        notifyListeners();
        return false;
      }
    }

    // Additional image quality validation
    if (_verificationData.idFrontImagePath != null) {
      final idQuality = await validateImageQuality(
        _verificationData.idFrontImagePath,
        false,
      );
      if (!idQuality) {
        return false;
      }
    }

    if (_verificationData.selfieWithIdImagePath != null) {
      final selfieQuality = await validateImageQuality(
        _verificationData.selfieWithIdImagePath,
        true,
      );
      if (!selfieQuality) {
        return false;
      }
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 2));
      final random = DateTime.now().millisecond % 10;
      if (random == 0)
        throw Exception('Verification failed: Please try again.');
      if (kDebugMode)
        print('Verification submitted: ${_verificationData.toMap()}');
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  void reset() {
    _verificationData = VerificationData();
    _currentStep = 0;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  double get progressValue => (_currentStep + 1) / _totalSteps;

  String getButtonText() {
    if (_currentStep == _totalSteps - 1) {
      return 'Complete Verification'; // This is now Step 7
    } else if (_currentStep == _totalSteps - 2) {
      return 'Review Information'; // This is Step 6 (selfie step)
    } else {
      return 'Continue';
    }
  }

  bool get shouldShowButton => _currentStep >= 0;
}
