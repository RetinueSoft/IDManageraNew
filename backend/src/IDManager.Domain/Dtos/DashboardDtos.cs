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

    /// Cards whose PDF was downloaded by the members they can see (themselves included), this
    /// month and in all.
    public int CardsThisMonth { get; set; }
    public int CardsTotal { get; set; }

    /// How many members they can see, not counting themselves. Null for a member who has no member
    /// screens (a User).
    public int? MembersCount { get; set; }

    /// The last twelve calendar months, oldest first, every month present (zero when nothing
    /// happened): points credited and debited to them.
    public List<MonthlyPointsDto> Months { get; set; } = new();
}

public class MonthlyPointsDto
{
    public int Year { get; set; }
    public int Month { get; set; }
    public int Credit { get; set; }
    public int Debit { get; set; }
}
