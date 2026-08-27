import '../../domain/entities/transaction.dart';
class TransactionModel extends TransactionEntity {
  TransactionModel({
    required super.id, required super.amount, required super.date,
    required super.category, required super.note, required super.actor, 
    required super.type, super.receiptImagePath,
  });
  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'], amount: (json['amount'] as num).toDouble(), date: DateTime.parse(json['date']),
      category: json['category'], note: json['note'] ?? '',
      actor: Actor.values.firstWhere((e) => e.name == json['actor']),
      type: TransactionType.values.firstWhere((e) => e.name == json['type']),
      receiptImagePath: json['receiptImagePath'],
    );
  }
  Map<String, dynamic> toJson() => {
    'id': id, 'amount': amount, 'date': date.toIso8601String(),
    'category': category, 'note': note, 'actor': actor.name, 'type': type.name,
    'receiptImagePath': receiptImagePath,
  };
  factory TransactionModel.fromEntity(TransactionEntity entity) => TransactionModel(
    id: entity.id, amount: entity.amount, date: entity.date,
    category: entity.category, note: entity.note, actor: entity.actor, 
    type: entity.type, receiptImagePath: entity.receiptImagePath,
  );
}
