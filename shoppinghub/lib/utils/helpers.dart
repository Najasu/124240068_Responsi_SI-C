import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showSnack(String title, String message) {
  Get.snackbar(
    title,
    message,
    snackPosition: SnackPosition.BOTTOM,
    margin: const EdgeInsets.all(16),
    borderRadius: 12,
    backgroundColor: Colors.black87,
    colorText: Colors.white,
    duration: const Duration(seconds: 2),
  );
}

const errorMessage =
    'Gagal memuat data.\nPeriksa koneksi internet kamu lalu coba lagi.';

// Color statusColor(String status) {
//   if (status == 'Alive') return Colors.green;
//   if (status == 'Dead') return Colors.red;
//   return Colors.grey;
// }
