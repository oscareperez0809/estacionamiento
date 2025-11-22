import 'package:flutter/material.dart';

// Importa tus tabs personalizados
import 'package:estacionamiento/tab/carros_tab.dart';
import 'package:estacionamiento/tab/categoria_tab.dart';
import 'package:estacionamiento/tab/marca_tab.dart';
import 'package:estacionamiento/tab/usuario_tab.dart';
import 'package:estacionamiento/tab/pensionados_tab.dart';

//formularios
import 'package:estacionamiento/registros/registrar_categoria.dart';
import 'package:estacionamiento/registros/registrar_marca.dart';

// Importa tu widget de tab con icono+texto
import 'package:estacionamiento/utils/my_tab.dart';

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
                leading: Icon(Icons.directions_car),
                title: Text('Registrar Carro'),
                onTap: () {
                  Navigator.pop(context);
                  DefaultTabController.of(context).animateTo(0);
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
                  DefaultTabController.of(context).animateTo(3);
                },
              ),

              ListTile(
                leading: Icon(Icons.people),
                title: Text('Registrar Pensionado'),
                onTap: () {
                  Navigator.pop(context);
                  DefaultTabController.of(context).animateTo(4);
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
          actions: const [
            Padding(
              padding: EdgeInsets.only(right: 24.0),
              child: Icon(Icons.person),
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
