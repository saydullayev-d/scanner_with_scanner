// services/excel_service.dart
import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';

class ExcelService {
  Future<File> createExcelFile(String invoiceNumber) async {
    var excel = Excel.createExcel();
    Sheet sheet = excel['Sheet1'];

    // Добавляем заголовки с использованием TextCellValue
    sheet.appendRow([
      TextCellValue('Номер накладной'),
      TextCellValue('Код маркировки'),
    ]);
    sheet.appendRow([
      TextCellValue(invoiceNumber),
      TextCellValue(''),
    ]);

    // Получаем путь для сохранения файла
    final directory = await getTemporaryDirectory();
    final filePath = '${directory.path}/накладная_$invoiceNumber.xlsx';
    final file = File(filePath);

    // Сохраняем файл
    final excelBytes = excel.encode();
    await file.writeAsBytes(excelBytes!);

    return file;
  }

  Future<void> updateExcelFile(File file, String invoiceNumber, List<String> markingCodes) async {
    var excel = Excel.decodeBytes(await file.readAsBytes());
    Sheet sheet = excel['Sheet1'];

    // Очищаем старые данные (кроме заголовков)
    for (int i = sheet.maxRows - 1; i > 0; i--) {
      sheet.removeRow(i);
    }

    // Добавляем новые данные с использованием TextCellValue
    for (String code in markingCodes) {
      sheet.appendRow([
        TextCellValue(invoiceNumber),
        TextCellValue(code),
      ]);
    }

    // Сохраняем обновленный файл
    final excelBytes = excel.encode();
    await file.writeAsBytes(excelBytes!);
  }
}