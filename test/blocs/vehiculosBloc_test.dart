import 'package:bloc_test/bloc_test.dart';
import 'package:matcher/matcher.dart';
import 'package:control_gastos_carros/blocs/vehiculosBloc.dart';
import 'package:control_gastos_carros/modelos/vehiculos.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  blocTest<VehiculosBloc, VehiculoEstado>(
    'añadimos un vehiculo',
    build: () => VehiculosBloc(),
    act: (bloc) => bloc.add(AddVehiculo(vehiculo: Vehiculo(id: 1, marca: 'VolksWagen', modelo: 'Sedan', anio: '2002', color: 'rojo'))),
    expect: () => [isA<VehiculosActualizados>()],
  );

  blocTest<VehiculosBloc, VehiculoEstado>(
    'actualiza un vehiculo',
    build: () => VehiculosBloc(),
    act: (bloc){
      bloc.add(AddVehiculo(vehiculo: Vehiculo(id: 1, marca: 'VolksWagen', modelo: 'Sedan', anio: '2002', color: 'rojo')));
      bloc.add(UpdateVehiculo(vehiculo: Vehiculo(id: 1, marca: 'VolksWagen', modelo: 'Sedan', anio: '2002', color: 'azul')));
    }, 
    expect: () =>[isA<VehiculosActualizados>()],
  );

  blocTest<VehiculosBloc, VehiculoEstado>(
    'elimina un vehiculo',
    build: () => VehiculosBloc(),
    act: (bloc){
      bloc.add(AddVehiculo(vehiculo: Vehiculo(id: 1, marca: 'VolksWagen', modelo: 'Sedan', anio: '2002', color: 'rojo')));
      bloc.add(DeleteVehiculo(vehiculo: Vehiculo(id: 1, marca: 'VolksWagen', modelo: 'Sedan', anio: '2002', color: 'rojo')));
    } ,
    expect: () => [VehiculosActualizados(vehiculos: [])],
  );
  
  blocTest<VehiculosBloc, VehiculoEstado>(
    'flujos de añadir, editar y eliminar vehículos',
    build: () => VehiculosBloc(),
    act: (bloc) {
      // Añadir el primer vehículo
      bloc.add(AddVehiculo(
        vehiculo: Vehiculo(id: 1, marca: 'Toyota', modelo: 'Camry', anio: '2021', color: 'azul'),
      ));

      // Añadir el segundo vehículo
      bloc.add(AddVehiculo(
        vehiculo: Vehiculo(id: 2, marca: 'Honda', modelo: 'Civic', anio: '2022', color: 'rojo'),
      ));

      // Editar el primer vehículo
      bloc.add(UpdateVehiculo(
        vehiculo: Vehiculo(id: 1, marca: 'Toyota', modelo: 'Camry', anio: '2021', color: 'verde'),
      ));

      // Eliminar el último vehículo
      bloc.add(DeleteVehiculo(
        vehiculo: Vehiculo(id: 2, marca: 'Honda', modelo: 'Civic', anio: '2022', color: 'rojo'),
      ));
    },
    expect: () => [
  equals(VehiculosActualizados(vehiculos: [Vehiculo(id: 1, marca: 'Toyota', modelo: 'Camry', anio: '2021', color: 'verde')])),
],
  );
}