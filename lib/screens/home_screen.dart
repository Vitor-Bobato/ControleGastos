import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:controlegastos/models/expense_model.dart';
import 'package:controlegastos/services/database_helper.dart';
import 'package:controlegastos/services/settings_service.dart';
import 'package:controlegastos/screens/settings_screen.dart';
import 'package:controlegastos/widgets/add_expense_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Expense>> _expensesFuture;
  final SettingsService _settingsService = SettingsService();

  String _currency = 'R\$';
  double _dailyLimit = 0.0;

  @override
  void initState() {
    super.initState();
    _loadSettingsAndExpenses();
  }

  Future<void> _loadSettingsAndExpenses() async {
    await _settingsService.init();
    setState(() {
      _currency = _settingsService.getCurrency();
      _dailyLimit = _settingsService.getDailyLimit();
      _expensesFuture = DatabaseHelper.instance.getAllExpenses();
    });
  }

  void _refreshData() {
    _loadSettingsAndExpenses();
  }

  void _showAddExpenseDialog() {
    showDialog(
      context: context,
      builder: (context) => AddExpenseDialog(
        onExpenseAdded: () {
          _refreshData();
        },
      ),
    );
  }

  // Função para apagar a despesa
  Future<void> _deleteExpense(Expense expense) async {
    // Apaga do banco de dados
    await DatabaseHelper.instance.deleteExpense(expense.id!);

    // Remove qualquer SnackBar que já esteja visível
    if (mounted) {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Despesa excluída."),
          action: SnackBarAction(
            label: "DESFAZER",
            onPressed: () {
              _undoDelete(expense);
            },
          ),
        ),
      );
    }

    // Atualiza a lista na tela
    setState(() {
      _expensesFuture = DatabaseHelper.instance.getAllExpenses();
    });
  }

  // Função para restaurar a despesa apagada
  Future<void> _undoDelete(Expense expense) async {
    // Recria a despesa (o banco de dados dará um novo ID)
    final restoredExpense = Expense(
      description: expense.description,
      value: expense.value,
      date: expense.date,
    );
    await DatabaseHelper.instance.addExpense(restoredExpense);

    // Atualiza a lista na tela
    setState(() {
      _expensesFuture = DatabaseHelper.instance.getAllExpenses();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Despesas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
              _refreshData(); // Recarrega as configurações ao voltar
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSummaryCard(),
          Expanded(
            child: FutureBuilder<List<Expense>>(
              future: _expensesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Erro: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      'Nenhuma despesa registrada ainda.',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  );
                }

                final expenses = snapshot.data!;
                return ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: expenses.length,
                  itemBuilder: (context, index) {
                    final expense = expenses[index];
                    return Dismissible(
                      key: ValueKey(expense.id), // Chave única para o widget
                      direction: DismissDirection
                          .endToStart, // Deslizar da direita para esquerda
                      onDismissed: (direction) {
                        _deleteExpense(expense);
                      },
                      background: Container(
                        color: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        alignment: Alignment.centerRight,
                        child: const Icon(Icons.delete_forever,
                            color: Colors.white),
                      ),
                      child: Card(
                        margin: const EdgeInsets.symmetric(vertical: 6.0),
                        child: ListTile(
                          leading: const Icon(Icons.monetization_on,
                              color: Colors.amber),
                          title: Text(expense.description,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(
                              DateFormat('dd/MM/yyyy').format(expense.date)),
                          trailing: Text(
                            '$_currency ${expense.value.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.indigo,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddExpenseDialog,
        tooltip: 'Adicionar Despesa',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Card(
      margin: const EdgeInsets.all(12.0),
      color: Colors.indigo.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Limite Diário:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              '$_currency ${_dailyLimit.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
