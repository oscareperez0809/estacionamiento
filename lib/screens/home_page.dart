import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Importa tus tabs personalizados
import 'package:estacionamiento/tab/carros_tab.dart';
import 'package:estacionamiento/tab/categoria_tab.dart';
import 'package:estacionamiento/tab/marca_tab.dart';
import 'package:estacionamiento/tab/usuario_tab.dart';
import 'package:estacionamiento/tab/pensionados_tab.dart';

//formularios
import 'package:estacionamiento/registros/registrar_categoria.dart';
import 'package:estacionamiento/registros/registrar_marca.dart';
import 'package:estacionamiento/registros/registrar_usuario.dart';
import 'package:estacionamiento/registros/registrar_pensionado.dart';
import 'package:estacionamiento/registros/registrar_carro.dart';
// Importa tu widget de tab con icono+texto
import 'package:estacionamiento/utils/my_tab.dart';
import 'package:estacionamiento/utils/session.dart';
import 'package:estacionamiento/utils/perfil_usuario.dart';

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
        // 🔹 MENU LATERAL (Drawer)
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
                  Navigator.pop(context); // cerrar el drawer
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RegistrarCarroPage(),
                    ),
                  );
                },
              ),

              ListTile(
                leading: const Icon(Icons.category),
                title: const Text('Registrar Categoría'),
                onTap: () {
                  Navigator.pop(context); // cerrar el drawer
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RegistrarCategoriaPage(),
                    ),
                  );
                },
              ),

              ListTile(
                leading: Icon(Icons.circle),
                title: Text('Registrar Marca'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RegistrarMarcaPage(),
                    ),
                  );
                },
              ),

              ListTile(
                leading: Icon(Icons.person),
                title: Text('Registrar Usuario'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RegistrarUsuarioPage(),
                    ),
                  );
                },
              ),

              ListTile(
                leading: Icon(Icons.person),
                title: Text('Registrar Pensionado'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RegistrarPensionadoPage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),

        // 🔹 APPBAR
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
                onPressed: () async {
                  final sessionUser = SessionManager.currentUser;

                  if (sessionUser == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('No hay usuario logueado')),
                    );
                    return;
                  }

                  try {
                    final supabase = Supabase.instance.client;

                    final response = await supabase
                        .from('Usuarios')
                        .select('id')
                        .eq('Email', sessionUser['Email'])
                        .single();

                    int userId = response['id'];

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PerfilUsuarioPage(userId: userId),
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('No se encontró el usuario: $e')),
                    );
                  }
                },
                color: Colors.grey[800],
              ),
            ),
          ],
        ),

        // 🔹 CUERPO
        body: Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 24.0),
              child: Row(
                children: [
                  Text('ESTACIONAMIENTO ', style: TextStyle(fontSize: 24)),
                  Text(
                    'SALAZAR',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),

            // 🔹 Tabs superiores
            TabBar(tabs: myTabs),

            // 🔹 Contenido de las tabs
            Expanded(
              child: TabBarView(
                physics: NeverScrollableScrollPhysics(),
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
