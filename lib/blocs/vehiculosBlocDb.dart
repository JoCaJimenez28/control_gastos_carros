import 'package:bloc/bloc.dart';
import 'package:control_gastos_carros/database/database.dart';
import 'package:control_gastos_carros/modelos/vehiculos.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

late Database_helper db;

sealed class VehiculoEvento {}

class VehiculosInicializado extends VehiculoEvento {}

class AddVehiculo extends VehiculoEvento {
  final Vehiculo vehiculo;

  AddVehiculo({required this.vehiculo});
}

class UpdateVehiculo extends VehiculoEvento {
  final Vehiculo vehiculo;

  UpdateVehiculo({required this.vehiculo});
}

class DeleteVehiculo extends VehiculoEvento {
  final Vehiculo vehiculo;

  DeleteVehiculo({required this.vehiculo});
}

//Estados
class VehiculoEstado with EquatableMixin {
  final List<Vehiculo> vehiculos;

  VehiculoEstado._() : vehiculos = [];

  VehiculoEstado({required this.vehiculos});

  @override
  List<Object?> get props => [vehiculos];
}

//Bloc
class VehiculosBlocDb extends Bloc<VehiculoEvento, VehiculoEstado> {
  List<Vehiculo> _vehiculos = [];

  VehiculosBlocDb() : super(VehiculoEstado._()) {
    on<VehiculosInicializado>((event, emit) async {
          _vehiculos = await getAllVehiculosFromDb();
      emit(VehiculoEstado(vehiculos: _vehiculos));
    });
    on<AddVehiculo>(_addVehiculo);
    // on<UpdateVehiculo>(_updateVehiculo);
    // on<DeleteVehiculo>(_deleteVehiculo);
  }

  void _addVehiculo(AddVehiculo event, Emitter<VehiculoEstado> emit) async {
    _vehiculos = await insertVehiculo(event.vehiculo);
    emit(VehiculoEstado(vehiculos: _vehiculos));
  }

  // void _updateVehiculo(UpdateVehiculo event, Emitter<VehiculoEstado> emit) {
  //   List<Vehiculo> updatedVehiculos = List.from(state.vehiculos);
  //   int index = updatedVehiculos
  //       .indexWhere((vehiculo) => vehiculo.id == event.vehiculo.id);
  //   print('lista sin actualizar: $updatedVehiculos ');

  //   if (index != -1) {
  //     updatedVehiculos[index] = event.vehiculo;
  //     print('vehiculo actualizado: $updatedVehiculos ');
  //     emit(VehiculoEstado(vehiculos: updatedVehiculos));
  //     print('estado ${state.vehiculos}');
  //   } else {
  //     print('Vehículo no encontrado para actualizar');
  //   }
  // }

  // void _deleteVehiculo(DeleteVehiculo event, Emitter<VehiculoEstado> emit) {
  //   List<Vehiculo> updatedVehiculos = List.from(state.vehiculos);
  //   if (_vehiculos.contains(event.vehiculo)) {
  //     _vehiculos = _vehiculos.copiar()..remove(event.vehiculo);
  //     print('a eliminar; ${event.vehiculo}');
  //     emit(VehiculoEstado(vehiculos: _vehiculos));
  //     print('estado; ${state.vehiculos}');
  //   } else {
  //     print("no se encontro el vehiculo a eliminar");
  //   }
  // }

  Future<List<Vehiculo>> getAllVehiculosFromDb() async {
    final db = Database_helper().dbGestor;

    List<Map<String, dynamic>> data = await db.query('vehiculos');
    List<Vehiculo> listaOriginal = data.map((e) {
      return Vehiculo(
          id: e['ID'], 
          marca: e['marca'], 
          modelo: e['modelo'], 
          anio: e['anio'], 
          color: e['color']
        );
    }).toList();

    return listaOriginal;
  }

  Future<List<Vehiculo>> insertVehiculo(Vehiculo vehiculo) async {
    final db = Database_helper().dbGestor;

    await db.insert('vehiculos', 
        {
          'marca': vehiculo.marca, 
          'modelo': vehiculo.modelo, 
          'anio': vehiculo.anio, 
          'color': vehiculo.color
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
    );

    List<Map<String, dynamic>> data = await db.query('vehiculos');
    List<Vehiculo> listaOriginal = data.map((e) {
      return Vehiculo(
          id: e['ID'], 
          marca: e['marca'], 
          modelo: e['modelo'], 
          anio: e['anio'], 
          color: e['color']
        );
    }).toList();

    return listaOriginal;
  }
}