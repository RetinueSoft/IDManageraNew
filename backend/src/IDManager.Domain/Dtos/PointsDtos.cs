using IDManager.Domain.Enums;

namespace IDManager.Domain.Dtos;

public class AdjustPointsRequest
{
    public int UserId { get; set; }
    public int Points { get; set; }
    public string Reason { get; set; } = string.Empty;
}

public class PointTransactionDto
{
    public DateTime Date { get; set; }
    public string Description { get; set; } = string.Empty;
    public int Points { get; set; }
    public PointTransType Type { get; set; }
    public PointStatus Status { get; set; }
}

public class GetPointsRequest : PagedRequest
{
    public int UserId { get; set; }
    public bool IncludeIncompleteAlso { get; set; }
}
