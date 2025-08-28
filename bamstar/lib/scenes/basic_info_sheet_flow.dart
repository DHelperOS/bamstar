import 'package:flutter/material.dart';
import 'basic_info_page.dart';

// 기존 Settings에서 Navigator.push(basicInfoSheetRoute()) 로 호출하는 진입점 유지
Route<void> basicInfoSheetRoute() {
  return MaterialPageRoute<void>(builder: (context) => const BasicInfoPage());
}
