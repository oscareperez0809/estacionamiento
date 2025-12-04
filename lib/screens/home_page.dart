import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Importa tabs
import 'package:estacionamiento/tab/carros_tab.dart';
import 'package:estacionamiento/tab/categoria_tab.dart';
import 'package:estacionamiento/tab/marca_tab.dart';
import 'package:estacionamiento/tab/usuario_tab.dart';
import 'package:estacionamiento/tab/pensionados_tab.dart';

// Formularios
import 'package:estacionamiento/registros/registrar_categoria.dart';
import 'package:estacionamiento/registros/registrar_marca.dart';
import 'package:estacionamiento/registros/registrar_usuario.dart';
import 'package:estacionamiento/registros/registrar_pensionado.dart';
import 'package:estacionamiento/registros/registrar_carro.dart';

// Utils
import 'package:estacionamiento/utils/my_tab.dart';
import 'package:estacionamiento/utils/perfil_usuario.dart';
import 'package:estacionamiento/utils/session.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Widget> myTabs = const [
    MyTab(iconPath: 'lib/icons/car.png', iconName: 'Carros'),
    MyTab(iconPath: 'lib/icons/categoria.png', iconName: 'Categoria'),
    MyTab(iconPath: 'lib/icons/marca.png', iconName: 'Marcas'),
    MyTab(iconPath: 'lib/icons/usuario.png', iconName: 'Usuarios'),
    MyTab(iconPath: 'lib/icons/pensionados.png', iconName: 'Pensionados'),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: myTabs.length,
      child: Scaffold(
        resizeToAvoidBottomInset: false,

        // ------------------ DRAWER ------------------
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(color: Colors.blue),
                child: Text(
                  'Menú de Registro',
                  style: TextStyle(color: Colors.white, fontSize: 22),
                ),
              ),

              ListTile(
                leading: const Icon(Icons.directions_car),
                title: const Text('Registrar Carro'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RegistrarCarroPage(),
                    ),
                  );
                },
              ),

              ListTile(
                leading: const Icon(Icons.category),
                title: const Text('Registrar Categoría'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RegistrarCategoriaPage(),
                    ),
                  );
                },
              ),

              ListTile(
                leading: const Icon(Icons.circle),
                title: const Text('Registrar Marca'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RegistrarMarcaPage(),
                    ),
                  );
                },
              ),

              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Registrar Usuario'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => RegistrarUsuarioPage()),
                  );
                },
              ),

              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Registrar Pensionado'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RegistrarPensionadoPage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),

        // ------------------ APPBAR ------------------
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.menu, color: Colors.grey[800]),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 24.0),
              child: IconButton(
                icon: const Icon(Icons.person),
                color: Colors.grey[800],
                onPressed: () async {
                  final user = SessionManager.currentUser;

                  if (user == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('No hay usuario logueado')),
                    );
                    return;
                  }

                  final email = user["Email"];

                  try {
                    final supabase = Supabase.instance.client;

                    final response = await supabase
                        .from('Usuarios')
                        .select('id')
                        .eq('Email', email as Object) // ← cast corregido
                        .single();

                    final userId = response['id'];

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PerfilUsuarioPage(userId: userId),
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error cargando usuario: $e')),
                    );
                  }
                },
              ),
            ),
          ],
        ),

        // ------------------ BODY ------------------
        body: Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 24.0),
              child: Row(
                children: [
                  Text('ESTACIONAMIENTO ', style: TextStyle(fontSize: 20)),
                  Text(
                    'SALAZAR',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),

            TabBar(tabs: myTabs),

            Expanded(
              child: TabBarView(
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  CarrosTab(),
                  CategoriaTab(),
                  MarcaTab(),
                  UsuarioTab(),
                  PensionadosTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
