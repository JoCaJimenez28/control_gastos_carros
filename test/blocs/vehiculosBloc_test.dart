import 'package:bloc_test/bloc_test.dart';
import 'package:matcher/matcher.dart';
import 'package:control_gastos_carros/blocs/vehiculosBlocPrueba.dart';
import 'package:control_gastos_carros/modelos/vehiculos.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  blocTest<VehiculosBloc, VehiculoEstado>(
      'emite un nuevo estado con el vehículo agregado',
      build: () => VehiculosBloc()..add(VehiculosInicializado()),
      act: (bloc) => bloc.add(AddVehiculo(vehiculo: Vehiculo(id: 3, marca: 'Toyota', placa: 'VSA-3456', modelo: 'Corolla', anio: '2022', color: 'Azul'))),
      expect: () => [
        VehiculoEstado(vehiculos: [Vehiculo(id: 1, marca: 'vw', placa: 'VSA-1234', modelo: 'vocho', anio: '2002', color: 'rojo'), Vehiculo(id: 2, marca: 'nissan', placa: 'VSA-2345', modelo: 'sentra', anio: '2003', color: 'azul')]),
        VehiculoEstado(vehiculos: [Vehiculo(id: 1, marca: 'vw', placa: 'VSA-1234', modelo: 'vocho', anio: '2002', color: 'rojo'), Vehiculo(id: 2, marca: 'nissan', placa: 'VSA-2345', modelo: 'sentra', anio: '2003', color: 'azul'),Vehiculo(id: 3, marca: 'Toyota', placa: 'VSA-3456', modelo: 'Corolla', anio: '2022', color: 'Azul')]),
      ],
  );

  blocTest<VehiculosBloc, VehiculoEstado>(
      'agregando 2 vehiculos',
      build: () => VehiculosBloc()..add(VehiculosInicializado()),
      act: (bloc){
        bloc.add(AddVehiculo(vehiculo: Vehiculo(id: 3, marca: 'Toyota', placa: 'VSA-3456', modelo: 'Corolla', anio: '2022', color: 'Azul')));
        bloc.add(AddVehiculo(vehiculo: Vehiculo(id: 4, marca: 'Nissan', placa: 'VSA-4567', modelo: 'Altima', anio: '2001', color: 'Gris')));
      },
      expect: () => [
        VehiculoEstado(vehiculos: [Vehiculo(id: 1, marca: 'vw', placa: 'VSA-1234', modelo: 'vocho', anio: '2002', color: 'rojo'), Vehiculo(id: 2, marca: 'nissan', placa: 'VSA-2345', modelo: 'sentra', anio: '2003', color: 'azul')]),
        VehiculoEstado(vehiculos: [Vehiculo(id: 1, marca: 'vw', placa: 'VSA-1234', modelo: 'vocho', anio: '2002', color: 'rojo'), Vehiculo(id: 2, marca: 'nissan', placa: 'VSA-2345', modelo: 'sentra', anio: '2003', color: 'azul'),Vehiculo(id: 3, marca: 'Toyota', placa: 'VSA-3456', modelo: 'Corolla', anio: '2022', color: 'Azul')]),
        VehiculoEstado(vehiculos: [Vehiculo(id: 1, marca: 'vw', placa: 'VSA-1234', modelo: 'vocho', anio: '2002', color: 'rojo'), Vehiculo(id: 2, marca: 'nissan', placa: 'VSA-2345', modelo: 'sentra', anio: '2003', color: 'azul'),
        Vehiculo(id: 3, marca: 'Toyota', placa: 'VSA-3456', modelo: 'Corolla', anio: '2022', color: 'Azul'), Vehiculo(id: 4, marca: 'Nissan', placa: 'VSA-4567', modelo: 'Altima', anio: '2001', color: 'Gris')]),
      ],
  );

  blocTest<VehiculosBloc, VehiculoEstado>(
  'emite un nuevo estado con el vehículo actualizado',
  build: () => VehiculosBloc()..add(VehiculosInicializado()),
  act: (bloc) => bloc.add(UpdateVehiculo(vehiculo: Vehiculo(id: 1, marca: 'Toyota', placa: 'VSA-1234', modelo: 'Camry', anio: '2022', color: 'Rojo'))),
  expect: () => [
    VehiculoEstado(vehiculos: [Vehiculo(id: 1, marca: 'vw', placa: 'VSA-1234', modelo: 'vocho', anio: '2002', color: 'rojo'), Vehiculo(id: 2, marca: 'nissan', placa: 'VSA-2345', modelo: 'sentra', anio: '2003', color: 'azul')]),
    VehiculoEstado(vehiculos: [Vehiculo(id: 1, marca: 'Toyota', placa: 'VSA-1234', modelo: 'Camry', anio: '2022', color: 'Rojo'), Vehiculo(id: 2, marca: 'nissan', placa: 'VSA-2345', modelo: 'sentra', anio: '2003', color: 'azul')]),
  ],
);

