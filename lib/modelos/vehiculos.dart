import 'package:equatable/equatable.dart';

class Vehiculo with EquatableMixin {
  final int? id;
  final String marca;
  final String placa;
  final String modelo;
  final String anio;
  final String color;

  Vehiculo({
    this.id,
    required this.marca,
    required this.placa,
    required this.modelo,
    required this.anio,
    required this.color,
  });
  
  @override
  List<Object?> get props => [id, marca, placa, modelo, anio, color];

  @override
  bool get stringify => true;
}

// class Vehiculo {
//   final int id;
//   final String marca;
//   final String modelo;
//   final String anio;
//   final String color;

//   Vehiculo({
//     required this.id,
//     required this.marca,
//     required this.modelo,
//     required this.anio,
//     required this.color,
//   });

//   @override
//   bool operator ==(Object other) =>
//       identical(this, other) ||
//       other is Vehiculo &&
//           runtimeType == other.runtimeType &&
//           id == other.id &&
//           marca == other.marca &&
//           modelo == other.modelo &&
//           anio == other.anio &&
//           color == other.color;

//   @override
//   int get hashCode =>
//       id.hashCode ^ marca.hashCode ^ modelo.hashCode ^ anio.hashCode ^ color.hashCode;
//   @override
//   String toString() {
//     return 'Vehiculo{id: $id, marca: $marca, modelo: $modelo, anio: $anio, color: $color}';
//   }
// }