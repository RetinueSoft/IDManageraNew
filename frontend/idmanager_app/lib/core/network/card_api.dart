import 'package:dio/dio.dart';
import '../models/card.dart';
import '../models/template.dart';
import 'api_client.dart';
import 'template_api.dart';

class CardApi {
  final ApiClient _client;
  CardApi(this._client);

  Future<List<ExtractedField>> parsePdf(PickedFile file) => _client.postForm(
        '/Cards/ParsePdf',
        FormData.fromMap({
          'File': MultipartFile.fromBytes(file.bytes, filename: file.name),
        }),
        (data) => (data as List<dynamic>)
            .map((e) => ExtractedField.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Future<GenerateCardResponse> generate({
    required int templateId,
    required int combinationId,
    required PickedFile file,
  }) =>
      _client.postForm(
        '/Cards/Generate',
        FormData.fromMap({
          'TemplateId': templateId,
          'CombinationId': combinationId,
          'File': MultipartFile.fromBytes(file.bytes, filename: file.name),
        }),
        (data) => GenerateCardResponse.fromJson(data as Map<String, dynamic>),
      );

  /// Returns the raw print-ready PDF bytes (not wrapped in the ApiResponse envelope).
  Future<List<int>> download(int idCardId) => _client.postForBytes(
        '/Cards/Download',
        {'idCardId': idCardId},
      );
}
