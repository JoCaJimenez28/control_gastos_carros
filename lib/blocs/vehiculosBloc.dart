import 'package:bloc/bloc.dart';
import 'package:control_gastos_carros/modelos/vehiculos.dart';
import 'package:equatable/equatable.dart';

//Eventos
class VehiculoEvento {}

class AddVehiculo extends VehiculoEvento{
  final Vehiculo vehiculo;

  AddVehiculo({required this.vehiculo});
}

class UpdateVehiculo extends VehiculoEvento{
  final Vehiculo vehiculo;

  UpdateVehiculo({required this.vehiculo});
}

class DeleteVehiculo extends VehiculoEvento{
  final Vehiculo vehiculo;

  DeleteVehiculo({required this.vehiculo});
}

//Estados

class VehiculoEstado extends Equatable{
  List<Vehiculo> vehiculos;

  VehiculoEstado({required this.vehiculos});
  
  @override
  List<Object?> get props => [vehiculos];
}

class VehiculosInicial extends VehiculoEstado{
  VehiculosInicial({required List<Vehiculo> vehiculos}) : super(vehiculos: vehiculos);
}

class VehiculosActualizados extends VehiculoEstado{
  VehiculosActualizados({required List<Vehiculo> vehiculos}) : super(vehiculos: vehiculos);
}

//Bloc
class VehiculosBloc extends Bloc<VehiculoEvento, VehiculoEstado> {
  VehiculosBloc() : super(VehiculosInicial(vehiculos: [])) {
    on<VehiculoEvento>((event, emit) {
      // TODO: implement event handler
    });

    on<AddVehiculo>((event, emit) {
      state.vehiculos.add(event.vehiculo);
      emit(VehiculosActualizados(vehiculos: state.vehiculos));
      // Imprimir en la consola el valor del vehículo
      print('Vehículo añadido: ${state.vehiculos.toString()}');
    });

    on<UpdateVehiculo>((event, emit) {
      for(int i = 0; i < state.vehiculos.length; i++){
        if(event.vehiculo.id == state.vehiculos[i].id){
          state.vehiculos[i] = event.vehiculo;
          print('Vehículo actualizado: ${event.vehiculo.toString()}');
        }
      }

      emit(VehiculosActualizados(vehiculos: state.vehiculos));
    });

    on<DeleteVehiculo>((event, emit) {
      if(state.vehiculos.contains(event.vehiculo)){
      state.vehiculos.remove(event.vehiculo);
      print('a eliminar; ${event.vehiculo}');
      print('estado; ${state.vehiculos}');
      emit(VehiculosActualizados(vehiculos: state.vehiculos));
      }
      else{
        print("no se encontro el vehiculo a eliminar");
      }
      

    });
  }
}