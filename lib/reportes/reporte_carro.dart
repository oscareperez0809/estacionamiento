import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

Future<void> generarReporteCarrosPDF(
  BuildContext context,
  List<Map<String, dynamic>> carros,
) async {
  // 📌 Cálculo total de importes
  double totalImporte = 0;
  for (var car in carros) {
    final value = double.tryParse(car["importe"].toString()) ?? 0;
    totalImporte += value;
  }

  // 📌 Crear documento PDF
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // 🏷️ Título del reporte
          pw.Text(
            "REPORTE DE SALIDA DE CARROS",
            style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
          ),

          pw.SizedBox(height: 20),

          // 📋 Tabla principal
          pw.Table(
            border: pw.TableBorder.all(),
            columnWidths: {
              0: pw.FixedColumnWidth(90),
              1: pw.FixedColumnWidth(90),
              2: pw.FixedColumnWidth(70),
              3: pw.FixedColumnWidth(70),
              4: pw.FixedColumnWidth(70), // columna agregado Importe
            },
            children: [
              // 🔝 Encabezados
              pw.TableRow(
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromInt(0xFFE0E0E0),
                ),
                children: [
                  pw.Padding(
                    padding: pw.EdgeInsets.all(5),
                    child: pw.Text("Entrada"),
                  ),
                  pw.Padding(
                    padding: pw.EdgeInsets.all(5),
                    child: pw.Text("Vehiculo"),
                  ),
                  pw.Padding(
                    padding: pw.EdgeInsets.all(5),
                    child: pw.Text("Placas"),
                  ),
                  pw.Padding(
                    padding: pw.EdgeInsets.all(5),
                    child: pw.Text("Salida"),
                  ),
                  pw.Padding(
                    padding: pw.EdgeInsets.all(5),
                    child: pw.Text("Importe"),
                  ),
                ],
              ),

              // 🔄 Filas dinámicas
              ...carros.map(
                (car) => pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: pw.EdgeInsets.all(5),
                      child: pw.Text(car["hora_entrada"] ?? ""),
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.all(5),
                      child: pw.Text(car["vehiculo"] ?? ""),
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.all(5),
                      child: pw.Text(car["placas"] ?? ""),
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.all(5),
                      child: pw.Text(car["hora_salida"] ?? ""),
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.all(5),
                      child: pw.Text("\$${car["importe"]}"),
                    ),
                  ],
                ),
              ),

              // 🔥 Fila final con el total
              pw.TableRow(
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromInt(0xFFD0FFD0),
                ),
                children: [
                  pw.Padding(padding: pw.EdgeInsets.all(5), child: pw.Text("")),
                  pw.Padding(padding: pw.EdgeInsets.all(5), child: pw.Text("")),
                  pw.Padding(padding: pw.EdgeInsets.all(5), child: pw.Text("")),
                  pw.Padding(
                    padding: pw.EdgeInsets.all(5),
                    child: pw.Text(
                      "TOTAL:",
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                  pw.Padding(
                    padding: pw.EdgeInsets.all(5),
                    child: pw.Text(
                      "\$${totalImporte.toStringAsFixed(2)}",
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ),
  );

  // 📁 Directorio temporal para guardar el PDF
  final dir = await getTemporaryDirectory();
  final file = File("${dir.path}/reporte_carros.pdf");

  // 💾 Guardar archivo
  await file.writeAsBytes(await pdf.save());

  // 📂 Abrir archivo
  final result = await OpenFile.open(file.path);
  debugPrint("RESULTADO OPEN FILE -> $result");
}
