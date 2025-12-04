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

  // Función para capitalizar la primera letra
  String capitalizar(String texto) {
    if (texto.isEmpty) return '';
    texto = texto.trim();
    return texto[0].toUpperCase() + texto.substring(1).toLowerCase();
  }

  Future<void> registrarMarca() async {
    String nombre = capitalizar(_nombreCtrl.text);

    if (nombre.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("El nombre no puede estar vacío")),
      );
      return;
    }

    try {
      // 🔍 Verificar si ya existe
      final existing = await supabase
          .from('marcas')
          .select('*')
          .ilike('marcas', nombre); // ilike para ignorar mayúsculas/minúsculas

      if (existing.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("La marca '$nombre' ya está registrada")),
        );
        return;
      }

      // Insertar
      await supabase.from('marcas').insert({'marcas': nombre});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Marca '$nombre' registrada correctamente ✔")),
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
        padding: const EdgeInsets.all(22),
        child: Column(
          children: [
            TextField(
              controller: _nombreCtrl,
              decoration: const InputDecoration(labelText: "Marca de auto"),
            ),
            const SizedBox(height: 22),
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
