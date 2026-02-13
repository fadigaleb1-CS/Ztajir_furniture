import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:ztajir_furniture/data/models/order_model.dart';
import 'package:intl/intl.dart' as intl;
import 'package:ztajir_furniture/core/utiles/price_formatter.dart';

class PdfInvoiceService {
  // ألوان الهوية
  static const PdfColor primaryColor = PdfColor.fromInt(0xFF8B4513); // بني غامق
  static const PdfColor primaryColorLight = PdfColor.fromInt(
    0x338B4513,
  ); // شفاف 20%
  static const PdfColor primaryColorVeryLight = PdfColor.fromInt(
    0x1A8B4513,
  ); // شفاف 10%
  static const PdfColor lightColor = PdfColor.fromInt(0xFFFFFBF0); // بيج فاتح
  static const PdfColor greyColor = PdfColor.fromInt(0xFF808080);

  static Future<void> generateAndSaveInvoice(OrderModel orderData) async {
    final pdf = pw.Document();

    // تحميل الخطوط
    final ttf = await PdfGoogleFonts.cairoRegular();
    final ttfBold = await PdfGoogleFonts.cairoBold();

    final theme = pw.ThemeData.withFont(base: ttf, bold: ttfBold);

    pdf.addPage(
      pw.Page(
        theme: theme,
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              _buildHeader(orderData),
              pw.SizedBox(height: 20),
              pw.Divider(color: primaryColor, thickness: 2),
              pw.SizedBox(height: 20),
              _buildOrderDetailsGrid(orderData),
              pw.SizedBox(height: 30),
              _buildItemsTable(orderData),
              pw.SizedBox(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.start,
                children: [
                  pw.Container(width: 250, child: _buildTotals(orderData)),
                  pw.Expanded(child: pw.SizedBox()),
                ],
              ),
              pw.Spacer(),
              _buildFooter(),
            ],
          );
        },
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename:
          'Invoice_${orderData.orderNumber}_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
  }

  static pw.Widget _buildHeader(OrderModel data) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(
              "ZTAJIR FURNITURE",
              style: pw.TextStyle(
                fontSize: 20,
                fontWeight: pw.FontWeight.bold,
                color: primaryColor,
              ),
            ),
            pw.Text(
              "أناقة منزلك.. تبدأ من هنا",
              style: pw.TextStyle(fontSize: 10, color: greyColor),
            ),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              " فاتورة شراء",
              style: pw.TextStyle(
                fontSize: 28,
                fontWeight: pw.FontWeight.bold,
                color: primaryColor,
              ),
            ),
            pw.Text(
              "رقم الفاتورة: #${data.orderNumber}",
              style: pw.TextStyle(fontSize: 12, color: PdfColors.black),
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildOrderDetailsGrid(OrderModel data) {
    final dateStr = intl.DateFormat(
      'yyyy/MM/dd - HH:mm',
    ).format(data.createdAt);

    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: lightColor,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: primaryColorLight),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          _buildDetailItem("تاريخ الطلب", dateStr),
          _buildDetailItem(
            "طريقة الدفع",
            getPaymentMethodDisplayName(data.paymentMethod),
          ),
          _buildDetailItem("حالة الطلب", data.status),
        ],
      ),
    );
  }

  static pw.Widget _buildDetailItem(String title, String value) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(title, style: pw.TextStyle(color: greyColor, fontSize: 10)),
        pw.SizedBox(height: 4),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            fontSize: 12,
            color: PdfColors.black,
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildItemsTable(OrderModel data) {
    final headers = ['المجموع', 'سعر الوحدة', 'الكمية', 'المنتج'];

    return pw.Table(
      border: pw.TableBorder.all(color: primaryColorVeryLight, width: 1),
      columnWidths: {
        0: const pw.FlexColumnWidth(1.5),
        1: const pw.FlexColumnWidth(1.5),
        2: const pw.FlexColumnWidth(1),
        3: const pw.FlexColumnWidth(3),
      },
      children: [
        pw.TableRow(
          decoration: pw.BoxDecoration(color: primaryColor),
          children: headers
              .map(
                (h) => pw.Container(
                  padding: const pw.EdgeInsets.all(8),
                  alignment: pw.Alignment.center,
                  child: pw.Text(
                    h,
                    style: pw.TextStyle(
                      color: PdfColors.white,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        ...data.items.map((item) {
          return pw.TableRow(
            decoration: const pw.BoxDecoration(color: PdfColors.white),
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(
                  '${formatPrice(item.total)} ${data.currency}',
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(
                  '${formatPrice(item.price)} ${data.currency}',
                  textAlign: pw.TextAlign.center,
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(
                  '${item.quantity}',
                  textAlign: pw.TextAlign.center,
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(item.productName, textAlign: pw.TextAlign.right),
              ),
            ],
          );
        }).toList(),
      ],
    );
  }

  static pw.Widget _buildTotals(OrderModel data) {
    return pw.Column(
      children: [
        _buildTotalRow(
          "المجموع الفرعي",
          '${formatPrice(data.subTotal)} ${data.currency}',
        ),
        if (data.shippingCost > 0)
          _buildTotalRow(
            "رسوم الشحن",
            '${formatPrice(data.shippingCost)} ${data.currency}',
          ),
        if (data.tax > 0)
          _buildTotalRow(
            "الضريبة",
            '${formatPrice(data.tax)} ${data.currency}',
          ),
        if (data.discount > 0)
          _buildTotalRow(
            "الخصم",
            '- ${formatPrice(data.discount)} ${data.currency}',
            color: PdfColors.green700,
          ),
        pw.Divider(color: greyColor),
        _buildTotalRow(
          "الإجمالي النهائي",
          '${formatPrice(data.total)} ${data.currency}',
          isBold: true,
          fontSize: 16,
          color: primaryColor,
        ),
      ],
    );
  }

  static pw.Widget _buildTotalRow(
    String label,
    String value, {
    bool isBold = false,
    double fontSize = 12,
    PdfColor? color,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(fontSize: fontSize, color: greyColor),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: color ?? PdfColors.black,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildFooter() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Divider(color: primaryColor, thickness: 1),
        pw.SizedBox(height: 10),
        pw.Text(
          "شكراً لثقتكم واختياركم Ztajir Furniture",
          style: pw.TextStyle(
            color: primaryColor,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 5),
        pw.Text(
          "للإستفسار أو المساعدة يرجى التواصل معنا",
          style: pw.TextStyle(color: greyColor, fontSize: 10),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          "+967 774372566",
          style: pw.TextStyle(
            color: primaryColor,
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
          ),
          textDirection: pw.TextDirection.ltr,
        ),
      ],
    );
  }
}
