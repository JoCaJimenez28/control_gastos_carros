import 'package:bloc/bloc.dart';
import 'package:control_gastos_carros/modelos/vehiculos.dart';
import 'package:equatable/equatable.dart';

//Eventos
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
      _vehiculos.addAll(listaOriginal);
      emit(VehiculoEstado(vehiculos: _vehiculos));
    });
    on<AddVehiculo>(_addVehiculo);
    on<UpdateVehiculo>(_updateVehiculo);
    on<DeleteVehiculo>(_deleteVehiculo);
  }

  void _addVehiculo(AddVehiculo event, Emitter<VehiculoEstado> emit) {
    _vehiculos = _vehiculos.agregar(event.vehiculo);
    emit(VehiculoEstado(vehiculos: _vehiculos));
    // List<Vehiculo> updatedVehiculos = List.from(_vehiculos);
    // print('updatedVehiculos: $updatedVehiculos');
    // updatedVehiculos.add(event.vehiculo);
    // print('updatedVehiculos con añadido: $updatedVehiculos');
    // emit(VehiculoEstado(vehiculos: updatedVehiculos));
    // print('estado: $state');
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

final List<Vehiculo> listaOriginal = [
  Vehiculo(id: 1, marca: 'vw', modelo: 'vocho', anio: '2002', color: 'rojo'),
  Vehiculo(id: 2, marca: 'nissan', modelo: 'sentra', anio: '2003', color: 'azul'),
];

extension MiLista<T> on List<T>{
  List<T> agregar (T elemento)=> [... this, elemento];
  List<T> copiar ( )=> [... this];
}
// //Eventos
// class VehiculoEvento {}

// class AddVehiculo extends VehiculoEvento{
//   final Vehiculo vehiculo;

//   AddVehiculo({required this.vehiculo});
// }

// class UpdateVehiculo extends VehiculoEvento{
//   final Vehiculo vehiculo;

//   UpdateVehiculo({required this.vehiculo});
// }

// class DeleteVehiculo extends VehiculoEvento{
//   final Vehiculo vehiculo;

//   DeleteVehiculo({required this.vehiculo});
// }

// class VehiculosInicializado extends VehiculoEvento {}

// //Estados

// class VehiculoEstado with EquatableMixin{
//   List<Vehiculo> vehiculos;

//   VehiculoEstado({required this.vehiculos});

//   @override
//   List<Object?> get props => [vehiculos];
// }

// class VehiculosInicial extends VehiculoEstado{
//   VehiculosInicial({required List<Vehiculo> vehiculos}) : super(vehiculos: vehiculos);
// }

// class VehiculosActualizados extends VehiculoEstado{
//   VehiculosActualizados({required List<Vehiculo> vehiculos}) : super(vehiculos: vehiculos);
// }

// //Bloc
// class VehiculosBloc extends Bloc<VehiculoEvento, VehiculoEstado> {
//   VehiculosBloc() : super(VehiculosInicial(vehiculos: [])) {
//     on<VehiculoEvento>((event, emit) {
//       // TODO: implement event handler
//     });

//     on<VehiculosInicializado>((event, emit) {
//       emit(VehiculosActualizados(vehiculos: []));
//     });

//     on<AddVehiculo>((event, emit) {
//       state.vehiculos.add(event.vehiculo);
//       emit(VehiculosActualizados(vehiculos: state.vehiculos));
//       // Imprimir en la consola el valor del vehículo
//       print('Vehículo añadido: ${state.vehiculos.toString()}');
//     });

//     on<UpdateVehiculo>((event, emit) {
//       for(int i = 0; i < state.vehiculos.length; i++){
//         if(event.vehiculo.id == state.vehiculos[i].id){
//           state.vehiculos[i] = event.vehiculo;
//           print('Vehículo actualizado: ${event.vehiculo.toString()}');
//         }
//       }

//       emit(VehiculosActualizados(vehiculos: state.vehiculos));
//     });

//     on<DeleteVehiculo>((event, emit) {
//       if(state.vehiculos.contains(event.vehiculo)){
//       state.vehiculos.remove(event.vehiculo);
//       print('a eliminar; ${event.vehiculo}');
//       print('estado; ${state.vehiculos}');
//       emit(VehiculosActualizados(vehiculos: state.vehiculos));
//       }
//       else{
//         print("no se encontro el vehiculo a eliminar");
//       }

//     });
//   }
// }
