import 'package:flutter/material.dart';

/// Devuelve la ruta PNG del logo de la marca.
/// Debes poner tus propios archivos en:
/// lib/icons/marcas/
String getMarcaIcon(String nombre) {
  final marca = nombre.trim().toLowerCase();

  // Nissan
  if (marca.contains('nissan')) {
    return 'lib/icons/marcas/nissan.png';
  }

  // Toyota
  if (marca.contains('toyota')) {
    return 'lib/icons/marcas/toyota.png';
  }

  // Volkswagen / VW
  if (marca.contains('volkswagen') || marca.contains('vw')) {
    return 'lib/icons/marcas/vw.png';
  }

  // Ford
  if (marca.contains('ford')) {
    return 'lib/icons/marcas/ford.png';
  }

  // Tesla
  if (marca.contains('tesla')) {
    return 'lib/icons/marcas/tesla.png';
  }

  // Ferrari
  if (marca.contains('ferrari')) {
    return 'lib/icons/marcas/ferrari.png';
  }

  // Lamborghini / Lambo
  if (marca.contains('lamborghini') || marca.contains('lambo')) {
    return 'lib/icons/marcas/Lamborghini.png';
  }

  // Bugatti
  if (marca.contains('bugatti')) {
    return 'lib/icons/marcas/bugatti.png';
  }

  // BMW
  if (marca.contains('bmw')) {
    return 'lib/icons/marcas/bmw.png';
  }

  // Mercedes / Benz
  if (marca.contains('mercedes') || marca.contains('benz')) {
    return 'lib/icons/marcas/mercedes.png';
  }

  // Mazda
  if (marca.contains('mazda')) {
    return 'lib/icons/marcas/mazda.png';
  }

  // Chevrolet / Chevy
  if (marca.contains('chevrolet') || marca.contains('chevy')) {
    return 'lib/icons/marcas/chevrolet.png';
  }

  // Dodge
  if (marca.contains('dodge')) {
    return 'lib/icons/marcas/dodge.png';
  }

  // Jeep
  if (marca.contains('jeep')) {
    return 'lib/icons/marcas/jeep.png';
  }

  // Hyundai
  if (marca.contains('hyundai')) {
    return 'lib/icons/marcas/hyundai.png';
  }

  // Kia
  if (marca.contains('kia')) {
    return 'lib/icons/marcas/kia.png';
  }

  // Subaru
  if (marca.contains('subaru')) {
    return 'lib/icons/marcas/subaru.png';
  }

  // Mitsubishi
  if (marca.contains('mitsu')) {
    return 'lib/icons/marcas/mitsubishi.png';
  }

  // Porsche
  if (marca.contains('porsche')) {
    return 'lib/icons/marcas/porsche.png';
  }

  // Default / sin coincidencia
  return 'lib/icons/marcas/default.png';
}

/// Widget helper por si quieres usarlo directo
Widget marcaLogoWidget(String marca, {double size = 50}) {
  return Image.asset(
    getMarcaIcon(marca),
    width: size,
    height: size,
    fit: BoxFit.contain,
  );
}
