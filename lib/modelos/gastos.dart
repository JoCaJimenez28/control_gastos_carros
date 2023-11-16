import 'package:equatable/equatable.dart';

class Gasto with EquatableMixin {
  final int id;
  final String tipoGasto;
  final double monto;
  final DateTime fecha;
  final String descripcion;
  final int vehiculoId;

  Gasto({
    required this.id,
    required this.tipoGasto,
    required this.monto,
    required this.fecha,
    required this.descripcion,
    required this.vehiculoId
  });
  
  @override
  List<Object?> get props => [tipoGasto, monto, fecha, descripcion, vehiculoId];

  @override
  bool get stringify => true;
}