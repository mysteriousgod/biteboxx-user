import 'dart:async';

import 'package:get/get.dart';
import 'package:stackfood_multivendor/features/countdown/models/countdown_model.dart';

class CountdownController extends GetxController {
  final CountdownModel countdownModel;
  
  CountdownController({CountdownModel? countdownModel}) 
      : countdownModel = countdownModel ?? CountdownModel.defaultLaunch();

  final RxMap<String, int> remainingTime = RxMap<String, int>();
  final RxBool isLaunched = false.obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _updateCountdown();
    // Update countdown every second
    Timer.periodic(const Duration(seconds: 1), (_) {
      _updateCountdown();
    });
  }

  void _updateCountdown() {
    final time = countdownModel.getRemainingTime();
    remainingTime.value = time;
    isLaunched.value = countdownModel.isLaunched;
    isLoading.value = false;
    update(); // Force UI update for GetBuilder
  }

  String get formattedDays => remainingTime['days']!.toString().padLeft(2, '0');
  String get formattedHours => remainingTime['hours']!.toString().padLeft(2, '0');
  String get formattedMinutes => remainingTime['minutes']!.toString().padLeft(2, '0');
  String get formattedSeconds => remainingTime['seconds']!.toString().padLeft(2, '0');

  String get launchDateFormatted => countdownModel.launchDate.toString().substring(0, 16).replaceAll('T', ' ');

  void resetCountdown() {
    Get.delete<CountdownController>(force: true);
    Get.put(CountdownController());
  }
}
