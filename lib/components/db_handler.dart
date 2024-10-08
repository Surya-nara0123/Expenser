import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';

import 'package:flutter/widgets.dart';

Future<Database> initializeDB() async {
  WidgetsFlutterBinding.ensureInitialized();

  // print("path");
  final path = join(await getDatabasesPath(), 'expenser.db');
  return openDatabase(
    path,
    version: 1,
    onCreate: (db, version) async {
      // Create tables
      await db.execute('''
          CREATE TABLE Allpayments(
            id INTEGER PRIMARY KEY AUTOINCREMENT, 
            title TEXT, 
            reason TEXT, 
            date TEXT, 
            category INT,
            amount REAL
          );
        ''');

      await db.execute('''
          CREATE TABLE Categories(
            id INTEGER PRIMARY KEY AUTOINCREMENT, 
            category TEXT, 
            description TEXT, 
            color TEXT
          );
        ''');

      // Insert default categories
      await db.insert('Categories', {
        'category': 'Fees',
        'description':
            'Mandatory fee payments (exam fees, mess fees, clg fees)',
        'color': '0xFFE57373'
      });

      await db.insert('Categories', {
        'category': 'Liesure',
        'description': 'Avoidable expanses for pleasure and indulgence',
        'color': '0xFF81C784'
      });

      await db.insert('Categories', {
        'category': 'Unavoidables',
        'description':
            'Unavoidable expenses due to emergencies (missing mess, etc)',
        'color': '0xFF64B5F6'
      });

      await db.insert('Categories', {
        'category': 'Reimbursables',
        'description': 'House expenses like buying something for the house',
        'color': '0xFF9575CD'
      });

      await db.insert('Categories', {
        'category': 'Credited',
        'description': 'Money credited to the bank',
        'color': '0xFFFFD54F'
      });
    },
  );
}

Future<void> insertItem(Database db, String title, String reason,int category, String date,
    double amount) async {
  await db.insert(
    'Allpayments',
    {
      'title': title,
      'reason': reason,
      'date': date,
      'category':category,
      'amount': amount, // Make sure amount is of type double
    },
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}