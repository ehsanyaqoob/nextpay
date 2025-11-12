// verification_provider.dart
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
  final String? proofOfResidencyType;
  String? proofOfResidencyImagePath;
  final String? idFrontImagePath;
  final String? idBackImagePath;
  final String? selfieWithIdImagePath;

  VerificationData({
    this.accountType,
    this.fullName,
    this.country,
    this.idType,
    this.idNumber,
    this.issueDate,
    this.expiryDate,
    this.proofOfResidencyImagePath,
    this.proofOfResidencyType,
    this.idFrontImagePath,
    this.idBackImagePath,
    this.selfieWithIdImagePath,
  });

  VerificationData copyWith({
    String? accountType,
    String? fullName,
    Country? country,
    String? idType,
    String? idNumber,
    DateTime? issueDate,
    DateTime? expiryDate,
    String? proofOfResidencyType,
    String? proofOfResidencyImagePath,
    String? idFrontImagePath,
    String? idBackImagePath,
    String? selfieWithIdImagePath,
  }) {
    return VerificationData(
      accountType: accountType ?? this.accountType,
      fullName: fullName ?? this.fullName,
      country: country ?? this.country,
      idType: idType ?? this.idType,
      idNumber: idNumber ?? this.idNumber,
      issueDate: issueDate ?? this.issueDate,
      expiryDate: expiryDate ?? this.expiryDate,
      proofOfResidencyType: proofOfResidencyType ?? this.proofOfResidencyType,
      proofOfResidencyImagePath: proofOfResidencyImagePath ?? this.proofOfResidencyImagePath,
      idFrontImagePath: idFrontImagePath ?? this.idFrontImagePath,
      idBackImagePath: idBackImagePath ?? this.idBackImagePath,
      selfieWithIdImagePath: selfieWithIdImagePath ?? this.selfieWithIdImagePath,
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
      'proofOfResidencyType': proofOfResidencyType,
      'proofOfResidencyImagePath': proofOfResidencyImagePath,
      'idFrontImagePath': idFrontImagePath,
      'idBackImagePath': idBackImagePath,
      'selfieWithIdImagePath': selfieWithIdImagePath,
    };
  }
}

class VerificationProvider with ChangeNotifier {
  VerificationData _verificationData = VerificationData();
  int _currentStep = 0;
  final int _totalSteps = 6;
  bool _isLoading = false;
  String? _errorMessage;

  VerificationData get verificationData => _verificationData;
  int get currentStep => _currentStep;
  int get totalSteps => _totalSteps;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  static const List<String> _isoCodes = [
    'AF','AX','AL','DZ','AS','AD','AO','AI','AQ','AG','AR','AM','AW','AU','AT','AZ','BS','BH','BD','BB',
    'BY','BE','BZ','BJ','BM','BT','BO','BQ','BA','BW','BV','BR','IO','BN','BG','BF','BI','CV','KH','CM',
    'CA','KY','CF','TD','CL','CN','CX','CC','CO','KM','CG','CD','CK','CR','CI','HR','CU','CW','CY','CZ',
    'DK','DJ','DM','DO','EC','EG','SV','GQ','ER','EE','SZ','ET','FK','FO','FJ','FI','FR','GF','PF','TF',
    'GA','GM','GE','DE','GH','GI','GR','GL','GD','GP','GU','GT','GG','GN','GW','GY','HT','HM','VA','HN',
    'HK','HU','IS','IN','ID','IR','IQ','IE','IM','IL','IT','JM','JP','JE','JO','KZ','KE','KI','KP','KR',
    'KW','KG','LA','LV','LB','LS','LR','LY','LI','LT','LU','MO','MG','MW','MY','MV','ML','MT','MH','MQ',
    'MR','MU','YT','MX','FM','MD','MC','MN','ME','MS','MA','MZ','MM','NA','NR','NP','NL','NC','NZ','NI',
    'NE','NG','NU','NF','MK','MP','NO','OM','PK','PW','PS','PA','PG','PY','PE','PH','PN','PL','PT','PR',
    'QA','RE','RO','RU','RW','BL','SH','KN','LC','MF','PM','VC','WS','SM','ST','SA','SN','RS','SC','SL',
    'SG','SX','SK','SI','SB','SO','ZA','GS','SS','ES','LK','SD','SR','SJ','SE','CH','SY','TW','TJ','TZ',
    'TH','TL','TG','TK','TO','TT','TN','TR','TM','TC','TV','UG','UA','AE','GB','US','UM','UY','UZ','VU',
    'VE','VN','VG','VI','WF','EH','YE','ZM','ZW'
  ];

