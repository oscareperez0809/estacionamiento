import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PensionadosTab extends StatelessWidget {
  const PensionadosTab({super.key});

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: supabase
          .from('Pensionados')
          .select('id, Nombre, Apellido, Marca, Pago_Men'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        final pensionados = snapshot.data ?? [];

        if (pensionados.isEmpty) {
          return const Center(
            child: Text(
              'No hay pensionados registrados',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: pensionados.length,
          itemBuilder: (context, index) {
            final p = pensionados[index];

            final nombreCompleto = "${p['Nombre'] ?? ''} ${p['Apellido'] ?? ''}"
                .trim();

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

                    const SizedBox(height: 12),

                    // 🔹 Marca
                    Row(
                      children: [
                        const Icon(Icons.directions_car_outlined),
                        const SizedBox(width: 10),
                        Text(
                          "Marca: ${p['Marca']}",
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // 🔹 Pago mensual
                    Row(
                      children: [
                        const Icon(Icons.attach_money_outlined),
                        const SizedBox(width: 10),
                        Text(
                          "Mensualidad: \$${p['Pago_Men']}",
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.green,
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
