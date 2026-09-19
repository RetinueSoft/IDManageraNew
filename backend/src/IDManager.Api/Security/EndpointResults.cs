using IDManager.Domain.Common;

namespace IDManager.Api.Security;

/// Maps every Infrastructure service's OperationResult to the matching HTTP
/// response, so every Endpoint file gets identical, real HTTP-status semantics
/// (404/400/403/409) instead of a single generic {success,message} envelope on
/// every response.
public static class EndpointResults
{
    public static IResult ToHttpResult(this OperationResult result) => result.Status switch
    {
        ResultStatus.Success => Results.Ok(),
        ResultStatus.NotFound => Results.NotFound(new { error = result.Error }),
        ResultStatus.ValidationFailed => Results.BadRequest(ErrorBody(result)),
        ResultStatus.Unauthorized => Results.Json(new { error = result.Error }, statusCode: StatusCodes.Status401Unauthorized),
        ResultStatus.Forbidden => Results.Json(new { error = result.Error }, statusCode: StatusCodes.Status403Forbidden),
        ResultStatus.Conflict => Results.Conflict(new { error = result.Error }),
        _ => Results.Problem("Unknown result status."),
    };

    public static IResult ToHttpResult<T>(this OperationResult<T> result) => result.Status switch
    {
        ResultStatus.Success => Results.Ok(result.Value),
        ResultStatus.NotFound => Results.NotFound(new { error = result.Error }),
        ResultStatus.ValidationFailed => Results.BadRequest(ErrorBody(result)),
        ResultStatus.Unauthorized => Results.Json(new { error = result.Error }, statusCode: StatusCodes.Status401Unauthorized),
        ResultStatus.Forbidden => Results.Json(new { error = result.Error }, statusCode: StatusCodes.Status403Forbidden),
        ResultStatus.Conflict => Results.Conflict(new { error = result.Error }),
        _ => Results.Problem("Unknown result status."),
    };

    /// A file (e.g. a generated PDF) that succeeded returns the raw bytes with the
    /// given content type; every other status is the same JSON error shape as
    /// every other endpoint.
    public static IResult ToFileResult(this OperationResult<byte[]> result, string contentType, string fileName) =>
        result.Status == ResultStatus.Success
            ? Results.File(result.Value!, contentType, fileName)
            : result.ToHttpResult();

    private static object ErrorBody(OperationResult result) =>
        result.FieldErrors is { Count: > 0 }
            ? new { errors = result.FieldErrors }
            : new { error = result.Error };
}
