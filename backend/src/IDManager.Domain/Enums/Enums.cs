namespace IDManager.Domain.Enums;

public enum UserRole
{
    Unknown = 0,
    SuperAdmin = 1,
    // 2 was Admin - removed; existing rows were migrated to Distributor. Don't reuse it.
    Distributor = 3,
    User = 4,
    Retailer = 5,
}

public enum LayerFieldType
{
    Text = 1,
    Image = 2,
}

public enum CardSide
{
    Front = 1,
    Back = 2,
}

public enum PointTransType
{
    Earn = 1,
    Spend = 2,
    EarnForCard = 3,
    SpendForCard = 4,
}

public enum PointStatus
{
    Pending = 1,
    Completed = 2,
    Failed = 3,
}
