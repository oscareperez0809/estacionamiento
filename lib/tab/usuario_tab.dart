import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UsuarioTab extends StatelessWidget {
  const UsuarioTab({super.key});

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: supabase
          .from('Usuarios')
          .select('id, Email, Nombre, Apellido, Fecha_Nac'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        final usuarios = snapshot.data ?? [];

        if (usuarios.isEmpty) {
          return const Center(
            child: Text(
              'No hay usuarios registrados',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: usuarios.length,
          itemBuilder: (context, index) {
            final user = usuarios[index];

            final nombreCompleto =
                "${user['Nombre'] ?? ''} ${user['Apellido'] ?? ''}".trim();

            final fechaNac = user['Fecha_Nac'] ?? 'No registrada';

            return Card(
              elevation: 4,
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🔹 Nombre completo
                    Text(
                      nombreCompleto.isEmpty ? "Sin nombre" : nombreCompleto,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // 🔹 Email
                    Row(
                      children: [
                        const Icon(Icons.email_outlined),
                        const SizedBox(width: 10),
                        Text(
                          user['Email'],
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // 🔹 Fecha de nacimiento
                    Row(
                      children: [
                        const Icon(Icons.cake_outlined, size: 20),
                        const SizedBox(width: 10),
                        Text(
                          "Fecha de nacimiento: $fechaNac",
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
