import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:estacionamiento/utils/iconos_marca.dart';
import 'package:estacionamiento/editar/editar_marca.dart';

class MarcaTab extends StatefulWidget {
  const MarcaTab({super.key});

  @override
  State<MarcaTab> createState() => _MarcaTabState();
}

class _MarcaTabState extends State<MarcaTab> {
  final supabase = Supabase.instance.client;

  List<dynamic> marcas = []; // Lista cruda de registros traída de Supabase
  bool cargando = true; // Flag de carga
  String filtro = ""; // Texto del filtro (buscar marca)

  @override
  void initState() {
    super.initState();
    cargarMarcas();
  }

  /// Carga las marcas desde Supabase y actualiza el estado.
  Future<void> cargarMarcas() async {
    try {
      final data = await supabase
          .from('marcas')
          .select()
          .order('marcas', ascending: true);
      setState(() {
        marcas = List<Map<String, dynamic>>.from(data as List);
        cargando = false;
      });
    } catch (e) {
      setState(() => cargando = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error al cargar las marcas: $e")));
    }
  }

  /// Borra la marca por id y recarga la lista.
  Future<void> borrarMarca(int id) async {
    try {
      await supabase.from('marcas').delete().eq('id', id);
      await cargarMarcas();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error al borrar: $e")));
    }
  }

  /// Muestra diálogo de confirmación para borrar.
  void confirmarBorrado(int id, String nombre) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirmar borrado"),
        content: Text("¿Eliminar la marca \"$nombre\"?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              borrarMarca(id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Eliminar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Mostrar loader mientras carga
    if (cargando) {
      return const Center(child: CircularProgressIndicator());
    }

    // Aplicar filtro (case-insensitive)
    final marcasFiltradas = marcas.where((m) {
      final nombre = (m["marcas"] ?? "").toString().toLowerCase();
      return nombre.contains(filtro.toLowerCase());
    }).toList();

    return Column(
      children: [
        // Barra de búsqueda
        Padding(
          padding: const EdgeInsets.all(15),
          child: TextField(
            decoration: InputDecoration(
              labelText: "Buscar marca",
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (value) {
              setState(() {
                filtro = value.trim();
              });
            },
          ),
        ),

        // Lista de marcas filtradas
        Expanded(
          child: marcasFiltradas.isEmpty
              ? const Center(
                  child: Text(
                    "No se encontraron marcas",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(15),
                  itemCount: marcasFiltradas.length,
                  itemBuilder: (context, index) {
                    final marca =
                        marcasFiltradas[index] as Map<String, dynamic>;
                    final id = marca['id'] as int;
                    final nombre = marca['marcas']?.toString() ?? '';

                    return Card(
                      elevation: 3,
                      child: ListTile(
                        // Usamos el helper que devuelve Image o Icon en caso de fallo
                        leading: marcaLogoWidget(nombre, size: 40),
                        title: Text(
                          nombre,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        // Menú de acciones (ver / editar / borrar)
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) async {
                            if (value == "ver") {
                              // Mostrar diálogo con la marca
                              showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text("Marca"),
                                  content: Row(
                                    children: [
                                      // mostramos logo o icono
                                      marcaLogoWidget(nombre, size: 50),
                                      const SizedBox(width: 15),
                                      Text(
                                        nombre,
                                        style: const TextStyle(fontSize: 18),
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text("Cerrar"),
                                    ),
                                  ],
                                ),
                              );
                            } else if (value == "editar") {
                              // Navegar a la página de edición y recargar si regresan cambios
                              final res = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => EditarMarcaPage(marca: marca),
                                ),
                              );
                              if (res != null) await cargarMarcas();
                            } else if (value == "borrar") {
                              confirmarBorrado(id, nombre);
                            }
                          },
                          itemBuilder: (context) => const [
                            PopupMenuItem(
                              value: "ver",
                              child: Row(
                                children: [
                                  Icon(Icons.visibility, color: Colors.blue),
                                  SizedBox(width: 10),
                                  Text("Ver"),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: "editar",
                              child: Row(
                                children: [
                                  Icon(Icons.edit, color: Colors.orange),
                                  SizedBox(width: 10),
                                  Text("Editar"),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: "borrar",
                              child: Row(
                                children: [
                                  Icon(Icons.delete, color: Colors.red),
                                  SizedBox(width: 10),
                                  Text("Borrar"),
                                ],
                              ),
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
