import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:estacionamiento/editar/editar_carro.dart';

class CarrosTab extends StatefulWidget {
  const CarrosTab({super.key});

  @override
  State<CarrosTab> createState() => _CarrosTabState();
}

class _CarrosTabState extends State<CarrosTab> {
  final supabase = Supabase.instance.client;

  late Future<List<Map<String, dynamic>>> futureCarros;

  @override
  void initState() {
    super.initState();
    futureCarros = cargarCarros();
  }

  Future<List<Map<String, dynamic>>> cargarCarros() async {
    final data = await supabase.from('Carros_Estacionados').select('*');
    return data;
  }

  void editarCarro(Map<String, dynamic> car) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditarCarroPage(carro: car)),
    );

    // 🔥 Recargar después de regresar
    setState(() {
      futureCarros = cargarCarros();
    });
  }
  

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: futureCarros,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final carros = snapshot.data!;

        if (carros.isEmpty) {
          return const Center(
            child: Text(
              "No hay carros estacionados",
              style: TextStyle(fontSize: 16),
            ),
          );
        }

        return ListView.builder(
          itemCount: carros.length,
          itemBuilder: (context, index) {
            final car = carros[index];

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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

                      Text(
                        "Vehículo: ${car["vehiculo"] ?? "Sin vehículo"}",
                        style: const TextStyle(fontSize: 14),
                      ),

                      const SizedBox(height: 2),

                      Text(
                        "Categoría: ${car["categoria"] ?? "Sin categoría"}",
                        style: const TextStyle(fontSize: 14),
                      ),

                      const SizedBox(height: 2),

                      Text(
                        "Entrada: ${car["fecha_entrada"] ?? '--'}  ${car["hora_entrada"] ?? '--'}",
                        style: const TextStyle(fontSize: 14),
                      ),

                      const SizedBox(height: 2),

                      Text(
                        "Salida: ${car["fecha_salida"] ?? '--'}  ${car["hora_salida"] ?? '--'}",
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),

                  trailing: IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => editarCarro(car),
                  ),
                  
                ),
              ),
            );
          },
        );
      },
    );
  }
}
