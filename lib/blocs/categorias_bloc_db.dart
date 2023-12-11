import 'package:bloc/bloc.dart';
import 'package:control_gastos_carros/modelos/categorias.dart';
import 'package:mockito/mockito.dart';
import 'package:control_gastos_carros/database/database.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

late DatabaseHelper db;

sealed class CategoriaEvento {}

class Categoriasinicializado extends CategoriaEvento {}

class AddCategoria extends CategoriaEvento {
  final Categoria categoria;

  AddCategoria({required this.categoria});
}

class UpdateCategoria extends CategoriaEvento {
  final Categoria categoria;

  UpdateCategoria({required this.categoria});
}

class DeleteCategoria extends CategoriaEvento {
  final Categoria categoria;

  DeleteCategoria({required this.categoria});
}

class ObtenerCategorias extends CategoriaEvento {
  final Categoria categoria;

  ObtenerCategorias({required this.categoria});
}

//Estados
class CategoriasEstado with EquatableMixin {
  final List<Categoria> categorias;
  String error = "";

  CategoriasEstado._() : categorias = [];

  CategoriasEstado({required this.categorias, this.error=""});

  @override
  List<Object?> get props => [categorias];
}

class MockVehiculosBlocDb extends Mock implements CategoriasBloc {}

//Bloc
class CategoriasBloc extends Bloc<CategoriaEvento, CategoriasEstado> {
  List<Categoria> _categorias = [];

  CategoriasBloc() : super(CategoriasEstado._()) {
    on<Categoriasinicializado>((event, emit) async {
      await DatabaseHelper().iniciarDatabase();
      _categorias = await getAllCategoriasFromDb();
      emit(CategoriasEstado(categorias: _categorias));
    });
    on<AddCategoria>(_addcategoria);
    on<UpdateCategoria>(_updateCategoria);
    on<DeleteCategoria>(_deleteCategoria);
  }

  // void _addcategoria(AddCategoria event, Emitter<CategoriasEstado> emit) async {
  //   print("entro al _add");
  //   try {
  //     await DatabaseHelper().iniciarDatabase();
  //     _categorias = await insertCategoria(event.categoria);
  //   print("inserto categoria");
  //     emit(CategoriasEstado(categorias: _categorias));
  //   print("estado: ${_categorias}");

  //   } catch (e) {
  //     emitErrorSnackBar(emit, 'Error al agregar vehículo: $e');
  //   }
  // }

  void _updateCategoria(UpdateCategoria event, Emitter<CategoriasEstado> emit) async {
    try {
      Categoria? editCategoria = await getCategoriaByNombre(event.categoria.nombre);
      // print("editCategoria: $editCategoria");

      if (editCategoria != null) {
        _categorias = await updateCategoria(event.categoria);
        emit(CategoriasEstado(categorias: _categorias));
        // print('Categoria actualizado con éxito!');
      } else {
        emitErrorSnackBar(emit, 'Categoria no encontrado para actualizar.');
      }
    } catch (e) {
      emitErrorSnackBar(emit, 'Error al actualizar el vehículo: $e');
    }
  }

  void _deleteCategoria(DeleteCategoria event, Emitter<CategoriasEstado> emit) async {
    try {
      // print("entro al delete");
      List<Categoria> updatedList = await deleteCategoria(event.categoria);
      emit(CategoriasEstado(categorias: updatedList));
      // print('categoria eliminada con éxito!');
    } catch (e) {
      emitErrorSnackBar(emit, 'Error al eliminar categoria: $e');
      // print('errorDelete $e');
    }
  }

  
  void emitErrorSnackBar(Emitter<CategoriasEstado> emit, String errorMessage) {
    emit(CategoriasEstado(categorias: state.categorias, error: errorMessage)); // Mantener el estado actual  
  }



  Future<List<Categoria>> getAllCategoriasFromDb() async {
    final Database? db = await DatabaseHelper().database;

    if (db == null) {
      // print('Error: Database not initialized.');
      return [];
    }

    List<Map<String, dynamic>> data = await db.query('categorias');
    List<Categoria> listaOriginal = data.map((e) {
      return Categoria(
          id: e['ID'],
          nombre: e['nombre']);
    }).toList();

    return listaOriginal;
  }

