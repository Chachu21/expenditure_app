import 'package:expenditure_app/model/borrow.dart';
import 'package:expenditure_app/model/expense.dart';
import 'package:expenditure_app/model/loan.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  late Database _database;

  Future<void> init() async {
    _database = await openDatabase(
      join(await getDatabasesPath(), 'finance_app.db'),
      onCreate: (db, version) {
        db.execute(
          'CREATE TABLE expenses(id INTEGER PRIMARY KEY AUTOINCREMENT, date TEXT, amount REAL, reason TEXT)',
        );
        db.execute(
          'CREATE TABLE loans(id INTEGER PRIMARY KEY AUTOINCREMENT, date TEXT, amount REAL, person TEXT)',
        );
        db.execute(
          'CREATE TABLE borrowings(id INTEGER PRIMARY KEY AUTOINCREMENT, date TEXT, amount REAL, person TEXT)',
        );
      },
      version: 1,
    );
  }

  Future<void> insertExpense(Expense expense) async {
    await _database.insert(
      'expenses',
      expense.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Expense>> getExpenses() async {
    final List<Map<String, dynamic>> maps = await _database.query('expenses');
    return List.generate(maps.length, (i) {
      return Expense.fromMap(maps[i]);
    });
  }

  Future<void> deleteExpense(int id) async {
    await _database.delete(
      'expenses',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> insertLoan(Loan loan) async {
    await _database.insert(
      'loans',
      loan.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Loan>> getLoans() async {
    final List<Map<String, dynamic>> maps = await _database.query('loans');
    return List.generate(maps.length, (i) {
      return Loan.fromMap(maps[i]);
    });
  }

  Future<void> deleteLoan(int id) async {
    await _database.delete(
      'loans',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> insertBorrowing(Borrow borrow) async {
    await _database.insert(
      'borrowings',
      borrow.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Borrow>> getBorrowings() async {
    final List<Map<String, dynamic>> maps = await _database.query('borrowings');
    return List.generate(maps.length, (i) {
      return Borrow.fromMap(maps[i]);
    });
  }

  Future<void> deleteBorrowing(int id) async {
    await _database.delete(
      'borrowings',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
