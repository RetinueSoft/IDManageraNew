import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:idmanager_app/core_engine/common/enums.dart';
import 'package:idmanager_app/core_engine/common/paged_result.dart';
import 'package:idmanager_app/core_engine/common/uploaded_file.dart';
import 'package:idmanager_app/core_engine/common/validation_exception.dart';
import 'package:idmanager_app/core_engine/templates/contracts/template_repository.dart';
import 'package:idmanager_app/core_engine/templates/domain/card_template.dart';
import 'package:idmanager_app/core_engine/templates/domain/template_layer.dart';
import 'package:idmanager_app/core_engine/templates/template_engine.dart';
import 'package:idmanager_app/foundation/network/api_exception.dart';

CardTemplateDetail _detail({int id = 1, String name = 'Card'}) => CardTemplateDetail(
  template: CardTemplate(
    id: id,
    name: name,
    cardWidthMm: 85.6,
    cardHeightMm: 54,
    pointCost: 1,
    isActive: true,
    frontImageBase64: '',
    backImageBase64: '',
    createdAt: DateTime(2026, 1, 1),
  ),
);

UploadedFile _file() => UploadedFile(Uint8List.fromList([1, 2, 3]), 'front.png');

class _FakeTemplateRepository implements TemplateRepository {
  Object? createError;
  CardTemplateDetail? createReturns;
  List<TemplateLayer>? savedLayers;
  int? savedTemplateId;

  @override
  Future<PagedResult<CardTemplate>> getAll({int pageIndex = 1, int pageSize = 20, String? searchBy}) async =>
      PagedResult(items: const [], totalCount: 0, pageIndex: pageIndex, pageSize: pageSize);

  @override
  Future<CardTemplateDetail?> getById(int id) async => null;

  @override
  Future<CardTemplateDetail> create({
    required String name,
    required double cardWidthMm,
    required double cardHeightMm,
    required int pointCost,
    required UploadedFile frontFile,
    required UploadedFile backFile,
    String groupsJson = '[]',
  }) async {
    if (createError != null) throw createError!;
    return createReturns!;
  }

  @override
  Future<CardTemplateDetail> update({
    required int id,
    required String name,
    required int pointCost,
    required bool isActive,
    String groupsJson = '[]',
    UploadedFile? frontFile,
    UploadedFile? backFile,
  }) async => _detail(id: id, name: name);

  @override
  Future<void> setActive(int id, bool active) async {}

  @override
  Future<void> saveLayers(int templateId, List<TemplateLayer> layers) async {
    savedTemplateId = templateId;
    savedLayers = layers;
  }

  @override
  Future<Combination> addCombination({
    required int templateId,
    required String name,
    required UploadedFile frontFile,
    required UploadedFile backFile,
  }) async => Combination(id: 1, name: name, frontImageBase64: '', backImageBase64: '');

  @override
  Future<void> deleteCombination(int combinationId) async {}
}

void main() {
  group('TemplateEngineService.create', () {
    test('throws ValidationException locally when name/images are missing', () async {
      final repo = _FakeTemplateRepository();
      final engine = TemplateEngineService(repo);

      try {
        await engine.create(
          name: '',
          cardWidthMm: 85.6,
          cardHeightMm: 54,
          pointCost: 1,
          frontFile: null,
          backFile: null,
        );
        fail('expected a ValidationException');
      } on ValidationException catch (e) {
        expect(e.errors.keys, containsAll(['name', 'frontImage', 'backImage']));
      }
    });

    test('passes through to the repository when valid', () async {
      final repo = _FakeTemplateRepository()..createReturns = _detail(name: 'Employee Card');
      final engine = TemplateEngineService(repo);

      final result = await engine.create(
        name: 'Employee Card',
        cardWidthMm: 85.6,
        cardHeightMm: 54,
        pointCost: 1,
        frontFile: _file(),
        backFile: _file(),
      );

      expect(result.template.name, 'Employee Card');
    });

    test('converts field-error ApiException into ValidationException', () async {
      final repo = _FakeTemplateRepository()
        ..createError = ApiException('bad', fieldErrors: {'name': 'Name already used.'});
      final engine = TemplateEngineService(repo);

      try {
        await engine.create(
          name: 'Dup',
          cardWidthMm: 85.6,
          cardHeightMm: 54,
          pointCost: 1,
          frontFile: _file(),
          backFile: _file(),
        );
        fail('expected a ValidationException');
      } on ValidationException catch (e) {
        expect(e.errors['name'], 'Name already used.');
      }
    });
  });

  group('TemplateEngineService.saveLayers', () {
    test('forwards the exact template id and layer list to the repository', () async {
      final repo = _FakeTemplateRepository();
      final engine = TemplateEngineService(repo);
      final layers = [TemplateLayer(side: CardSide.front, groups: const [])];

      await engine.saveLayers(7, layers);

      expect(repo.savedTemplateId, 7);
      expect(repo.savedLayers, same(layers));
    });
  });
}
