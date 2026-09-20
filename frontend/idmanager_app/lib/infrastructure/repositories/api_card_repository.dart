import '../../core_engine/templates/domain/template_layer.dart';

import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../core_engine/cards/contracts/card_repository.dart';
import '../../core_engine/cards/domain/generated_card.dart';
import '../../core_engine/common/uploaded_file.dart';
import '../../core_engine/templates/domain/field_group.dart';
import '../../foundation/network/api_client.dart';
import 'template_mappers.dart';

class ApiCardRepository implements CardRepository {
  ApiCardRepository(this._client);

  final ApiClient _client;

  @override
  Future<List<ExtractedField>> parsePdf(UploadedFile file) =>
      _client.guard(() async {
        final form = FormData.fromMap({
          'file': MultipartFile.fromBytes(file.bytes, filename: file.name),
        });
        final response = await _client.dio.post('/cards/parse-pdf', data: form);
        return (response.data as List<dynamic>)
            .map((e) => extractedFieldFromJson(e as Map<String, dynamic>))
            .toList();
      });

  @override
  Future<GeneratedCard> generate({
    required int templateId,
    required int combinationId,
    required UploadedFile file,
    Map<String, UploadedFile> qrImages = const {},
  }) => _client.guard(() async {
    final form = FormData.fromMap({
      'templateId': templateId,
      'combinationId': combinationId,
      'file': MultipartFile.fromBytes(file.bytes, filename: file.name),
      // Each QR slot's image goes as a file named "qr:<slot key>".
      for (final entry in qrImages.entries)
        'qr:${entry.key}': MultipartFile.fromBytes(
          entry.value.bytes,
          filename: entry.value.name,
        ),
    });
    final response = await _client.dio.post('/cards/generate', data: form);
    final body = response.data as Map<String, dynamic>;
    return GeneratedCard(
      idCardId: body['idCardId'] as int,
      layers: (body['layers'] as List<dynamic>? ?? [])
          .map((e) => templateLayerFromJson(e as Map<String, dynamic>))
          .toList(),
      cardWidthMm: (body['cardWidthMm'] as num?)?.toDouble() ?? 85.6,
      cardHeightMm: (body['cardHeightMm'] as num?)?.toDouble() ?? 54.0,
      frontImageBase64: body['frontImageBase64'] as String? ?? '',
      backImageBase64: body['backImageBase64'] as String? ?? '',
    );
  });

  @override
  Future<Uint8List> download(
    int idCardId,
    List<TemplateLayer> layers,
    int combinationId,
  ) => _client.guard(() async {
    final response = await _client.dio.post<List<int>>(
      '/cards/$idCardId/download',
      data: {
        'layers': layers.map(templateLayerToJson).toList(),
        'combinationId': combinationId,
      },
      options: Options(responseType: ResponseType.bytes),
    );
    return Uint8List.fromList(response.data ?? []);
  });
}
