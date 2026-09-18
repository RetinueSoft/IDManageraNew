import 'package:dio/dio.dart';
import '../models/layer.dart';
import '../models/paged_result.dart';
import '../models/template.dart';
import 'api_client.dart';

class PickedFile {
  final List<int> bytes;
  final String name;
  PickedFile(this.bytes, this.name);
}

class TemplateApi {
  final ApiClient _client;
  TemplateApi(this._client);

  Future<PagedResult<TemplateSummary>> getAll({int pageIndex = 1, int pageSize = 20, String? searchBy}) =>
      _client.postJson(
        '/Templates/GetAll',
        {'pageIndex': pageIndex, 'pageSize': pageSize, 'searchBy': searchBy},
        (data) => PagedResult.fromJson(
            data as Map<String, dynamic>, (e) => TemplateSummary.fromJson(e)),
      );

  Future<TemplateDetail> getTemplate(int id) => _client.getJson(
        '/Templates/$id',
        (data) => TemplateDetail.fromJson(data as Map<String, dynamic>),
      );

  Future<TemplateDetail> create({
    required String name,
    required double cardWidthMm,
    required double cardHeightMm,
    required int pointCost,
    required PickedFile frontFile,
    required PickedFile backFile,
    String groupsJson = '[]',
  }) =>
      _client.postForm(
        '/Templates/Create',
        FormData.fromMap({
          'Name': name,
          'CardWidthMm': cardWidthMm,
          'CardHeightMm': cardHeightMm,
          'PointCost': pointCost,
          'GroupsJson': groupsJson,
          'FrontFile': MultipartFile.fromBytes(frontFile.bytes, filename: frontFile.name),
          'BackFile': MultipartFile.fromBytes(backFile.bytes, filename: backFile.name),
        }),
        (data) => TemplateDetail.fromJson(data as Map<String, dynamic>),
      );

  Future<void> saveLayers(int templateId, List<TemplateLayer> layers) => _client.postJson(
        '/Templates/SaveLayers',
        {
          'templateId': templateId,
          'layers': layers.map((l) => l.toJson()).toList(),
        },
        (_) {},
      );

  Future<void> setActive(int templateId, bool active) => _client.postJson(
        active ? '/Templates/Activate' : '/Templates/Deactivate',
        templateId,
        (_) {},
      );

  Future<CombinationDto> addCombination({
    required int templateId,
    required String name,
    required PickedFile frontFile,
    required PickedFile backFile,
  }) =>
      _client.postForm(
        '/Templates/AddCombination',
        FormData.fromMap({
          'TemplateId': templateId,
          'Name': name,
          'FrontFile': MultipartFile.fromBytes(frontFile.bytes, filename: frontFile.name),
          'BackFile': MultipartFile.fromBytes(backFile.bytes, filename: backFile.name),
        }),
        (data) => CombinationDto.fromJson(data as Map<String, dynamic>),
      );

  Future<void> deleteCombination(int combinationId) => _client.postJson(
        '/Templates/DeleteCombination',
        combinationId,
        (_) {},
      );
}
