import 'package:flutter/material.dart';

/// Devuelve la ruta PNG del logo de la marca o null si no hay imagen conocida.
/// Nota: devuelve String? (nullable). Si es null, el caller debe mostrar un Icon.
String? getMarcaIcon(String nombre) {
  final marca = nombre.trim().toLowerCase();

  // Ejemplos: si detectas la marca, devuelve la ruta relativa al asset.
  if (marca.contains('nissan')) return 'lib/icons/marcas/nissan.png';
  if (marca.contains('toyota')) return 'lib/icons/marcas/toyota.png';
  if (marca.contains('volkswagen') || marca.contains('vw'))
    return 'lib/icons/marcas/vw.png';
  if (marca.contains('ford')) return 'lib/icons/marcas/ford.png';
  if (marca.contains('tesla')) return 'lib/icons/marcas/tesla.png';
  if (marca.contains('ferrari')) return 'lib/icons/marcas/ferrari.png';
  if (marca.contains('lamborghini') || marca.contains('lambo'))
    return 'lib/icons/marcas/Lamborghini.png';
  if (marca.contains('bugatti')) return 'lib/icons/marcas/bugatti.png';
  if (marca.contains('bmw')) return 'lib/icons/marcas/bmw.png';
  if (marca.contains('mercedes') || marca.contains('benz'))
    return 'lib/icons/marcas/mercedes.png';
  if (marca.contains('mazda')) return 'lib/icons/marcas/mazda.png';
  if (marca.contains('chevrolet') || marca.contains('chevy'))
    return 'lib/icons/marcas/chevrolet.png';
  if (marca.contains('dodge')) return 'lib/icons/marcas/dodge.png';
  if (marca.contains('jeep')) return 'lib/icons/marcas/jeep.png';
  if (marca.contains('hyundai')) return 'lib/icons/marcas/hyundai.png';
  if (marca.contains('honda')) return 'lib/icons/marcas/honda.png';
  if (marca.contains('kia')) return 'lib/icons/marcas/kia.png';
  if (marca.contains('audi')) return 'lib/icons/marcas/audi.png';
  if (marca.contains('subaru')) return 'lib/icons/marcas/subaru.png';
  if (marca.contains('mitsubishi')) return 'lib/icons/marcas/mitsubishi.png';
  if (marca.contains('porsche')) return 'lib/icons/marcas/porsche.png';
  if (marca.contains('mg')) return 'lib/icons/marcas/mg.png';
  if (marca.contains('geely')) return 'lib/icons/marcas/geely.png';
  if (marca.contains('gmc')) return 'lib/icons/marcas/gmc.png';
  if (marca.contains('mustang')) return 'lib/icons/marcas/mustang.png';
  if (marca.contains('camaro')) return 'lib/icons/marcas/camaro.png';
  if (marca.contains('byd')) return 'lib/icons/marcas/byd.png';
  if (marca.contains('changan')) return 'lib/icons/marcas/changan.png';
  if (marca.contains('aston martin'))
    return 'lib/icons/marcas/aston_martin.png';
  if (marca.contains('acura')) return 'lib/icons/marcas/acura.png';
  if (marca.contains('ducati')) return 'lib/icons/marcas/ducati.png';
  if (marca.contains('lotus')) return 'lib/icons/marcas/lotus.png';

  // Si no hay coincidencia, devolvemos null para que el caller muestre un Icon.
  return null;
}

/// Widget helper: muestra la imagen de la marca si existe la ruta,
/// o un Icon de coche si no existe la imagen.
///
/// - [marca]: nombre de marca (texto).
/// - [size]: tamaño del widget devuelto.
Widget marcaLogoWidget(String marca, {double size = 40}) {
  final path = getMarcaIcon(marca);

  // Si path es null -> no hay imagen para esa marca, devolvemos Icon.
  if (path == null || path.isEmpty) {
    return Icon(Icons.directions_car, size: size, color: Colors.grey.shade700);
  }

  // Intentamos cargar la imagen. Si el asset no existe la app fallará en tiempo de ejecución;
  // para minimizar ese riesgo, recomendamos asegurarse de tener los assets sincronizados.
  return Image.asset(
    path,
    width: size,
    height: size,
    fit: BoxFit.contain,
    errorBuilder: (context, error, stackTrace) {
      // Si por alguna razón falla la carga, mostramos el icono en lugar de romper.
      return Icon(
        Icons.directions_car,
        size: size,
        color: Colors.grey.shade700,
      );
    },
  );
}
