import 'package:dio/dio.dart';

import '../../core_engine/common/paged_result.dart';
import '../../core_engine/common/uploaded_file.dart';
import '../../core_engine/templates/contracts/template_repository.dart';
import '../../core_engine/templates/domain/card_template.dart';
import '../../core_engine/templates/domain/field_group.dart';
import '../../core_engine/templates/domain/template_layer.dart';
import '../../foundation/network/api_client.dart';
import 'template_mappers.dart';

class ApiTemplateRepository implements TemplateRepository {
  ApiTemplateRepository(this._client);

  final ApiClient _client;

  @override
  Future<PagedResult<CardTemplate>> getAll({int pageIndex = 1, int pageSize = 20, String? searchBy}) =>
      _client.guard(() async {
        final response = await _client.dio.post(
          '/templates/list',
          data: {'pageIndex': pageIndex, 'pageSize': pageSize, 'searchBy': searchBy},
        );
        return PagedResult.fromJson(response.data as Map<String, dynamic>, cardTemplateFromJson);
      });

  @override
  Future<CardTemplateDetail?> getById(int id) => _client.guard(() async {
    final response = await _client.dio.get('/templates/$id');
    return cardTemplateDetailFromJson(response.data as Map<String, dynamic>);
  });

  @override
  Future<CardTemplateDetail> create({
    required String name,
    required double cardWidthMm,
    required double cardHeightMm,
    required int pointCost,
    required UploadedFile frontFile,
    required UploadedFile backFile,
    String groupsJson = '[]',
  }) => _client.guard(() async {
    final form = FormData.fromMap({
      'name': name,
      'cardWidthMm': cardWidthMm,
      'cardHeightMm': cardHeightMm,
      'pointCost': pointCost,
      'groupsJson': groupsJson,
      'frontFile': MultipartFile.fromBytes(frontFile.bytes, filename: frontFile.name),
      'backFile': MultipartFile.fromBytes(backFile.bytes, filename: backFile.name),
    });
    final response = await _client.dio.post('/templates/', data: form);
    return cardTemplateDetailFromJson(response.data as Map<String, dynamic>);
  });

  @override
  Future<CardTemplateDetail> update({
    required int id,
    required String name,
    required double cardWidthMm,
    required double cardHeightMm,
    required int pointCost,
    required bool isActive,
    String? groupsJson,
    UploadedFile? frontFile,
    UploadedFile? backFile,
  }) => _client.guard(() async {
    final form = FormData.fromMap({
      'name': name,
      'cardWidthMm': cardWidthMm,
      'cardHeightMm': cardHeightMm,
      'pointCost': pointCost,
      'isActive': isActive,
      if (groupsJson != null) 'groupsJson': groupsJson,
      if (frontFile != null)
        'frontFile': MultipartFile.fromBytes(frontFile.bytes, filename: frontFile.name),
      if (backFile != null) 'backFile': MultipartFile.fromBytes(backFile.bytes, filename: backFile.name),
    });
    final response = await _client.dio.put('/templates/$id', data: form);
    return cardTemplateDetailFromJson(response.data as Map<String, dynamic>);
  });

  @override
  Future<void> setActive(int id, bool active) => _client.guard(
    () => _client.dio.post('/templates/$id/${active ? 'activate' : 'deactivate'}'),
  );

  @override
  Future<void> saveLayers(int templateId, List<TemplateLayer> layers, {List<FieldGroup>? groups}) =>
      _client.guard(
        () => _client.dio.post(
          '/templates/layers',
          data: {
            'templateId': templateId,
            'layers': layers.map(templateLayerToJson).toList(),
            if (groups != null) 'groups': groups.map(fieldGroupToJson).toList(),
          },
        ),
      );

  @override
  Future<Combination> addCombination({
    required int templateId,
    required String name,
    required UploadedFile frontFile,
    required UploadedFile backFile,
  }) => _client.guard(() async {
    final form = FormData.fromMap({
      'templateId': templateId,
      'name': name,
      'frontFile': MultipartFile.fromBytes(frontFile.bytes, filename: frontFile.name),
      'backFile': MultipartFile.fromBytes(backFile.bytes, filename: backFile.name),
    });
    final response = await _client.dio.post('/templates/combinations', data: form);
    return combinationFromJson(response.data as Map<String, dynamic>);
  });

  @override
  Future<void> deleteCombination(int combinationId) =>
      _client.guard(() => _client.dio.delete('/templates/combinations/$combinationId'));
}
