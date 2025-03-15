// screens/scanner_screen.dart
import 'package:flutter/material.dart';
import '../models/document.dart';
import '../services/excel_service.dart'; // Импортируем ExcelService

class ScannerScreen extends StatefulWidget {
  final Document document;

  ScannerScreen({required this.document});

  @override
  _ScannerScreenState createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final TextEditingController _scanController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ExcelService _excelService =
      ExcelService(); // Создаем экземпляр ExcelService

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    FocusScope.of(context).requestFocus(_focusNode);
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _scanController.dispose();
    super.dispose();
  }

  Future<void> _addCode(String code) async {
    if (code.isNotEmpty && widget.document.excelFile != null) {
      setState(() {
        widget.document.markingCodes.add(code);
        _scanController.clear();
      });
      // Обновляем Excel-файл
      try {
        await _excelService.updateExcelFile(
          widget.document.excelFile!,
          widget.document.invoiceNumber,
          widget.document.markingCodes,
        );
        print('Excel-файл обновлен с кодом: $code');
      } catch (e) {
        print('Ошибка при обновлении Excel-файла: $e');
      }
    } else {
      print('Ошибка: код пустой или файл не существует');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Сканер для ${widget.document.invoiceNumber}'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _scanController,
              focusNode: _focusNode,
              decoration: InputDecoration(
                labelText: 'Отсканируйте код',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (value) {
                _addCode(value); // Добавляем код и обновляем файл
                FocusScope.of(context).requestFocus(_focusNode);
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: widget.document.markingCodes.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(widget.document.markingCodes[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
