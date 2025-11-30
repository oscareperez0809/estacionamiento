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

  List<dynamic> marcas = [];
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    cargarMarcas();
  }

  Future<void> cargarMarcas() async {
    try {
      final data = await supabase
          .from('marcas')
          .select()
          .order('marcas', ascending: true);
      setState(() {
        marcas = data;
        cargando = false;
      });
    } catch (e) {
      setState(() => cargando = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error al cargar las marcas: $e")));
    }
  }

  Future<void> borrarMarca(int id) async {
    try {
      await supabase.from('marcas').delete().eq('id', id);
      cargarMarcas();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error al borrar: $e")));
    }
  }

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
    if (cargando) {
      return const Center(child: CircularProgressIndicator());
    }

    if (marcas.isEmpty) {
      return const Center(
        child: Text(
          "No hay marcas registradas",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(15),
      itemCount: marcas.length,
      itemBuilder: (context, index) {
        final marca = marcas[index];
        final id = marca['id'];
        final nombre = marca['marcas'];

        return Card(
          elevation: 3,
          child: ListTile(
            leading: Image.asset(
              getMarcaIcon(nombre), // ← icono PNG desde tu función
              width: 40,
              height: 40,
              fit: BoxFit.contain,
            ),
            title: Text(
              nombre,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            trailing: PopupMenuButton(
              onSelected: (value) async {
                if (value == "ver") {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text("Marca"),
                      content: Row(
                        children: [
                          Image.asset(
                            getMarcaIcon(nombre),
                            width: 50,
                            height: 50,
                          ),
                          const SizedBox(width: 15),
                          Text(nombre, style: const TextStyle(fontSize: 18)),
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
                  final resultado = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditarMarcaPage(marca: marca),
                    ),
                  );

                  if (resultado != null) cargarMarcas();
                } else if (value == "borrar") {
                  confirmarBorrado(id, nombre);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: "ver",
                  child: Row(
                    children: [
                      Icon(Icons.visibility, color: Colors.blue),
                      SizedBox(width: 10),
                      Text("Ver"),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: "editar",
                  child: Row(
                    children: [
                      Icon(Icons.edit, color: Colors.orange),
                      SizedBox(width: 10),
                      Text("Editar"),
                    ],
                  ),
                ),
                const PopupMenuItem(
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
    );
  }
}
