import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegistrarMarcaPage extends StatefulWidget {
  const RegistrarMarcaPage({super.key});

  @override
  State<RegistrarMarcaPage> createState() => _RegistrarMarcaPageState();
}

class _RegistrarMarcaPageState extends State<RegistrarMarcaPage> {
  final TextEditingController _nombreCtrl = TextEditingController();
  final supabase = Supabase.instance.client;

  Future<void> registrarMarca() async {
    final nombre = _nombreCtrl.text.trim(); // ← variable correcta

    if (nombre.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("El nombre no puede estar vacío")),
      );
      return;
    }

    try {
      await supabase.from('marcas').insert({
        'marcas': nombre, // ← aquí usas 'nombre', no 'categoria'
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Marca registrada correctamente ✔")),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Registrar Marca")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _nombreCtrl,
              decoration: const InputDecoration(labelText: "Marca de auto"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: registrarMarca,
              child: const Text("Registrar"),
            ),
          ],
        ),
      ),
    );
  }
}
