import 'package:flutter/material.dart';
import '../models/document.dart';
import '../services/excel_service.dart'; // Используем ExcelHelper

class ScannerScreen extends StatefulWidget {
  final Document document;

  ScannerScreen({required this.document});

  @override
  _ScannerScreenState createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final TextEditingController _scanController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ExcelHelper _excelHelper = ExcelHelper(); // Создаем экземпляр ExcelHelper

  @override
  void initState() {
    super.initState();
    _excelHelper.initializeFilePath(); // Инициализируем путь к файлу
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _scanController.dispose();
    super.dispose();
  }

  Future<void> _addCode(String code) async {
    if (code.isNotEmpty) {
      bool isUnique = await _excelHelper.isDataUnique(code);
      if (isUnique) {
        setState(() {
          widget.document.markingCodes.add(code);
          _scanController.clear();
        });
        try {
          await _excelHelper.addData(code);
          print('Excel-файл обновлен с кодом: $code');
        } catch (e) {
          print('Ошибка при обновлении Excel-файла: $e');
        }
      } else {
        print('Данный код уже существует в файле.');
      }
    } else {
      print('Ошибка: код пустой');
    }
    FocusScope.of(context).requestFocus(_focusNode);
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
              onSubmitted: (value) => _addCode(value),
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
