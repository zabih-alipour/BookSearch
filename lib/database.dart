import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:test_app/model/Book.dart';


class BookDatabase {
  static final BookDatabase _bookDatabase = new BookDatabase._internal();

  final String tableName = "Books";

  Database db;

  factory BookDatabase() {
    return _bookDatabase;
  }


  /**
   * Returns a currently saved book, if it is not in the database returns the book of the input
   */
  Future<Book> getBook(Book book) async{
    var result = await db.rawQuery('SELECT * FROM $tableName WHERE ${Book.db_id} = "${book.id}"');
    if(result.length == 0)return book;
    return new Book.fromMap(result[0]);
  }


  Future updateBook(Book book) async {
    await db.inTransaction(() async {
      await db.rawInsert(
          'INSERT OR REPLACE INTO '
              '$tableName(${Book.db_id}, ${Book.db_title}, ${Book.db_url}, ${Book.db_star}, ${Book.db_notes})'
              ' VALUES("${book.id}", "${book.title}", "${book.url}", ${book.starred? 1:0}, "${book.notes}")');
    });
  }

  BookDatabase._internal() {
    start();
  }


  Future start() async {
    // Get a location using path_provider
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "demo.db");
    db = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
          // When creating the db, create the table
          await db.execute(
              "CREATE TABLE $tableName ("
                  "${Book.db_id} STRING PRIMARY KEY,"
                  "${Book.db_title} TEXT,"
                  "${Book.db_url} TEXT,"
                  "${Book.db_star} BIT,"
                  "${Book.db_notes} TEXT"
                  ")");
        });


  }
}