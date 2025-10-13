import 'dart:io';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import '../models/expense.dart';

class ExportService {
  static Future<String> exportToPDF(List<Expense> expenses) async {
    final pdf = pw.Document();

    // Format tanggal
    final now = DateTime.now();
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');

    // Hitung total pengeluaran
    final total = expenses.fold<double>(0, (sum, e) => sum + e.amount);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) => [
          pw.Center(
            child: pw.Text(
              'Laporan Pengeluaran',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text('Tanggal export: ${dateFormat.format(now)}'),
          pw.SizedBox(height: 20),

          pw.Table.fromTextArray(
            border: pw.TableBorder.all(),
            headers: ['Judul', 'Kategori', 'Tanggal', 'Jumlah'],
            data: expenses.map((e) {
              return [
                e.title,
                e.category,
                DateFormat('dd/MM/yyyy').format(e.date),
                'Rp ${e.amount.toStringAsFixed(2)}',
              ];
            }).toList(),
            cellAlignment: pw.Alignment.centerLeft,
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
          ),
          pw.SizedBox(height: 20),
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text(
              'Total: Rp ${total.toStringAsFixed(2)}',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/laporan_pengeluaran.pdf';
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());
    return filePath;
  }
}
