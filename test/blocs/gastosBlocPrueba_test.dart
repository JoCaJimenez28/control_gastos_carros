// import 'dart:js';

// import 'package:bloc_test/bloc_test.dart';
// import 'package:control_gastos_carros/blocs/gastos_bloc_prueba.dart';
// import 'package:control_gastos_carros/blocs/vehiculos_bloc_db.dart';
// import 'package:control_gastos_carros/modelos/gastos.dart';
// import 'package:flutter/widgets.dart';
// import 'package:flutter_test/flutter_test.dart';

// void main() {
//    blocTest<GastosBloc, GastoEstado>(
//       'emite un nuevo estado con el vehículo agregado',
//       build: () => GastosBloc(context: mockBuildContext())..add(GastosInicializado()),
//       act: (bloc) => bloc.add(AddGasto(gasto: Gasto(id: 3, tipoGasto: 'Mecanico', monto: 300, fecha: DateTime(2023, 10, 1), descripcion: 'cambio de refaccion', vehiculoId: 1), context: context)),
//       expect: () => [
//         GastoEstado(gastos: [
//             Gasto(id: 1, tipoGasto: 'Gasolinera', monto: 100, fecha: DateTime(2023, 11, 15), descripcion: '100 en gasolinera zacatecas', vehiculoId: 1), 
//             Gasto(id: 2, tipoGasto: 'Mecanico', monto: 600, fecha: DateTime(2023, 10, 1), descripcion: 'cambio de aceite', vehiculoId: 2)
//           ]),
//         GastoEstado(gastos: [
//             Gasto(id: 1, tipoGasto: 'Gasolinera', monto: 100, fecha: DateTime(2023, 11, 15), descripcion: '100 en gasolinera zacatecas', vehiculoId: 1), 
//             Gasto(id: 2, tipoGasto: 'Mecanico', monto: 600, fecha: DateTime(2023, 10, 1), descripcion: 'cambio de aceite', vehiculoId: 2),
//             Gasto(id: 1, tipoGasto: 'Mecanico', monto: 600, fecha: DateTime(2023, 10, 1), descripcion: 'cambio de aceite', vehiculoId: 1)

//           ]),
//       ],
//   );

//   blocTest<GastosBloc, GastoEstado>(
//       'agregando 2 gastos',
//       build: () => GastosBloc()..add(GastosInicializado()),
//       act: (bloc){
//         bloc.add(AddGasto(gasto: Gasto(id: 3, marca: 'Toyota', modelo: 'Corolla', anio: '2022', color: 'Azul')));
//         bloc.add(AddGasto(gasto: Gasto(id: 4, marca: 'Nissan', modelo: 'Altima', anio: '2001', color: 'Gris')));
//       },
//       expect: () => [
//         GastoEstado(gastos: [Gasto(id: 1, marca: 'vw', modelo: 'vocho', anio: '2002', color: 'rojo'), Gasto(id: 2, marca: 'nissan', modelo: 'sentra', anio: '2003', color: 'azul')]),
//         GastoEstado(gastos: [Gasto(id: 1, marca: 'vw', modelo: 'vocho', anio: '2002', color: 'rojo'), Gasto(id: 2, marca: 'nissan', modelo: 'sentra', anio: '2003', color: 'azul'),Vehiculo(id: 3, marca: 'Toyota', modelo: 'Corolla', anio: '2022', color: 'Azul')]),
//         GastoEstado(gastos: [Gasto(id: 1, marca: 'vw', modelo: 'vocho', anio: '2002', color: 'rojo'), Gasto(id: 2, marca: 'nissan', modelo: 'sentra', anio: '2003', color: 'azul'),
//         Gasto(id: 3, marca: 'Toyota', modelo: 'Corolla', anio: '2022', color: 'Azul'), Gasto(id: 4, marca: 'Nissan', modelo: 'Altima', anio: '2001', color: 'Gris')]),
//       ],
//   );
// }