enum UserRole {
  unknown,
  superAdmin,
  admin,
  distributor,
  user;

  static UserRole fromInt(int value) =>
      value >= 0 && value < UserRole.values.length
      ? UserRole.values[value]
      : UserRole.unknown;

  int toInt() => index;

  String get label => switch (this) {
    UserRole.superAdmin => 'Super Admin',
    UserRole.admin => 'Admin',
    UserRole.distributor => 'Distributor',
    UserRole.user => 'User',
    UserRole.unknown => 'Unknown',
  };
}

enum LayerFieldType {
  text,
  image;

  static LayerFieldType fromInt(int value) =>
      value == 2 ? LayerFieldType.image : LayerFieldType.text;
  int toInt() => this == LayerFieldType.image ? 2 : 1;
}

enum CardSide {
  front,
  back;

  static CardSide fromInt(int value) => value == 2 ? CardSide.back : CardSide.front;
  int toInt() => this == CardSide.back ? 2 : 1;
}

enum PointTransType {
  earn,
  spend,
  earnForCard,
  spendForCard;

  static PointTransType fromInt(int value) =>
      value >= 1 && value <= 4 ? PointTransType.values[value - 1] : PointTransType.earn;
}

enum PointStatus {
  pending,
  completed,
  failed;

  static PointStatus fromInt(int value) =>
      value >= 1 && value <= 3 ? PointStatus.values[value - 1] : PointStatus.pending;
}
