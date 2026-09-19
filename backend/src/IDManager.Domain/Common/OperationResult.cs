namespace IDManager.Domain.Common;

public enum ResultStatus
{
    Success,
    NotFound,
    ValidationFailed,
    Unauthorized,
    Forbidden,
    Conflict,
}

/// A single Result type shared by every Infrastructure service, instead of one
/// bespoke Outcome enum per operation: this app's CRUD operations share the same
/// handful of shapes (not-found, field-validation, conflict, ...), so one generic
/// type keeps every Endpoint's Outcome-to-HTTP-status mapping identical
/// (see EndpointResults) without enum-per-operation duplication.
public class OperationResult
{
    public ResultStatus Status { get; init; }
    public string? Error { get; init; }
    public IDictionary<string, string>? FieldErrors { get; init; }

    public static OperationResult Success() => new() { Status = ResultStatus.Success };
    public static OperationResult NotFound(string error) => new() { Status = ResultStatus.NotFound, Error = error };
    public static OperationResult Invalid(string error) => new() { Status = ResultStatus.ValidationFailed, Error = error };
    public static OperationResult Invalid(IDictionary<string, string> fieldErrors) =>
        new() { Status = ResultStatus.ValidationFailed, FieldErrors = fieldErrors };
    public static OperationResult Conflict(string error) => new() { Status = ResultStatus.Conflict, Error = error };
    public static OperationResult Forbidden(string error) => new() { Status = ResultStatus.Forbidden, Error = error };
}

public class OperationResult<T> : OperationResult
{
    public T? Value { get; init; }

    public static OperationResult<T> Success(T value) => new() { Status = ResultStatus.Success, Value = value };
    public static new OperationResult<T> NotFound(string error) => new() { Status = ResultStatus.NotFound, Error = error };
    public static new OperationResult<T> Invalid(string error) => new() { Status = ResultStatus.ValidationFailed, Error = error };
    public static new OperationResult<T> Invalid(IDictionary<string, string> fieldErrors) =>
        new() { Status = ResultStatus.ValidationFailed, FieldErrors = fieldErrors };
    public static new OperationResult<T> Conflict(string error) => new() { Status = ResultStatus.Conflict, Error = error };
    public static new OperationResult<T> Forbidden(string error) => new() { Status = ResultStatus.Forbidden, Error = error };
}
