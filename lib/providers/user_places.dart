import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:favorite_places/models/place.dart';
import 'package:path_provider/path_provider.dart' as syspaths;
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite/sqlite_api.dart';

Future<Database> _getDataBase() async {
  final dbPath = await sql.getDatabasesPath();
  final db = await sql.openDatabase(
      path.join(
        dbPath,
        'places.db',
      ), onCreate: (db, version) {
    return db.execute(
        'CREATE TABLE user_places(id Text PRIMARY KEY,title TEXT,image TEXt , lng REAL ,lat REAL , address TEXT)');
  }, version: 1);
  return db;
}

class UserPlacesNotifier extends StateNotifier<List<Place>> {
  UserPlacesNotifier() : super(const []);
  Future<void> loadPlaces() async {
    final db = await _getDataBase();
    final data = await db.query('user_places');
    final places = data
        .map(
          (row) => Place(
            title: row['title'] as String,
            image: File(row['image'] as String),
            location: PlaceLocation(
              longitude: row['lng'] as double,
              latitude: row['lat'] as double,
              address: row['address'] as String,
            ),
          ),
        )
        .toList();
    state = places;
  }

  void addPlace(String title, File image, PlaceLocation location) async {
    final appDir = await syspaths.getApplicationDocumentsDirectory();
    final fileName = await path.basename(image.path);
    final copiedImage = await image.copy('${appDir.path}/$fileName');
    final newPlace =
        Place(title: title, image: copiedImage, location: location);
    final db = await _getDataBase();
    db.insert(
      'user_places',
      {
        'id': newPlace.id,
        'title': newPlace.title,
        'image': newPlace.image.path,
        'lng': newPlace.location.longitude,
        'lat': newPlace.location.latitude,
        'address': newPlace.location.address,
      },
    );
    state = [newPlace, ...state];
  }
}

final userPlacesProvider =
    StateNotifierProvider<UserPlacesNotifier, List<Place>>(
  (ref) => UserPlacesNotifier(),
);
