class Expense {
  final int? id; // Nulável pois o ID é gerado pelo banco ao inserir
  final String description;
  final double value;
  final DateTime date;

  Expense({
    this.id,
    required this.description,
    required this.value,
    required this.date,
  });

  // Converte um objeto Expense para um Map.
  // Usado ao inserir/atualizar no banco de dados.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': description,
      'value': value,
      'date': date.toIso8601String(), // Armazena a data como texto
    };
  }

  // Converte um Map para um objeto Expense.
  // Usado ao ler dados do banco de dados.
  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      description: map['description'],
      value: map['value'],
      date: DateTime.parse(map['date']), // Converte o texto de volta para DateTime
    );
  }
}
