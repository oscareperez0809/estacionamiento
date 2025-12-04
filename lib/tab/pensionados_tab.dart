import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:estacionamiento/editar/editar_pensionado.dart';
import 'package:estacionamiento/reportes/reporte_pensionado.dart';

class Pensionado {
  final int id;
  final String nombre;
  final String apellido;
  final String telefono;
  final String marca;
  final String categoria;
  final String placas;
  final double pagoMensual;
  final DateTime? fechaInicio;
  final ValueNotifier<DateTime?> fechaFin;

  Pensionado({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.telefono,
    required this.marca,
    required this.categoria,
    required this.placas,
    required this.pagoMensual,
    this.fechaInicio,
    DateTime? fechaFin,
  }) : fechaFin = ValueNotifier(fechaFin);
}

class PensionadosTab extends StatefulWidget {
  const PensionadosTab({super.key});

  @override
  State<PensionadosTab> createState() => _PensionadosTabState();
}

class _PensionadosTabState extends State<PensionadosTab> {
  final supabase = Supabase.instance.client;

  List<Pensionado> pensionadosOriginal = [];
  List<Pensionado> pensionadosFiltrados = [];
  String filtroTelefono = "";

  final formatoFecha = DateFormat('dd-MM-yyyy');

  @override
  void initState() {
    super.initState();
    cargarPensionados();
  }

  Future<void> cargarPensionados() async {
    final data = await supabase
        .from('Pensionados')
        .select('*')
        .order('id', ascending: false);

    final lista = List<Map<String, dynamic>>.from(data as List);

    setState(() {
      pensionadosOriginal = lista.map<Pensionado>((p) {
        return Pensionado(
          id: p['id'],
          nombre: p['Nombre'] ?? '',
          apellido: p['Apellido'] ?? '',
          telefono: p['Teléfono']?.toString() ?? '',
          marca: p['Marca'] ?? '',
          categoria: p['Categoria'] ?? '',
          placas: p['Placas'] ?? '',
          pagoMensual: (p['Pago_Men'] ?? 0).toDouble(),
          fechaInicio: DateTime.tryParse(p['Fecha_Inicio'] ?? ''),
          fechaFin: DateTime.tryParse(p['Fecha_Fin'] ?? ''),
        );
      }).toList();

      pensionadosFiltrados = List<Pensionado>.from(pensionadosOriginal);
    });
  }

  void filtrarPensionados(String texto) {
    texto = texto.toLowerCase();
    setState(() {
      pensionadosFiltrados = pensionadosOriginal.where((p) {
        return p.telefono.toLowerCase().contains(texto);
      }).toList();
    });
  }

  void generarReportePensionados() {
    generarReportePensionadosPDF(
      context,
      pensionadosFiltrados.map((p) {
        return {
          'Nombre': p.nombre,
          'Apellido': p.apellido,
          'Teléfono': p.telefono,
          'Marca': p.marca,
          'Categoria': p.categoria,
          'Placas': p.placas,
          'Pago_Men': p.pagoMensual,
          'Fecha_Inicio': p.fechaInicio != null
              ? formatoFecha.format(p.fechaInicio!)
              : '',
          'Fecha_Fin': p.fechaFin.value != null
              ? formatoFecha.format(p.fechaFin.value!)
              : '',
        };
      }).toList(),
    );
  }

  void verPensionado(Pensionado p) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Detalles de ${p.nombre} ${p.apellido}"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Nombre: ${p.nombre}"),
            Text("Apellido: ${p.apellido}"),
            Text("Teléfono: ${p.telefono}"),
            Text("Marca: ${p.marca}"),
            Text("Categoría: ${p.categoria}"),
            Text("Placas: ${p.placas}"),
            Text("Pago Mensual: \$${p.pagoMensual}"),
            Text(
              "Fecha Inicio: ${p.fechaInicio != null ? formatoFecha.format(p.fechaInicio!) : '--'}",
            ),
            Text(
              "Fecha Fin: ${p.fechaFin.value != null ? formatoFecha.format(p.fechaFin.value!) : '--'}",
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text("Cerrar"),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void editarPensionado(Pensionado p) async {
    final actualizado = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditarPensionadoPage(pensionado: p)),
    );

    if (actualizado == true) {
      cargarPensionados();
    }
  }

  void eliminarPensionado(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirmar eliminación"),
        content: const Text("¿Seguro que deseas eliminar este pensionado?"),
        actions: [
          TextButton(
            child: const Text("Cancelar"),
            onPressed: () => Navigator.pop(context, false),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Eliminar"),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await supabase.from('Pensionados').delete().eq("id", id);
      cargarPensionados();
    }
  }

  Widget _iconoMensualidad(Pensionado p) {
    return ValueListenableBuilder<DateTime?>(
      valueListenable: p.fechaFin,
      builder: (_, fechaFin, __) {
        if (fechaFin == null)
          return const Icon(Icons.circle, color: Colors.grey, size: 30);

        final diferencia = fechaFin.difference(DateTime.now()).inDays;
        Color color;
        if (diferencia < 0) {
          color = Colors.red;
        } else if (diferencia <= 7) {
          color = Colors.yellow;
        } else {
          color = Colors.green;
        }

        return Icon(Icons.circle, color: color, size: 30);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Buscar por teléfono",
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: filtrarPensionados,
                ),
              ),
              const SizedBox(width: 10),
              IconButton(
                icon: const Icon(
                  Icons.picture_as_pdf,
                  size: 30,
                  color: Colors.red,
                ),
                onPressed: generarReportePensionados,
              ),
            ],
          ),
        ),
        Expanded(
          child: pensionadosFiltrados.isEmpty
              ? const Center(
                  child: Text(
                    "No se encontraron coincidencias",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: pensionadosFiltrados.length,
                  itemBuilder: (context, index) {
                    final p = pensionadosFiltrados[index];
                    final nombreCompleto = "${p.nombre} ${p.apellido}".trim();

                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: _iconoMensualidad(p),
                        title: Text(
                          nombreCompleto.isEmpty
                              ? "Sin nombre"
                              : nombreCompleto,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text("Marca: ${p.marca}"),
                            Text("Categoría: ${p.categoria}"),
                            Text(
                              "Fecha inicio: ${p.fechaInicio != null ? formatoFecha.format(p.fechaInicio!) : '--'}",
                            ),
                            Text(
                              "Fecha fin: ${p.fechaFin.value != null ? formatoFecha.format(p.fechaFin.value!) : '--'}",
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.visibility,
                                color: Colors.green,
                              ),
                              onPressed: () => verPensionado(p),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => editarPensionado(p),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => eliminarPensionado(p.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
