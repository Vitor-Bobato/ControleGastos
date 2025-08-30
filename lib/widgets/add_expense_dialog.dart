import 'package:flutter/material.dart';
import 'package:controlegastos/models/expense_model.dart';
import 'package:controlegastos/services/database_helper.dart';

class AddExpenseDialog extends StatefulWidget {
  final VoidCallback onExpenseAdded;

  const AddExpenseDialog({super.key, required this.onExpenseAdded});

  @override
  State<AddExpenseDialog> createState() => _AddExpenseDialogState();
}

class _AddExpenseDialogState extends State<AddExpenseDialog> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _valueController = TextEditingController();

  @override
  void dispose() {
    _descriptionController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final newExpense = Expense(
        description: _descriptionController.text,
        value: double.parse(_valueController.text.replaceAll(',', '.')),
        date: DateTime.now(),
      );

      await DatabaseHelper.instance.addExpense(newExpense);

      if (mounted) {
        widget.onExpenseAdded();
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nova Despesa'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descrição',
                icon: Icon(Icons.description),
              ),
              validator: (value) =>
                  value!.isEmpty ? 'Por favor, insira uma descrição' : null,
            ),
            TextFormField(
              controller: _valueController,
              decoration: const InputDecoration(
                labelText: 'Valor',
                icon: Icon(Icons.attach_money),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, insira um valor';
                }
                if (double.tryParse(value.replaceAll(',', '.')) == null) {
                  return 'Por favor, insira um valor numérico válido';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}
