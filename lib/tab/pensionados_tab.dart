import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:estacionamiento/editar/editar_pensionado.dart';

class PensionadosTab extends StatefulWidget {
  const PensionadosTab({super.key});

  @override
  State<PensionadosTab> createState() => _PensionadosTabState();
}

class _PensionadosTabState extends State<PensionadosTab> {
  final supabase = Supabase.instance.client;

  late Future<List<Map<String, dynamic>>> futurePensionados;

  String filtroTelefono = ""; // 🔍 ← buscador

  @override
  void initState() {
    super.initState();
    futurePensionados = cargarPensionados();
  }

  Future<List<Map<String, dynamic>>> cargarPensionados() async {
    return await supabase.from('Pensionados').select('*');
  }

  // 🔵 VER
  void verPensionado(Map<String, dynamic> p) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Detalles del pensionado"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Nombre: ${p['Nombre']} ${p['Apellido']}"),
            Text("Teléfono: ${p['Teléfono'] ?? '--'}"),
            Text("Marca: ${p['Marca']}"),
            Text("Categoría: ${p['Categoria']}"),
            Text("Placas: ${p['Placas']}"),
            Text("Pago mensual: \$${p['Pago_Men']}"),
            Text("Inicio: ${p['Fecha_Inicio'] ?? '--'}"),
            Text("Fin: ${p['Fecha_Fin'] ?? '--'}"),
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

  // 🟢 EDITAR
  void editarPensionado(Map<String, dynamic> p) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditarPensionadoPage(pensionado: p)),
    );

    setState(() {
      futurePensionados = cargarPensionados();
    });
  }

  // 🔴 ELIMINAR
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

      setState(() {
        futurePensionados = cargarPensionados();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: futurePensionados,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final pens = snapshot.data!;

        // 🔍 FILTRADO AQUÍ
        final filtrados = pens.where((p) {
          final tel = (p["Teléfono"] ?? "").toString();
          return tel.contains(filtroTelefono);
        }).toList();

        return Column(
          children: [
            // 🔵 BARRA DE BÚSQUEDA
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Buscar por teléfono",
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    filtroTelefono = value.trim();
                  });
                },
              ),
            ),

            Expanded(
              child: filtrados.isEmpty
                  ? const Center(
                      child: Text(
                        "No se encontraron coincidencias",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: filtrados.length,
                      itemBuilder: (context, index) {
                        final p = filtrados[index];

                        final nombreCompleto =
                            "${p['Nombre'] ?? ''} ${p['Apellido'] ?? ''}"
                                .trim();

                        return Card(
                          elevation: 3,
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),

                            leading: const Icon(
                              Icons.person,
                              size: 35,
                              color: Colors.blueAccent,
                            ),

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
                                Text("Teléfono: ${p['Teléfono'] ?? '--'}"),
                                Text("Marca: ${p['Marca']}"),
                                Text("Categoría: ${p['Categoria']}"),
                                Text("Placas: ${p['Placas']}"),
                                Text("Pago mensual: \$${p['Pago_Men']}"),
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
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.blue,
                                  ),
                                  onPressed: () => editarPensionado(p),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => eliminarPensionado(p["id"]),
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
      },
    );
  }
}
