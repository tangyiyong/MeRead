import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meread/helpers/constant_helper.dart';
import 'package:meread/helpers/dio_helper.dart';
import 'package:meread/helpers/log_helper.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateHelper {
  /// Check update
  static Future<void> checkUpdate() async {
    LogHelper.i('[update]: Start check update.');
    Get.snackbar(
      'info'.tr,
      'checkingForUpdates'.tr,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(12),
    );
    try {
      final response = await DioHelper.get(
        'https://github.com/gvenusleo/MeRead/releases/latest',
      );
      final String title =
          response.data.split('<title>')[1].split('</title>')[0];
      final String latestVersion = title.split(' ')[1];
      if (latestVersion == ConstantHelp.appVersion.substring(1, 6)) {
        Get.closeAllSnackbars();
        Get.snackbar(
          'info'.tr,
          'alreadyLatestVersion'.tr,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(12),
        );
        LogHelper.i(
            '[update]: Already the latest version: ${ConstantHelp.appVersion}.');
      } else {
        Get.closeAllSnackbars();
        Get.dialog(
          AlertDialog(
            icon: const Icon(Icons.update_outlined),
            title: Text('newVersionAvailable'.tr),
            content: Text('downloadInfo'.tr),
            actions: [
              TextButton(
                onPressed: () {
                  launchUrl(
                    Uri.parse(
                        'https://github.com/gvenusleo/MeRead/releases/latest'),
                    mode: LaunchMode.externalApplication,
                  );
                },
                child: Text('downloadNow'.tr),
              ),
              TextButton(
                onPressed: () => Get.back(),
                child: Text('temporarilyCancel'.tr),
              ),
            ],
          ),
        );
        LogHelper.i(
            '[update]: Found new version: $latestVersion, current version: ${ConstantHelp.appVersion}');
      }
    } catch (e) {
      Get.snackbar('error'.tr, 'checkUpdateError'.tr);
    }
  }
}