  void _addcategoria(AddCategoria event, Emitter<CategoriasEstado> emit) async {
  // print("entro al _add");
  try {
    await DatabaseHelper().iniciarDatabase();

    // Verificar si la categoría ya existe
    List<Categoria> categoriasExistentes = await getAllCategoriasFromDb();
    bool categoriaExiste = categoriasExistentes.any((cat) => cat.nombre == event.categoria.nombre);

    if (categoriaExiste) {
      emit(CategoriasEstado(categorias: _categorias, error: 'Ya existe una categoría con ese nombre'));
      return;
    }

    _categorias = await insertCategoria(event.categoria);
    // print("inserto categoria");
    emit(CategoriasEstado(categorias: _categorias));
    // print("estado: ${_categorias}");

  } catch (e) {
    emit(CategoriasEstado(categorias: _categorias, error: 'Error al agregar categoría: $e'));
  }
}

Future<List<Categoria>> insertCategoria(Categoria categoria) async {
  final Database? db = await DatabaseHelper().database;

  if (db == null) {
    // print('Error: Database not initialized.');
    return [];
  }
  
  await db.insert(
    'categorias',
    {
      'nombre': categoria.nombre,
    },
    conflictAlgorithm: ConflictAlgorithm.abort, // Cambiado a ConflictAlgorithm.abort
  );

  List<Map<String, dynamic>> data = await db.query('categorias');
  List<Categoria> listaOriginal = data.map((e) {
    return Categoria(
      id: e['ID'],
      nombre: e['nombre'],
    );
  }).toList();

  return listaOriginal;
}

Future<List<Categoria>> getCategorias() async {
  final Database? db = await DatabaseHelper().database;
  if (db == null) {
    // print('Error: Database not initialized.');
    return [];
  }

  List<Map<String, dynamic>> data = await db.query('categorias');
  List<Categoria> listaCategorias = data.map((e) {
    return Categoria(
      id: e['ID'],
      nombre: e['nombre'],
    );
  }).toList();

  return listaCategorias;
}

  // Future<List<Categoria>> insertCategoria(Categoria categoria) async {
  //   final Database? db = await DatabaseHelper().database;

  //   if (db == null) {
  //     print('Error: Database not initialized.');
  //     return [];
  //   }
  //   await db.insert(
  //     'categorias',
  //     {
  //       'nombre': categoria.nombre,
  //     },
  //     conflictAlgorithm: ConflictAlgorithm.replace,
  //   );

  //   List<Map<String, dynamic>> data = await db.query('categorias');
  //   List<Categoria> listaOriginal = data.map((e) {
  //     return Categoria(
  //       id: e['ID'],
  //       nombre: e['nombre'],
  //     );
  //   }).toList();

  //   return listaOriginal;
  // }

  Future<Categoria?> getCategoriaByNombre(String nombre) async {
    final Database? db = await DatabaseHelper().database;

    if (db == null) {
      // print('Error: Database not initialized.');
      return null;
    }

    List<Map<String, dynamic>> data = await db.query(
      'categorias',
      where:
          'nombre = ?', 
      whereArgs: [nombre],
    );

    if (data.isNotEmpty) {
      Map<String, dynamic> categoriaData = data.first;
      return Categoria(
        id: categoriaData['ID'],
        nombre: categoriaData['nombre'],
      );
    } else {
      // print('Categoria con nombre $nombre no encontrada.');
      return null;
    }
  }

  Future<List<Categoria>> updateCategoria(Categoria? categoria) async {
    final Database? db = await DatabaseHelper().database;
    // print("entro al update");
    if (categoria == null) {
      // print("no hay categoria");
      return [];
    }

    if (db == null) {
      // print('Error: Database not initialized.');
      return [];
    }

    await db.update(
      'categorias',
      {
        'nombre': categoria.nombre,
      },
      where: 'ID = ?', 
      whereArgs: [categoria.id], 
    );

    List<Map<String, dynamic>> data = await db.query('categorias');
    List<Categoria> listaOriginal = data.map((e) {
      return Categoria(
        id: e['ID'],
        nombre: e['nombre'],
      );
    }).toList();

    return listaOriginal;
  }

  Future<List<Categoria>> deleteCategoria(Categoria categoria) async {
    final Database? db = await DatabaseHelper().database;

    if (db == null) {
      // print('Error: Database not initialized.');
      return [];
    }

    await db.delete(
      'categorias',
      where: 'ID = ?',
      whereArgs: [categoria.id], 
    );

    List<Map<String, dynamic>> data = await db.query('categorias');
    List<Categoria> updatedList = data.map((e) {
      return Categoria(
        id: e['ID'],
        nombre: e['nombre']
      );
    }).toList();

    return updatedList;
  }
}

