import 'dart:async';
import 'package:flutter/material.dart';

class OtpVerificationViewModel extends ChangeNotifier {
  final String fullPhoneNumber;
  
  bool _isLoading = false;
  String _otpCode = '';
  static const String validOtpCode = '123456'; // Code statique pour test

  bool get isLoading => _isLoading;

  OtpVerificationViewModel({required this.fullPhoneNumber});

  void setOtpCode(String value) {
    _otpCode = value;
    notifyListeners();
  }

  Future<bool> verifyOTP() async {
    if (_otpCode.length != 6) return false;

    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1));
      return _otpCode == validOtpCode;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
