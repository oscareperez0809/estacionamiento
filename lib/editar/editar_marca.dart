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

  Future<void> guardar() async {
    final id = widget.marca["id"];

    await supabase.from("marcas").update({
      "marcas": marcaCtrl.text,
    }).eq("id", id);

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
            )
          ],
        ),
      ),
    );
  }
}
