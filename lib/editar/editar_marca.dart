import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditarMarcaPage extends StatefulWidget {
  final Map<String, dynamic> marca;

  const EditarMarcaPage({super.key, required this.marca});

  @override
  State<EditarMarcaPage> createState() => _EditarMarcaPageState();
}

class _EditarMarcaPageState extends State<EditarMarcaPage> {
  final supabase = Supabase.instance.client;

  late TextEditingController marcaCtrl;

  @override
  void initState() {
    super.initState();
    marcaCtrl = TextEditingController(text: widget.marca["marcas"]);
  }

  // 🔤 Filtro de ortografía / formato → Capitaliza la marca
  String formatMarca(String texto) {
    texto = texto.trim();
    if (texto.isEmpty) return texto;
    return texto[0].toUpperCase() + texto.substring(1).toLowerCase();
  }

  Future<void> guardar() async {
    final id = widget.marca["id"];

    // Aplica corrección de escritura antes de guardar
    final marcaFormateada = formatMarca(marcaCtrl.text);

    await supabase
        .from("marcas")
        .update({"marcas": marcaFormateada})
        .eq("id", id);

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Editar Marca")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: marcaCtrl,
              decoration: const InputDecoration(
                labelText: "Marca",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: guardar,
              child: const Text("Guardar Cambios"),
            ),
          ],
        ),
      ),
    );
  }
}
