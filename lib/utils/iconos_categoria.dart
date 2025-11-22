import 'package:flutter/material.dart';

IconData getCategoriaIcon(String categoriaRaw) {
  final categoria = categoriaRaw.trim().toLowerCase();

  // === AUTOS ===
  if (categoria.contains('auto')) return Icons.directions_car;
  if (categoria.contains('carro')) return Icons.directions_car;
  if (categoria.contains('sedan') || categoria.contains('sedán'))
    return Icons.directions_car;
  if (categoria.contains('hatchback')) return Icons.directions_car;
  if (categoria.contains('coupe') || categoria.contains('coupé'))
    return Icons.directions_car;

  // === MUSCLE CAR ===
  if (categoria.contains('muscle')) return Icons.local_fire_department;

  // === DEPORTIVOS ===
  if (categoria.contains('deportivo')) return Icons.sports_motorsports;
  if (categoria.contains('superdeportivo')) return Icons.sports_motorsports;
  if (categoria.contains('hiperdeportivo') || categoria.contains('hyper')) {
    return Icons.flash_on;
  }

  // === SUV / CROSSOVER ===
  if (categoria.contains('suv')) return Icons.directions_car_filled;
  if (categoria.contains('crossover')) return Icons.directions_car_filled;

  // === PICKUP / CAMIONETA ===
  if (categoria.contains('pickup')) return Icons.local_shipping;
  if (categoria.contains('camioneta')) return Icons.local_shipping;

  // === VANS ===
  if (categoria.contains('van')) return Icons.airport_shuttle;
  if (categoria.contains('minivan')) return Icons.airport_shuttle;

  // === MOTOS ===
  if (categoria.contains('moto') || categoria.contains('motocicleta')) {
    return Icons.motorcycle;
  }

  // === CAMIONES ===
  if (categoria.contains('camion')) return Icons.fire_truck;

  //====electricos===
  if (categoria.contains('electrico')) return Icons.electric_car;

  // === DEFAULT ===
  return Icons.category;
}
