// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audit_log_list_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AuditLogListController)
final auditLogListControllerProvider = AuditLogListControllerProvider._();

final class AuditLogListControllerProvider
    extends
        $AsyncNotifierProvider<AuditLogListController, List<AuditLogEntry>> {
  AuditLogListControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'auditLogListControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$auditLogListControllerHash();

  @$internal
  @override
  AuditLogListController create() => AuditLogListController();
}

String _$auditLogListControllerHash() =>
    r'0544a2ed63c94af35617ae342f41b787386de5d7';

abstract class _$AuditLogListController
    extends $AsyncNotifier<List<AuditLogEntry>> {
  FutureOr<List<AuditLogEntry>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<AuditLogEntry>>, List<AuditLogEntry>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<AuditLogEntry>>, List<AuditLogEntry>>,
              AsyncValue<List<AuditLogEntry>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
