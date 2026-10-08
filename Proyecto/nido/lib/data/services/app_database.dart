import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// Base de datos SQLite local de la app (plataforma Android).
class AppDatabase {
  AppDatabase._();

  static final AppDatabase instancia = AppDatabase._();

  Database? _db;

  Future<Database> get db async {
    _db ??= await _abrir();
    return _db!;
  }

  Future<Database> _abrir() async {
    final directorio = await getDatabasesPath();
    final ruta = p.join(directorio, 'nido.db');

    return openDatabase(
      ruta,
      version: 3,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE usuarios (
            id TEXT PRIMARY KEY,
            nombreCompleto TEXT NOT NULL,
            email TEXT NOT NULL UNIQUE,
            passwordHash TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE grupos_familiares (
            id TEXT PRIMARY KEY,
            nombre TEXT NOT NULL,
            codigoAcceso TEXT NOT NULL UNIQUE,
            integrantesIds TEXT NOT NULL
          )
        ''');        await db.execute('''
          CREATE TABLE productos (
            id TEXT PRIMARY KEY,
            nombre TEXT NOT NULL,
            categoria TEXT NOT NULL,
            cantidad INTEGER NOT NULL,
            cantidadMinima INTEGER NOT NULL DEFAULT 0,
            unidad TEXT NOT NULL,
            prioridad TEXT NOT NULL,
            estado TEXT NOT NULL,
            grupoId TEXT NOT NULL,
            creadoPor TEXT NOT NULL,
            fechaActualizacion TEXT NOT NULL
          )
        ''' );
        await db.execute('''
          CREATE TABLE espacios (
            id TEXT PRIMARY KEY,
            nombre TEXT NOT NULL,
            colorValue INTEGER NOT NULL,
            iconCodePoint INTEGER NOT NULL,
            grupoId TEXT NOT NULL
          )
        ''');
        // Fila única (id fijo en 0) con el usuario de la sesión activa.
        await db.execute('''
          CREATE TABLE sesion (
            id INTEGER PRIMARY KEY CHECK (id = 0),
            usuarioId TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE espacios (
              id TEXT PRIMARY KEY,
              nombre TEXT NOT NULL,
              colorValue INTEGER NOT NULL,
              iconCodePoint INTEGER NOT NULL,
              grupoId TEXT NOT NULL
            )
          ''');
        }
        if (oldVersion < 3) {
          await db.execute(
            'ALTER TABLE productos ADD COLUMN cantidadMinima INTEGER NOT NULL DEFAULT 0',
          );
          await db.execute(
            "UPDATE productos SET estado = 'Por revisar' WHERE cantidad <= cantidadMinima",
          );
        }
      },
    );
  }
}
