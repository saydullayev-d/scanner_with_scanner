// screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import '../models/document.dart';
import 'package:intl/intl.dart';
import 'scanner_screen.dart';
import '../services/excel_service.dart'; // Импорт сервиса

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Document> documents = [];
  final ExcelService excelService = ExcelService();

  Future<String?> _showItemNumberDialog(BuildContext context) async {
    final TextEditingController controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text(
          'Введите Номер Накладной',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Номер Накладной',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            filled: true,
            fillColor: Colors.grey[200],
          ),
          keyboardType: TextInputType.text,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('ОК', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _addDocument() async {
    final itemNumber = await _showItemNumberDialog(context);
    if (itemNumber != null && itemNumber.isNotEmpty) {
      final currentDate = DateFormat('yyyyMMdd').format(DateTime.now());
      final invoiceNumber = '${itemNumber}_$currentDate';
      final file = await excelService.createExcelFile(invoiceNumber);
      setState(() {
        documents.add(Document(
          invoiceNumber: invoiceNumber,
          excelFile: file,
        ));
      });
    }
  }

  void _openScannerScreen(Document document) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScannerScreen(document: document),
      ),
    ).then((_) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Список документов',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueAccent, Colors.lightBlue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: documents.isEmpty
          ? Center(
              child: Text(
                'Нет доступных документов',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            )
          : ListView.builder(
              itemCount: documents.length,
              itemBuilder: (context, index) {
                final document = documents[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    title: Text(
                      'Накладная №${document.invoiceNumber}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text('Кодов: ${document.markingCodes.length}'),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    onTap: () => _openScannerScreen(document),
                    trailing: Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    IconButton(
      icon: Icon(Icons.qr_code_scanner, color: Colors.blueAccent),
      onPressed: () => _openScannerScreen(document),
    ),
    IconButton(
      icon: Icon(Icons.open_in_new, color: Colors.green),
      onPressed: () => OpenFile.open(document.excelFile!.path),
    ),
  ],
),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addDocument,
        child: const Icon(Icons.add, size: 28),
        tooltip: 'Добавить документ',
        foregroundColor: Colors.white,
        backgroundColor: Colors.blueAccent,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }
}