import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

Future<void> generarReportePensionadosPDF(
  BuildContext context,
  List<Map<String, dynamic>> pensionados,
) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4.landscape, // <-- Orientación horizontal
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Center(
            child: pw.Text(
              "REPORTE DE PENSIONADOS",
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 20),

          pw.Table(
            border: pw.TableBorder.all(),
            defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
            columnWidths: {
              0: pw.FixedColumnWidth(40), // ID
              1: pw.FixedColumnWidth(100), // Nombre
              2: pw.FixedColumnWidth(100), // Apellido
              3: pw.FixedColumnWidth(80), // Teléfono
              4: pw.FixedColumnWidth(80), // Marca
              5: pw.FixedColumnWidth(80), // Categoria
              6: pw.FixedColumnWidth(70), // Placas
              7: pw.FixedColumnWidth(70), // Pago_Men
              8: pw.FixedColumnWidth(70), // Fecha_Inicio
              9: pw.FixedColumnWidth(70), // Fecha_Fin
            },
            children: [
              // Encabezado
              pw.TableRow(
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromInt(0xFFE0E0E0),
                ),
                children: [
                  pw.Padding(
                    padding: pw.EdgeInsets.all(5),
                    child: pw.Center(child: pw.Text("ID")),
                  ),
                  pw.Padding(
                    padding: pw.EdgeInsets.all(5),
                    child: pw.Center(child: pw.Text("Nombre")),
                  ),
                  pw.Padding(
                    padding: pw.EdgeInsets.all(5),
                    child: pw.Center(child: pw.Text("Apellido")),
                  ),
                  pw.Padding(
                    padding: pw.EdgeInsets.all(5),
                    child: pw.Center(child: pw.Text("Teléfono")),
                  ),
                  pw.Padding(
                    padding: pw.EdgeInsets.all(5),
                    child: pw.Center(child: pw.Text("Marca")),
                  ),
                  pw.Padding(
                    padding: pw.EdgeInsets.all(5),
                    child: pw.Center(child: pw.Text("Categoria")),
                  ),
                  pw.Padding(
                    padding: pw.EdgeInsets.all(5),
                    child: pw.Center(child: pw.Text("Placas")),
                  ),
                  pw.Padding(
                    padding: pw.EdgeInsets.all(5),
                    child: pw.Center(child: pw.Text("Pago Mensual")),
                  ),
                  pw.Padding(
                    padding: pw.EdgeInsets.all(5),
                    child: pw.Center(child: pw.Text("Inicio")),
                  ),
                  pw.Padding(
                    padding: pw.EdgeInsets.all(5),
                    child: pw.Center(child: pw.Text("Fin")),
                  ),
                ],
              ),

              // Filas dinámicas
              ...pensionados.map(
                (p) => pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: pw.EdgeInsets.all(5),
                      child: pw.Center(
                        child: pw.Text(p["id"]?.toString() ?? ""),
                      ),
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.all(5),
                      child: pw.Center(child: pw.Text(p["Nombre"] ?? "")),
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.all(5),
                      child: pw.Center(child: pw.Text(p["Apellido"] ?? "")),
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.all(5),
                      child: pw.Center(
                        child: pw.Text(p["Teléfono"]?.toString() ?? ""),
                      ),
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.all(5),
                      child: pw.Center(child: pw.Text(p["Marca"] ?? "")),
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.all(5),
                      child: pw.Center(child: pw.Text(p["Categoria"] ?? "")),
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.all(5),
                      child: pw.Center(child: pw.Text(p["Placas"] ?? "")),
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.all(5),
                      child: pw.Center(
                        child: pw.Text("\$${p["Pago_Men"] ?? ""}"),
                      ),
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.all(5),
                      child: pw.Center(
                        child: pw.Text(p["Fecha_Inicio"]?.toString() ?? ""),
                      ),
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.all(5),
                      child: pw.Center(
                        child: pw.Text(p["Fecha_Fin"]?.toString() ?? ""),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );

  // 🔥 DIRECTORIO PARA ANDROID / IOS
  final dir = await getTemporaryDirectory();
  final file = File("${dir.path}/reporte_pensionados.pdf");

  await file.writeAsBytes(await pdf.save());

  // 🔥 Abrir PDF automáticamente
  final result = await OpenFile.open(file.path);
  debugPrint("RESULTADO OPEN FILE -> $result");
}
