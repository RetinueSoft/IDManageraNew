namespace IDManager.Infrastructure.Cards;

/// The demo logins, by phone number (DemoAccounts:Phones). A demo account's card preview has no
/// watermark, so its points are taken as soon as the card is previewed instead of when the PDF is
/// downloaded, and without enough points there is no preview (docs/member-hierarchy.md, section 5).
public class DemoAccounts(IEnumerable<string>? phones = null)
{
    private readonly HashSet<string> _phones = new(
        (phones ?? []).Where(p => !string.IsNullOrWhiteSpace(p)).Select(p => p.Trim()),
        StringComparer.Ordinal);

    public static DemoAccounts None { get; } = new();

    public bool IsDemo(string? phone) => phone is not null && _phones.Contains(phone.Trim());
}
