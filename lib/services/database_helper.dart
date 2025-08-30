import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:controlegastos/models/expense_model.dart';

class DatabaseHelper {
  // Padrão Singleton para garantir uma única instância do banco de dados
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async => _database ??= await _initDatabase();

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'travel_expenses.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  // Cria a tabela de despesas quando o banco é criado pela primeira vez
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE expenses(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        description TEXT NOT NULL,
        value REAL NOT NULL,
        date TEXT NOT NULL
      )
    ''');
  }

  // Adiciona uma nova despesa ao banco de dados
  Future<int> addExpense(Expense expense) async {
    Database db = await instance.database;
    return await db.insert('expenses', expense.toMap());
  }

  // Retorna todas as despesas, ordenadas pela data mais recente
  Future<List<Expense>> getAllExpenses() async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> maps =
        await db.query('expenses', orderBy: 'date DESC');

    return List.generate(maps.length, (i) {
      return Expense.fromMap(maps[i]);
    });
  }

  // (Não solicitado, mas útil para o futuro)
  // Atualiza uma despesa
  Future<int> updateExpense(Expense expense) async {
    Database db = await instance.database;
    return await db.update(
      'expenses',
      expense.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  // (Não solicitado, mas útil para o futuro)
  // Deleta uma despesa
  Future<int> deleteExpense(int id) async {
    Database db = await instance.database;
    return await db.delete(
      'expenses',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
