enum Actor { hidayatullah, deasy }

extension ActorExt on Actor {
  String get fullName {
    switch (this) {
      case Actor.hidayatullah:
        return 'Hidayatullah';
      case Actor.deasy:
        return 'Deasy Amalia Widianingsih';
    }
  }

  String get shortName {
    switch (this) {
      case Actor.hidayatullah:
        return 'Hidayatullah';
      case Actor.deasy:
        return 'Deasy Amalia W.';
    }
  }
}

enum TransactionType { income, expense, initialBalance }

class TransactionEntity {
  final String id;
  final double amount;
  final DateTime date;
  final String category;
  final String note;
  final Actor actor;
  final TransactionType type;
  final String? receiptImagePath;

  TransactionEntity({
    required this.id,
    required this.amount,
    required this.date,
    required this.category,
    this.note = '',
    required this.actor,
    required this.type,
    this.receiptImagePath,
  });
}
