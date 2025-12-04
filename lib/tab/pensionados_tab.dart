import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:estacionamiento/editar/editar_pensionado.dart';
import 'package:estacionamiento/reportes/reporte_pensionado.dart';

/// Clase que representa un pensionado
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

  /// Usamos ValueNotifier para reaccionar al cambio de fecha fin
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

/// Vista principal de la pestaña de pensionados
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

  /// Formato deseado para mostrar fechas
  final formatoFecha = DateFormat('dd-MM-yyyy');

  @override
  void initState() {
    super.initState();
    cargarPensionados();
  }

  /// Convierte cadena Fecha_Fin a DateTime sin mostrar T00:00:00
  DateTime? parsearFecha(dynamic fecha) {
    if (fecha == null || fecha.toString().trim().isEmpty) return null;

    try {
      return DateTime.parse(fecha.toString());
    } catch (_) {
      return null;
    }
  }

  /// Carga los pensionados desde Supabase
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

          /// Convertimos la fecha sin mostrar T 00:00:00
          fechaInicio: parsearFecha(p['Fecha_Inicio']),
          fechaFin: parsearFecha(p['Fecha_Fin']),
        );
      }).toList();

      pensionadosFiltrados = List<Pensionado>.from(pensionadosOriginal);
    });
  }

  /// Filtro por teléfono
  void filtrarPensionados(String texto) {
    texto = texto.toLowerCase();
    setState(() {
      pensionadosFiltrados = pensionadosOriginal.where((p) {
        return p.telefono.toLowerCase().contains(texto);
      }).toList();
    });
  }

  /// Genera reporte PDF con fechas ya formateadas
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

          /// Convertimos fechas al formato correcto
          'Fecha_Inicio': p.fechaInicio != null
              ? formatoFecha.format(p.fechaInicio!)
              : '--',

          'Fecha_Fin': p.fechaFin.value != null
              ? formatoFecha.format(p.fechaFin.value!)
              : '--',
        };
      }).toList(),
    );
  }

  /// Muestra ventana con detalles del pensionado
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

            /// Formato correcto sin T00:00:00
            Text(
              "Fecha Inicio: "
              "${p.fechaInicio != null ? formatoFecha.format(p.fechaInicio!) : '--'}",
            ),

            Text(
              "Fecha Fin: "
              "${p.fechaFin.value != null ? formatoFecha.format(p.fechaFin.value!) : '--'}",
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

  /// Abre página para editar pensionado
  void editarPensionado(Pensionado p) async {
    final actualizado = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditarPensionadoPage(pensionado: p)),
    );

    /// Si hubo cambios, recargamos la lista
    if (actualizado == true) {
      cargarPensionados();
    }
  }

  /// Elimina un registro de Supabase
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

  /// Icono que indica días restantes del pago mensual
  Widget _iconoMensualidad(Pensionado p) {
    return ValueListenableBuilder<DateTime?>(
      valueListenable: p.fechaFin,
      builder: (_, fechaFin, __) {
        if (fechaFin == null) {
          return const Icon(Icons.circle, color: Colors.grey, size: 30);
        }

        final diferencia = fechaFin.difference(DateTime.now()).inDays;

        Color color;

        if (diferencia < 0) {
          color = Colors.red; // vencido
        } else if (diferencia <= 7) {
          color = Colors.yellow; // por vencer
        } else {
          color = Colors.green; // al corriente
        }

        return Icon(Icons.circle, color: color, size: 30);
      },
    );
  }

  /// UI principal de la pestaña
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        /// BUSCADOR + PDF
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

              /// Botón de PDF
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

        /// LISTA DE PENSIONADOS
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

                        /// Icono indicador de mensualidad
                        leading: _iconoMensualidad(p),

                        /// Título (nombre)
                        title: Text(
                          nombreCompleto.isEmpty
                              ? "Sin nombre"
                              : nombreCompleto,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        /// SUBTÍTULO (datos)
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text("Marca: ${p.marca}"),
                            Text("Categoría: ${p.categoria}"),

                            /// Formateo correcto de fecha
                            Text(
                              "Fecha inicio: "
                              "${p.fechaInicio != null ? formatoFecha.format(p.fechaInicio!) : '--'}",
                            ),

                            Text(
                              "Fecha fin: "
                              "${p.fechaFin.value != null ? formatoFecha.format(p.fechaFin.value!) : '--'}",
                            ),
                          ],
                        ),

                        /// BOTONES (ver, editar, borrar)
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
