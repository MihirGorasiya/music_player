import 'package:get/get.dart';

class Controller extends GetxController {
  var isDrawerOpen = false.obs;
  var musicPosition = '00:00'.obs;
  var musicLength = '00:00'.obs;
  var musicLengthInt = 1.obs;
  var sliderValue = 0.25.obs;
}
