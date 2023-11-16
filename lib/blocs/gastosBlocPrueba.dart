import 'package:bloc/bloc.dart';
import 'package:control_gastos_carros/database/database.dart';
import 'package:control_gastos_carros/modelos/gastos.dart';
import 'package:control_gastos_carros/modelos/vehiculos.dart';
import 'package:equatable/equatable.dart';

late Database_helper db;
//Eventos
sealed class GastoEvento {}

class GastosInicializado extends GastoEvento {}

class AddGasto extends GastoEvento {
  final Gasto gasto;

  AddGasto({required this.gasto});
}

class UpdateGasto extends GastoEvento {
  final Gasto gasto;

  UpdateGasto({required this.gasto});
}

class DeleteGasto extends GastoEvento {
  final Gasto gasto;

  DeleteGasto({required this.gasto});
}

//Estados
class GastoEstado with EquatableMixin {
  final List<Gasto> gastos;

  GastoEstado._() : gastos = [];

  GastoEstado({required this.gastos});

  @override
  List<Object?> get props => [gastos];
}

//Bloc
class GastoBloc extends Bloc<GastoEvento, GastoEstado> {
  List<Gasto> _gastos = [];

  GastoBloc() : super(GastoEstado._()) {
    on<GastosInicializado>((event, emit) {
      _gastos.addAll(listaOriginal);
      emit(GastoEstado(gastos: _gastos));
    });
    on<AddGasto>(_addGasto);
    on<UpdateGasto>(_updateGasto);
    on<DeleteGasto>(_deleteGasto);
  }

  void _addGasto(AddGasto event, Emitter<GastoEstado> emit) {
    _gastos = _gastos.agregar(event.gasto);
    emit(GastoEstado(gastos: _gastos));
  }

  void _updateGasto(UpdateGasto event, Emitter<GastoEstado> emit) {
    List<Gasto> updatedGastos = List.from(state.gastos);
    int index = updatedGastos
        .indexWhere((gasto) => gasto.id == event.gasto.id);
    print('lista sin actualizar: $updatedGastos ');

    if (index != -1) {
      updatedGastos[index] = event.gasto;
      print('Gasto actualizado: $updatedGastos ');
      emit(GastoEstado(gastos: updatedGastos));
      print('estado ${state.gastos}');
    } else {
      print('Vehículo no encontrado para actualizar');
    }
  }

  void _deleteGasto(DeleteGasto event, Emitter<GastoEstado> emit) {
    List<Gasto> updatedGastos = List.from(state.gastos);
    if (_gastos.contains(event.gasto)) {
      _gastos = _gastos.copiar()..remove(event.gasto);
      print('a eliminar; ${event.gasto}');
      emit(GastoEstado(gastos: _gastos));
      print('estado; ${state.gastos}');
    } else {
      print("no se encontro el vehiculo a eliminar");
    }
  }
}

final List<Gasto> listaOriginal = [
  Gasto(id: 1, tipoGasto: 'Gasolinera', monto: 100, fecha: DateTime(2023, 11, 15), descripcion: '100 en gasolinera zacatecas', vehiculoId: 1),
  Gasto(id: 1, tipoGasto: 'Mecanico', monto: 600, fecha: DateTime(2023, 10, 1), descripcion: 'cambio de aceite', vehiculoId: 1)
];

extension MiLista<T> on List<T>{
  List<T> agregar (T elemento)=> [... this, elemento];
  List<T> copiar ( )=> [... this];
}