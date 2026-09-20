namespace IDManager.Domain.Dtos;

/// What the dashboard shows the signed-in member.
public class DashboardSummaryDto
{
    /// Their current point balance.
    public int Balance { get; set; }

    /// Points that came in / went out this calendar month, and over all time (only points that
    /// were actually applied - a card's points count once its PDF is downloaded).
    public int CreditThisMonth { get; set; }
    public int DebitThisMonth { get; set; }
    public int CreditTotal { get; set; }
    public int DebitTotal { get; set; }

    /// Every card generated (previewed, whether or not its PDF was downloaded) by the members they
    /// can see, themselves included, this month and in all. For the Super Admin that is every card in
    /// the whole app.
    public int CardsThisMonth { get; set; }
    public int CardsTotal { get; set; }

    /// How many members they can see, not counting themselves or any Super Admin - for the Super
    /// Admin every member of the whole app. Null for a member who has no member screens (a User).
    public int? MembersCount { get; set; }

    /// The same members counted by role (they add up to MembersCount). Null when MembersCount is.
    public MemberRoleCountsDto? MembersByRole { get; set; }

    /// The last twelve calendar months, oldest first, every month present (zero when nothing
    /// happened): points credited and debited to them.
    public List<MonthlyPointsDto> Months { get; set; } = new();
}

public class MemberRoleCountsDto
{
    public int Distributors { get; set; }
    public int Retailers { get; set; }
    public int Users { get; set; }
    public int Total => Distributors + Retailers + Users;
}

public class MonthlyPointsDto
{
    public int Year { get; set; }
    public int Month { get; set; }
    public int Credit { get; set; }
    public int Debit { get; set; }
}
