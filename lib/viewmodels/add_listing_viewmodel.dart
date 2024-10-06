import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ipj417c_b_2024/services/Listings_repository.dart';

class AddListingViewModel extends ChangeNotifier {
  final ListingRepository _repository;

  int _currentStep = 0;
  String _title = '';
  String _description = '';
  double _price = 0.0;
  String _address = '';
  List<XFile> _images = [];
  List<String> _amenities = [];
  List<String> _rules = [];
  double _distanceFromCampus = 0.0;
  String _neighborhood = '';
  bool _isBursaryEligible = false;
  Map<String, dynamic> _safetyFeatures = {};

  bool _isLoading = false;
  String _errorMessage = '';

  // Amenities
  bool _hasWifi = false;
  bool _hasLaundry = false;

  // Safety Features
  bool _hasSmokeDetector = false;
  bool get hasSmokeDetector => _hasSmokeDetector;

  // Getters
  bool get hasWifi => _hasWifi;
  bool get hasLaundry => _hasLaundry;

  void setHasWifi(bool value) {
    _hasWifi = value;
    notifyListeners();
  }

  void setHasLaundry(bool value) {
    _hasLaundry = value;
    notifyListeners();
  }

  void setHasSmokeDetector(bool value) {
    _hasSmokeDetector = value;
    notifyListeners();
  }

  AddListingViewModel(this._repository);

  // Getters
  int get currentStep => _currentStep;
  String get title => _title;
  String get description => _description;
  double get price => _price;
  String get address => _address;
  List<XFile> get images => _images;
  List<String> get amenities => _amenities;
  List<String> get rules => _rules;
  double get distanceFromCampus => _distanceFromCampus;
  String get neighborhood => _neighborhood;
  bool get isBursaryEligible => _isBursaryEligible;
  Map<String, dynamic> get safetyFeatures => _safetyFeatures;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  // Setters
  void setTitle(String value) {
    _title = value;
    notifyListeners();
  }

  void setDescription(String value) {
    _description = value;
    notifyListeners();
  }

  void setPrice(double value) {
    _price = value;
    notifyListeners();
  }

  void setAddress(String value) {
    _address = value;
    notifyListeners();
  }

  void setImages(List<XFile> value) {
    _images = value;
    notifyListeners();
  }

  void setAmenities(List<String> value) {
    _amenities = value;
    notifyListeners();
  }

  void setRules(List<String> value) {
    _rules = value;
    notifyListeners();
  }

  void setDistanceFromCampus(double value) {
    _distanceFromCampus = value;
    notifyListeners();
  }

  void setNeighborhood(String value) {
    _neighborhood = value;
    notifyListeners();
  }

  void setIsBursaryEligible(bool value) {
    _isBursaryEligible = value;
    notifyListeners();
  }

  void setSafetyFeatures(Map<String, dynamic> value) {
    _safetyFeatures = value;
    notifyListeners();
  }

  void goToNextStep() {
    if (_currentStep < 4) {
      // Assuming 5 steps total
      _currentStep++;
      notifyListeners();
    }
  }

  void goToPreviousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      notifyListeners();
    }
  }

  bool canProceed() {
    switch (_currentStep) {
      case 0:
        return _title.isNotEmpty && _description.isNotEmpty;
      case 1:
        return _price > 0 && _address.isNotEmpty && _distanceFromCampus >= 0;
      case 2:
        return _images.isNotEmpty;
      case 3:
        return true;
      case 4:
        return true;
      default:
        return false;
    }
  }

  Future<void> submitListing() async {
    if (!canProceed()) {
      _errorMessage = 'Please fill in all required fields correctly.';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      List<String> amenities = [];
      if (_hasWifi) amenities.add('Wi-Fi');

      // Prepare safety features map
      Map<String, bool> safetyFeatures = {
        'Smoke Detector': _hasSmokeDetector,
      };

      await _repository.addListing(
        title: _title,
        description: _description,
        price: _price,
        address: _address,
        images: _images,
        amenities: _amenities,
        rules: _rules,
        distanceFromCampus: _distanceFromCampus,
        neighborhood: _neighborhood,
        isBursaryEligible: _isBursaryEligible,
        safetyFeatures: safetyFeatures,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to add listing: ${e.toString()}';
      notifyListeners();
    }
  }
}
