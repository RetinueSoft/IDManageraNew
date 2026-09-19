/// The member types of the network - see docs/member-hierarchy.md. The wire values
/// match the backend's UserRole (2 was the removed Admin role).
enum UserRole {
  unknown,
  superAdmin,
  distributor,
  retailer,
  user;

  static UserRole fromInt(int value) => switch (value) {
    1 => UserRole.superAdmin,
    3 => UserRole.distributor,
    4 => UserRole.user,
    5 => UserRole.retailer,
    _ => UserRole.unknown,
  };

  int toInt() => switch (this) {
    UserRole.superAdmin => 1,
    UserRole.distributor => 3,
    UserRole.user => 4,
    UserRole.retailer => 5,
    UserRole.unknown => 0,
  };

  String get label => switch (this) {
    UserRole.superAdmin => 'Super Admin',
    UserRole.distributor => 'Distributor',
    UserRole.retailer => 'Retailer',
    UserRole.user => 'User',
    UserRole.unknown => 'Unknown',
  };

  /// The roles this role can add (docs/member-hierarchy.md, section 2). The backend
  /// enforces the same rule; this only decides what the screens offer.
  List<UserRole> get creatableRoles => switch (this) {
    UserRole.superAdmin || UserRole.distributor => const [
      UserRole.distributor,
      UserRole.retailer,
      UserRole.user,
    ],
    UserRole.retailer => const [UserRole.retailer, UserRole.user],
    _ => const [],
  };

  /// Whether this role has the member screens (Users, allocating points).
  bool get canManageMembers => creatableRoles.isNotEmpty;
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