blocTest<VehiculosBloc, VehiculoEstado>(
      'emite un nuevo estado sin el vehículo eliminado',
      build: () => VehiculosBloc()..add(VehiculosInicializado()),
      act: (bloc) => bloc.add(DeleteVehiculo(vehiculo: Vehiculo(id: 1, marca: 'vw', placa: 'VSA-1234', modelo: 'vocho', anio: '2002', color: 'rojo'))),
      expect: () => [
        VehiculoEstado(vehiculos: [Vehiculo(id: 1, marca: 'vw', placa: 'VSA-1234', modelo: 'vocho', anio: '2002', color: 'rojo'), Vehiculo(id: 2, marca: 'nissan', placa: 'VSA-2345', modelo: 'sentra', anio: '2003', color: 'azul')]),
        VehiculoEstado(vehiculos: [Vehiculo(id: 2, marca: 'nissan', placa: 'VSA-2345', modelo: 'sentra', anio: '2003', color: 'azul')]),
      ],
    );

//   blocTest<VehiculosBloc, VehiculoEstado>(
//     'añadimos un vehiculo',
//     build: () => VehiculosBloc(),
//     act: (bloc) => bloc.add(AddVehiculo(vehiculo: Vehiculo(id: 1, marca: 'VolksWagen', modelo: 'Sedan', anio: '2002', color: 'rojo'))),
//     expect: () => [isA<VehiculoEstado>()],
//   );

//   blocTest<VehiculosBloc, VehiculoEstado>(
//     'actualiza un vehiculo',
//     build: () => VehiculosBloc(),
//     act: (bloc){
//       bloc.add(AddVehiculo(vehiculo: Vehiculo(id: 1, marca: 'VolksWagen', modelo: 'Sedan', anio: '2002', color: 'rojo')));
//       bloc.add(UpdateVehiculo(vehiculo: Vehiculo(id: 1, marca: 'VolksWagen', modelo: 'Sedan', anio: '2002', color: 'azul')));
//     }, 
//     expect: () =>[isA<VehiculoEstado>()],
//   );

//   blocTest<VehiculosBloc, VehiculoEstado>(
//     'elimina un vehiculo',
//     build: () => VehiculosBloc(),
//     act: (bloc){
//       bloc.add(AddVehiculo(vehiculo: Vehiculo(id: 1, marca: 'VolksWagen', modelo: 'Sedan', anio: '2002', color: 'rojo')));
//       bloc.add(DeleteVehiculo(vehiculo: Vehiculo(id: 1, marca: 'VolksWagen', modelo: 'Sedan', anio: '2002', color: 'rojo')));
//     } ,
//     expect: () => [VehiculoEstado(vehiculos: [])],
//   );
  
//   blocTest<VehiculosBloc, VehiculoEstado>(
//     'flujos de añadir, editar y eliminar vehículos',
//     build: () => VehiculosBloc(),
//     act: (bloc) {
//       // Añadir el primer vehículo
//       bloc.add(AddVehiculo(
//         vehiculo: Vehiculo(id: 1, marca: 'Toyota', modelo: 'Camry', anio: '2021', color: 'azul'),
//       ));

//       // Añadir el segundo vehículo
//       bloc.add(AddVehiculo(
//         vehiculo: Vehiculo(id: 2, marca: 'Honda', modelo: 'Civic', anio: '2022', color: 'rojo'),
//       ));

//       // Editar el primer vehículo
//       bloc.add(UpdateVehiculo(
//         vehiculo: Vehiculo(id: 1, marca: 'Toyota', modelo: 'Camry', anio: '2021', color: 'verde'),
//       ));

//       // Eliminar el último vehículo
//       bloc.add(DeleteVehiculo(
//         vehiculo: Vehiculo(id: 2, marca: 'Honda', modelo: 'Civic', anio: '2022', color: 'rojo'),
//       ));
//     },
//     expect: () => [
//   equals(VehiculoEstado(vehiculos: [Vehiculo(id: 1, marca: 'Toyota', modelo: 'Camry', anio: '2021', color: 'verde')])),
// ],
//   );
}