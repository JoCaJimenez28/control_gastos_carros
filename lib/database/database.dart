import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class Database_helper {
  late Database dbGestor;

  Future<void> iniciarDatabase() async {
    WidgetsFlutterBinding.ensureInitialized();
    // sqfliteFfiInit();

    var fabricaBaseDatos = databaseFactoryFfi;
    String rutaBaseDatos = '${await fabricaBaseDatos.getDatabasesPath()}/base.db';

    dbGestor = await fabricaBaseDatos.openDatabase(rutaBaseDatos,
        options: OpenDatabaseOptions(
            version: 1,
            onCreate: (db, version) async {
              await db.execute(
                  'CREATE TABLE vehiculos (ID INTEGER PRIMARY KEY AUTOINCREMENT, marca TEXT(35), modelo TEXT(35), anio TEXT(35), color TEXT(35));');
            }));
  }
}
