import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:estacionamiento/editar/editar_carro.dart';
import 'package:estacionamiento/reportes/reporte_carro.dart'; // <-- IMPORTANTE

class CarrosTab extends StatefulWidget {
  const CarrosTab({super.key});

  @override
  State<CarrosTab> createState() => _CarrosTabState();
}

class _CarrosTabState extends State<CarrosTab> {
  final supabase = Supabase.instance.client;

  late Future<List<Map<String, dynamic>>> futureCarros;

  // 🔎 Controlador del buscador
  final TextEditingController buscadorCtrl = TextEditingController();

  // Lista filtrada
  List<Map<String, dynamic>> carrosFiltrados = [];
  List<Map<String, dynamic>> carrosOriginal = [];

  @override
  void initState() {
    super.initState();
    futureCarros = cargarCarros();
  }

  Future<List<Map<String, dynamic>>> cargarCarros() async {
    final data = await supabase
        .from('Carros_Estacionados')
        .select('*')
        .order('id', ascending: false);

    carrosOriginal = List<Map<String, dynamic>>.from(data);
    carrosFiltrados = List<Map<String, dynamic>>.from(data);

    return data;
  }

  // 🔎 FILTRAR
  void filtrarCarros(String texto) {
    texto = texto.toLowerCase();

    setState(() {
      carrosFiltrados = carrosOriginal.where((car) {
        final placas = car["placas"].toString().toLowerCase();
        final vehiculo = car["vehiculo"].toString().toLowerCase();

        return placas.contains(texto) || vehiculo.contains(texto);
      }).toList();
    });
  }

  // 🔹 GENERAR REPORTE
  void generarReporteCarros() {
    generarReporteCarrosPDF(context, carrosFiltrados);
  }

  // ----------------------- EDITAR -----------------------
  void editarCarro(Map<String, dynamic> car) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditarCarroPage(carro: car)),
    );

    setState(() {
      futureCarros = cargarCarros();
    });
  }

  // ----------------------- ELIMINAR -----------------------
  Future<void> eliminarCarro(int id) async {
    await supabase.from('Carros_Estacionados').delete().eq("id", id);

    setState(() {
      futureCarros = cargarCarros();
    });
  }

  // ----------------------- VER ----------------------------
  void verCarro(Map<String, dynamic> car) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Detalles del carro"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Placas: ${car['placas']}"),
            Text("Vehículo: ${car['vehiculo']}"),
            Text("Categoría: ${car['categoria']}"),
            Text("Entrada: ${car['fecha_entrada']} ${car['hora_entrada']}"),
            Text(
              "Salida: ${car['fecha_salida'] ?? '--'} ${car['hora_salida'] ?? '--'}",
            ),
            Text("Tiempo: ${car['tiempo'] ?? '--'}"),
            Text("Importe: \$${car['importe']}"),
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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: futureCarros,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            // 🔎 BARRA DE BÚSQUEDA + PDF
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: buscadorCtrl,
                      onChanged: filtrarCarros,
                      decoration: InputDecoration(
                        hintText: "Buscar por placas o vehículo...",
                        prefixIcon: Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.grey.shade200,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // 🔹BOTÓN DE REPORTE
                  IconButton(
                    icon: const Icon(
                      Icons.picture_as_pdf,
                      size: 30,
                      color: Colors.red,
                    ),
                    onPressed: generarReporteCarros,
                  ),
                ],
              ),
            ),

            Expanded(
              child: carrosFiltrados.isEmpty
                  ? const Center(
                      child: Text(
                        "No se encontraron resultados",
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      itemCount: carrosFiltrados.length,
                      itemBuilder: (context, index) {
                        final car = carrosFiltrados[index];

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 3,
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              leading: const Icon(
                                Icons.directions_car,
                                size: 32,
                                color: Colors.blueAccent,
                              ),
                              title: Text(
                                car["placas"] ?? "Sin placas",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text("Vehículo: ${car["vehiculo"]}"),
                                  Text("Entrada:  ${car["hora_entrada"]}"),
                                  Text(
                                    "Salida:  ${car["hora_salida"] ?? '--'}",
                                  ),
                                  Text("Importe: \$${car["importe"]}"),
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
                                    onPressed: () => verCarro(car),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.blue,
                                    ),
                                    onPressed: () => editarCarro(car),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () => eliminarCarro(car["id"]),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}
