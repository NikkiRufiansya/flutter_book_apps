import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';

import '../main.dart';
import '../models/book.dart';

class AddEditBookScreen extends StatefulWidget {
  final Database database;
  final Book? book;

  const AddEditBookScreen({required this.database, this.book});

  @override
  _AddEditBookScreenState createState() => _AddEditBookScreenState();
}

class _AddEditBookScreenState extends State<AddEditBookScreen> {
  late TextEditingController _codeController;
  late TextEditingController _isbnController;
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _publishDateController;
  late TextEditingController _priceController;
  late bool _hardCover;
  late String _selectedCategory;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController(text: widget.book?.code ?? '');
    _isbnController = TextEditingController(text: widget.book?.isbn ?? '');
    _titleController = TextEditingController(text: widget.book?.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.book?.description ?? '');
    _publishDateController =
        TextEditingController(text: widget.book?.publishDate ?? '');
    _priceController = TextEditingController(
        text: widget.book != null ? widget.book!.price.toString() : '');
    _hardCover = widget.book?.hardCover ?? false;
    _selectedCategory = widget.book?.category ?? 'Fiksi';
    _selectedDate = widget.book != null
        ? DateTime.parse(widget.book!.publishDate)
        : DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.book != null ? 'Edit Book' : 'Add Book'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          child: ListView(
            children: [
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(labelText: 'Book Code'),
              ),
              TextFormField(
                controller: _isbnController,
                decoration: const InputDecoration(labelText: 'ISBN'),
              ),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Book Title'),
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Book Description'),
              ),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: _buildDropdownItems(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
                decoration: const InputDecoration(labelText: 'Book Category'),
              ),
              GestureDetector(
                onTap: () {
                  _showDatePicker(context);
                },
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: _publishDateController,
                    decoration: const InputDecoration(labelText: 'Publish Date'),
                  ),
                ),
              ),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Price'),
              ),
              CheckboxListTile(
                title: const Text('Hard Cover'),
                value: _hardCover,
                onChanged: (value) {
                  setState(() {
                    _hardCover = value!;
                  });
                },
              ),
              ElevatedButton(
                child: Text(widget.book != null ? 'Update' : 'Save'),
                onPressed: () {
                  final book = Book(
                    id: widget.book?.id,
                    code: _codeController.text,
                    isbn: _isbnController.text,
                    title: _titleController.text,
                    description: _descriptionController.text,
                    category: _selectedCategory,
                    publishDate: _selectedDate.toIso8601String(),
                    price: double.parse(_priceController.text),
                    hardCover: _hardCover,
                  );
                  if (widget.book != null) {
                    updateBook(book);
                  } else {
                    insertBook(book);
                  }
                  Navigator.pop(context);
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> insertBook(Book book) async {
    await widget.database.insert('books', book.toMap());
  }

  Future<void> updateBook(Book book) async {
    await widget.database.update(
      'books',
      book.toMap(),
      where: 'id = ?',
      whereArgs: [book.id],
    );
  }

  List<DropdownMenuItem<String>> _buildDropdownItems() {
    return [
      const DropdownMenuItem(
        value: 'Fiksi',
        child: Text('Fiksi'),
      ),
      const DropdownMenuItem(
        value: 'Fantasi',
        child: Text('Fantasi'),
      ),
       const DropdownMenuItem(
        value: 'Sains Fiksi (Science Fiction)',
        child: Text('Sains Fiksi (Science Fiction)'),
      ),
      const DropdownMenuItem(
        value: 'Misteri dan Detektif',
        child: Text('Misteri dan Detektif'),
      ),
      const DropdownMenuItem(
        value: 'Sejarah',
        child: Text('Sejarah'),
      ),
      const DropdownMenuItem(
        value: 'Biografi',
        child: Text('Biografi'),
      ),
      const DropdownMenuItem(
        value: 'Pendidikan',
        child: Text('Pendidikan'),
      ),
      const DropdownMenuItem(
        value: 'Drama',
        child: Text('Drama'),
      ),
      const DropdownMenuItem(
        value: 'Psikologi',
        child: Text('Psikologi'),
      ),
      // Add more items as needed
    ];
  }

  Future<void> _showDatePicker(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
        _publishDateController.text =
            DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }
}