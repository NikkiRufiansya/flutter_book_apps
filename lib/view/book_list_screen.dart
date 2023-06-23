import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../main.dart';
import '../models/book.dart';
import 'add_edit_book_screen.dart';

class BookListScreen extends StatefulWidget {
  @override
  _BookListScreenState createState() => _BookListScreenState();
}

class _BookListScreenState extends State<BookListScreen> {
  late Database _database;
  late List<Book> _books;
  List<int> _selectedBookIds = [];

  @override
  void initState() {
    super.initState();
    openDatabaseAndFetchBooks();
  }

  Future<void> openDatabaseAndFetchBooks() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'book_collection.db');
    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE books (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            code TEXT,
            isbn TEXT,
            title TEXT,
            description TEXT,
            category TEXT,
            publishDate TEXT,
            price REAL,
            hardCover INTEGER
          )
        ''');
      },
    );
    final List<Map<String, dynamic>> maps = await _database.query('books');
    _books = List.generate(maps.length, (i) {
      return Book(
        id: maps[i]['id'],
        code: maps[i]['code'],
        isbn: maps[i]['isbn'],
        title: maps[i]['title'],
        description: maps[i]['description'],
        category: maps[i]['category'],
        publishDate: maps[i]['publishDate'],
        price: maps[i]['price'],
        hardCover: maps[i]['hardCover'] == 1,
      );
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Collection'),
      ),
      body: ListView.builder(
        itemCount: _books.length,
        itemBuilder: (context, index) {
          final book = _books[index];
          final isSelected = _selectedBookIds.contains(book.id);
          return ListTile(
            title: Text(book.title),
            subtitle: Text(book.category),
            trailing: Checkbox(
              value: isSelected,
              onChanged: (value) {
                setState(() {
                  if (value == true) {
                    _selectedBookIds.add(book.id!);
                  } else {
                    _selectedBookIds.remove(book.id);
                  }
                });
              },
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddEditBookScreen(
                    database: _database,
                    book: book,
                  ),
                ),
              ).then((_) {
                openDatabaseAndFetchBooks();
              });
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddEditBookScreen(database: _database),
            ),
          ).then((_) {
            openDatabaseAndFetchBooks();
          });
        },
      ),
      persistentFooterButtons: [
        ElevatedButton(
          child: const Text('Delete Selected'),
          onPressed: _selectedBookIds.isNotEmpty
              ? () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Delete Selected Books'),
                        content: const Text(
                          'Are you sure you want to delete the selected books?',
                        ),
                        actions: [
                          TextButton(
                            child: const Text('Cancel'),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                          TextButton(
                            child: const Text('Delete'),
                            onPressed: () {
                              deleteSelectedBooks();
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      );
                    },
                  );
                }
              : null,
        ),
      ],
    );
  }

  Future<void> deleteSelectedBooks() async {
    for (int bookId in _selectedBookIds) {
      await _database.delete(
        'books',
        where: 'id = ?',
        whereArgs: [bookId],
      );
    }
    _selectedBookIds.clear();
    openDatabaseAndFetchBooks();
  }
}