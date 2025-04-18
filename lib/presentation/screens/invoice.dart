import 'dart:io';

import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/models/cart.dart';

class InvoiceScreen extends StatefulWidget {
  final List<CartItem> cartItems;
  final DateTime purchaseDate;

  const InvoiceScreen({
    super.key,
    required this.cartItems,
    required this.purchaseDate,
  });

  @override
  State<InvoiceScreen> createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen> {
  double get totalPrice {
    return widget.cartItems
        .fold(0, (sum, item) => sum + (item.item.price * item.quantity));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Close button
          Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.fromLTRB(12, 16, 0, 0),
            child: IconButton(
              icon: const Icon(
                Icons.close,
                size: 25,
                color: Color(0XFF315472),
              ),
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
            ),
          ),

          // Invoice content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Invoice header
                  Text(
                    "INVOICE",
                    style: GoogleFonts.inter(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF315472),
                    ),
                  ),
                  const SizedBox(height: 0),

                  // Date
                  Text(
                    "Tanggal: \n${_formatDate(widget.purchaseDate)}",
                    style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF315472)),
                  ),
                  const SizedBox(height: 6),

                  // Table header
                  _buildTableRow(
                    isHeader: true,
                    values: ['Name', 'Price', 'Qty', 'Total'],
                  ),
                  const SizedBox(height: 12),

                  // Divider
                  const Divider(thickness: 1),
                  const SizedBox(height: 12),

                  // Invoice items
                  ...widget.cartItems
                      .map((item) => Column(
                            children: [
                              _buildTableRow(
                                values: [
                                  item.item.name,
                                  'Rp.${item.item.price}',
                                  '${item.quantity}',
                                  'Rp.${(item.item.price * item.quantity).toStringAsFixed(0)}',
                                ],
                              ),
                              const SizedBox(height: 12),
                            ],
                          ))
                      .toList(),

                  // Total
                  const Divider(thickness: 1),
                  const SizedBox(height: 16),
                  _buildTableRow(
                    isTotal: true,
                    values: [
                      'Total Belanja',
                      '',
                      '',
                      'Rp.${totalPrice.toStringAsFixed(0)}',
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(thickness: 1),
                  const SizedBox(height: 12),
                  Center(
                    child: ElevatedButton(
                      onPressed: () async {
                        try {
                          final file = await _generatePdf();
                          AnimatedSnackBar.material(
                                  'Invoice saved to ${file.path}',
                                  type: AnimatedSnackBarType.info)
                              .show(context);
                        } catch (e) {
                          AnimatedSnackBar.material(e.toString(),
                                  type: AnimatedSnackBarType.error)
                              .show(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(200, 40),
                        backgroundColor: Colors.greenAccent[400],
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Save',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Buttons
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 24),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          _shareInvoice();
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 40),
                          backgroundColor: const Color(0xFF315472),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Share',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          try {
                            final file = await _generatePdf();

                            // Optionally open the PDF preview
                            await Printing.layoutPdf(
                              onLayout: (PdfPageFormat format) async =>
                                  await file.readAsBytes(),
                            );
                          } catch (e) {
                            AnimatedSnackBar.material(e.toString(),
                                    type: AnimatedSnackBarType.error)
                                .show(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 40),
                          backgroundColor: const Color(0xFF315472),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Print',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 40),
                    backgroundColor: const Color(0xFF315472),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Selesai',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableRow({
    bool isHeader = false,
    bool isTotal = false,
    required List<String> values,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 3,
          child: Text(
            values[0],
            style: GoogleFonts.inter(
              fontSize: isHeader ? 16 : 14,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF315472),
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            values[1],
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: isHeader ? 16 : 14,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF315472),
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Text(
            values[2],
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: isHeader ? 16 : 14,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF315472),
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            values[3],
            textAlign: TextAlign.right,
            style: GoogleFonts.inter(
              fontSize: isHeader ? 16 : 14,
              fontWeight: FontWeight.bold,
              color: isTotal ? Colors.orange : const Color(0xFF315472),
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day} ${_getMonthName(date.month)} ${date.year}';
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }

  void _shareInvoice() async {
    try {
      final file = await _generatePdf();
      await Share.shareXFiles([XFile(file.path)], text: 'Here is your invoice');
    } catch (e) {
      AnimatedSnackBar.material(
        'Failed to share invoice: $e',
        type: AnimatedSnackBarType.error,
      ).show(context);
    }
  }

  Future<File> _generatePdf() async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.interRegular();
    final fontBold = await PdfGoogleFonts.interBold();

    pdf.addPage(
      pw.Page(
        theme: pw.ThemeData.withFont(
          base: font,
          bold: fontBold,
        ),
        margin: const pw.EdgeInsets.all(24),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Invoice header
              pw.Text(
                "INVOICE",
                style: pw.TextStyle(
                  fontSize: 28,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromInt(0xFF315472),
                ),
              ),
              pw.SizedBox(height: 16),

              // Date
              pw.Text(
                "Tanggal: ${_formatDate(widget.purchaseDate)}",
                style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromInt(0xFF315472),
                ),
              ),
              pw.SizedBox(height: 24),

              // Table header
              _buildPdfTableRow(
                isHeader: true,
                values: ['Name', 'Price', 'Qty', 'Total'],
              ),
              pw.SizedBox(height: 12),

              // Divider
              pw.Divider(thickness: 1, color: PdfColors.grey300),
              pw.SizedBox(height: 12),

              // Invoice items
              ...widget.cartItems
                  .map((item) => pw.Column(
                        children: [
                          _buildPdfTableRow(
                            values: [
                              item.item.name,
                              'Rp.${item.item.price}',
                              '${item.quantity}',
                              'Rp.${(item.item.price * item.quantity).toStringAsFixed(0)}',
                            ],
                          ),
                          pw.SizedBox(height: 12),
                        ],
                      ))
                  .toList(),

              // Total
              pw.Divider(thickness: 1, color: PdfColors.grey300),
              pw.SizedBox(height: 16),
              _buildPdfTableRow(
                isTotal: true,
                values: [
                  'Total Belanja',
                  '',
                  '',
                  'Rp.${totalPrice.toStringAsFixed(0)}',
                ],
              ),
              pw.SizedBox(height: 16),
              pw.Divider(thickness: 1, color: PdfColors.grey300),
            ],
          );
        },
      ),
    );

    // Get directory for saving
    final directory = await getApplicationDocumentsDirectory();
    final file = File(
        '${directory.path}/invoice_${DateTime.now().millisecondsSinceEpoch}.pdf');

    // Save PDF
    await file.writeAsBytes(await pdf.save());

    return file;
  }

  pw.Widget _buildPdfTableRow({
    bool isHeader = false,
    bool isTotal = false,
    required List<String> values,
  }) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Expanded(
          flex: 3,
          child: pw.Text(
            values[0],
            style: pw.TextStyle(
              fontSize: isHeader ? 16 : 14,
              fontWeight: isHeader || isTotal
                  ? pw.FontWeight.bold
                  : pw.FontWeight.normal,
              color: PdfColor.fromInt(0xFF315472),
            ),
          ),
        ),
        pw.Expanded(
          flex: 2,
          child: pw.Text(
            values[1],
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(
              fontSize: isHeader ? 16 : 14,
              fontWeight: isTotal ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: PdfColor.fromInt(0xFF315472),
            ),
          ),
        ),
        pw.Expanded(
          flex: 1,
          child: pw.Text(
            values[2],
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(
              fontSize: isHeader ? 16 : 14,
              fontWeight: isTotal ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: PdfColor.fromInt(0xFF315472),
            ),
          ),
        ),
        pw.Expanded(
          flex: 2,
          child: pw.Text(
            values[3],
            textAlign: pw.TextAlign.right,
            style: pw.TextStyle(
              fontSize: isHeader ? 16 : 14,
              fontWeight: isTotal ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: isTotal
                  ? PdfColor.fromInt(0xFFFFA500)
                  : PdfColor.fromInt(0xFF315472),
            ),
          ),
        ),
      ],
    );
  }
}
