import 'package:bloc/bloc.dart';
import 'package:control_gastos_carros/database/database.dart';
import 'package:control_gastos_carros/modelos/vehiculos.dart';
import 'package:equatable/equatable.dart';

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
class VehiculosBloc extends Bloc<VehiculoEvento, VehiculoEstado> {
  List<Vehiculo> _vehiculos = [];

  VehiculosBloc() : super(VehiculoEstado._()) {
    on<VehiculosInicializado>((event, emit) {
      print(db.dbGestor.execute('SELECT * FROM vehiculos'));
      // _vehiculos.addAll(listaOriginal);
      emit(VehiculoEstado(vehiculos: _vehiculos));
    });
    on<AddVehiculo>(_addVehiculo);
    on<UpdateVehiculo>(_updateVehiculo);
    on<DeleteVehiculo>(_deleteVehiculo);
  }

  void _addVehiculo(AddVehiculo event, Emitter<VehiculoEstado> emit) {
    _vehiculos = _vehiculos.agregar(event.vehiculo);
    emit(VehiculoEstado(vehiculos: _vehiculos));
  }

  void _updateVehiculo(UpdateVehiculo event, Emitter<VehiculoEstado> emit) {
    List<Vehiculo> updatedVehiculos = List.from(state.vehiculos);
    int index = updatedVehiculos
        .indexWhere((vehiculo) => vehiculo.id == event.vehiculo.id);
    print('lista sin actualizar: $updatedVehiculos ');

    if (index != -1) {
      updatedVehiculos[index] = event.vehiculo;
      print('vehiculo actualizado: $updatedVehiculos ');
      emit(VehiculoEstado(vehiculos: updatedVehiculos));
      print('estado ${state.vehiculos}');
    } else {
      print('Vehículo no encontrado para actualizar');
    }
  }

  void _deleteVehiculo(DeleteVehiculo event, Emitter<VehiculoEstado> emit) {
    List<Vehiculo> updatedVehiculos = List.from(state.vehiculos);
    if (_vehiculos.contains(event.vehiculo)) {
      _vehiculos = _vehiculos.copiar()..remove(event.vehiculo);
      print('a eliminar; ${event.vehiculo}');
      emit(VehiculoEstado(vehiculos: _vehiculos));
      print('estado; ${state.vehiculos}');
    } else {
      print("no se encontro el vehiculo a eliminar");
    }
  }
}