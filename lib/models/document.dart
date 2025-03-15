// models/document.dart
import 'dart:io';

class Document {
  String invoiceNumber;
  List<String> markingCodes;
  File? excelFile; // Поле для хранения файла

  Document({
    required this.invoiceNumber,
    this.markingCodes = const [],
    this.excelFile,
  });
}