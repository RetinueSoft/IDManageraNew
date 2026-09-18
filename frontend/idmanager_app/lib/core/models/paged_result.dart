class PagedResult<T> {
  final List<T> items;
  final int totalCount;
  final int pageIndex;
  final int pageSize;

  PagedResult({
    required this.items,
    required this.totalCount,
    required this.pageIndex,
    required this.pageSize,
  });

  factory PagedResult.fromJson(Map<String, dynamic> json, T Function(Map<String, dynamic>) fromJsonT) =>
      PagedResult(
        items: (json['items'] as List<dynamic>? ?? [])
            .map((e) => fromJsonT(e as Map<String, dynamic>))
            .toList(),
        totalCount: json['totalCount'] as int? ?? 0,
        pageIndex: json['pageIndex'] as int? ?? 1,
        pageSize: json['pageSize'] as int? ?? 20,
      );
}