  List<Country> get countries =>
      _isoCodes.map((code) => CountryPickerUtils.getCountryByIsoCode(code)).toList();

  final List<String> idTypes = [
    'National Identity Card',
    'Passport',
    'Driver License',
  ];

  // Validation methods
  String? validateAccountType(String? value) {
    if (value == null || value.isEmpty) return 'Please select an account type';
    return null;
  }

  String? validateFullName(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your full name';
    if (value.length < 2) return 'Name must be at least 2 characters long';
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) return 'Name can only contain letters and spaces';
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
    if (value == null || value.isEmpty) return 'Please enter your ID number';
    if (value.length < 3) return 'ID number must be at least 3 characters long';
    return null;
  }

  String? validateIssueDate(DateTime? value) {
    if (value == null) return 'Please select issue date';
    if (value.isAfter(DateTime.now())) return 'Issue date cannot be in the future';
    return null;
  }

  String? validateExpiryDate(DateTime? value, DateTime? issueDate) {
    if (value == null) return 'Please select expiry date';
    if (issueDate != null && value.isBefore(issueDate)) return 'Expiry date must be after issue date';
    if (value.isBefore(DateTime.now())) return 'ID has expired';
    return null;
  }

  String? validateIdFrontImage(String? value) {
    if (value == null || value.isEmpty) return 'Please capture the front of your ID';
    return null;
  }

  String? validateIdBackImage(String? value) {
    if (value == null || value.isEmpty) return 'Please capture the back of your ID';
    return null;
  }

  String? validateSelfieWithId(String? value) {
    if (value == null || value.isEmpty) return 'Please take a selfie with your ID';
    return null;
  }

  bool validateStep(int step) {
    switch (step) {
      case 0: return validateAccountType(_verificationData.accountType) == null;
      case 1: return validateFullName(_verificationData.fullName) == null;
      case 2: return validateCountry(_verificationData.country) == null;
      case 3: return validateIdType(_verificationData.idType) == null; // Only validate ID type selection
      case 4: // ID Capture step - validate both images are captured
        return validateIdFrontImage(_verificationData.idFrontImagePath) == null &&
               validateIdBackImage(_verificationData.idBackImagePath) == null;
      case 5: // Selfie step
        return validateSelfieWithId(_verificationData.selfieWithIdImagePath) == null;
      default: return false;
    }
  }

  String? getStepValidationMessage(int step) {
    switch (step) {
      case 0: return validateAccountType(_verificationData.accountType);
      case 1: return validateFullName(_verificationData.fullName);
      case 2: return validateCountry(_verificationData.country);
      case 3: return validateIdType(_verificationData.idType);
      case 4:
        return validateIdFrontImage(_verificationData.idFrontImagePath) ??
               validateIdBackImage(_verificationData.idBackImagePath);
      case 5: return validateSelfieWithId(_verificationData.selfieWithIdImagePath);
      default: return 'Please complete this step';
    }
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

  void updateIdBackImage(String path) {
    _verificationData = _verificationData.copyWith(idBackImagePath: path);
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
    return countries.where((c) => c.name.toLowerCase().contains(query.toLowerCase())).toList();
  }

  Future<bool> submitVerification() async {
    for (int i = 0; i < _totalSteps; i++) {
      if (!validateStep(i)) { 
        _errorMessage = getStepValidationMessage(i); 
        notifyListeners(); 
        return false; 
      }
    }
    
    _isLoading = true; 
    _errorMessage = null; 
    notifyListeners();
    
    try {
      await Future.delayed(const Duration(seconds: 2));
      final random = DateTime.now().millisecond % 10;
      if (random == 0) throw Exception('Verification failed: Please try again.');
      if (kDebugMode) print('Verification submitted: ${_verificationData.toMap()}');
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

  String getAppBarTitle() {
    switch (_currentStep) {
      case 0: return 'Account Type';
      case 1: return 'Your Name';
      case 2: return 'Country';
      case 3: return 'Select ID Type';
      case 4: return 'Capture ID';
      case 5: return 'Take Selfie with ID';
      default: return 'Complete Profile';
    }
  }

  String getButtonText() => _currentStep == _totalSteps - 1 ? 'Complete Verification' : 'Continue';

  bool get shouldShowButton => _currentStep > 0;
}