import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:idmanager_app/core_engine/common/uploaded_file.dart';
import 'package:idmanager_app/presentation/users/identity_image_picker.dart';

UploadedFile file(String name, {int size = 10}) => UploadedFile(Uint8List(size), name);

Widget host({
  Uint8List? bytes,
  required Future<UploadedFile?> Function() pick,
  required List<UploadedFile> picked,
  required List<String> rejected,
  VoidCallback? onRemoved,
}) => MaterialApp(
  home: Scaffold(
    body: IdentityImagePicker(
      label: 'Front',
      bytes: bytes,
      pickImage: pick,
      onPicked: picked.add,
      onRemoved: onRemoved ?? () {},
      onRejected: rejected.add,
    ),
  ),
);

void main() {
  group('identityImageProblem', () {
    test('accepts JPG, JPEG, PNG and WebP in any case', () {
      for (final name in ['a.jpg', 'a.JPEG', 'card.PNG', 'c.webp']) {
        expect(identityImageProblem(file(name)), isNull, reason: name);
      }
    });

    test('refuses other file types', () {
      expect(identityImageProblem(file('scan.pdf')), isNotNull);
      expect(identityImageProblem(file('anim.gif')), isNotNull);
      expect(identityImageProblem(file('noextension')), isNotNull);
    });

    test('refuses an empty file and one over 5 MB', () {
      expect(identityImageProblem(file('a.jpg', size: 0)), isNotNull);
      expect(identityImageProblem(file('a.jpg', size: maxIdentityImageBytes)), isNull);
      expect(identityImageProblem(file('a.jpg', size: maxIdentityImageBytes + 1)), contains('5 MB'));
    });
  });

  testWidgets('with no picture it offers Choose, and no Remove', (tester) async {
    await tester.pumpWidget(host(pick: () async => null, picked: [], rejected: []));

    expect(find.text('Front of the ID card'), findsOneWidget);
    expect(find.text('No Front picture'), findsOneWidget);
    expect(find.text('Choose Front'), findsOneWidget);
    expect(find.text('Remove'), findsNothing);
  });

  testWidgets('with a picture it offers Replace and Remove', (tester) async {
    var removed = 0;
    await tester.pumpWidget(
      host(bytes: Uint8List.fromList(List.filled(8, 1)), pick: () async => null, picked: [], rejected: [], onRemoved: () => removed++),
    );

    expect(find.text('Replace Front'), findsOneWidget);
    expect(find.text('No Front picture'), findsNothing);
    await tester.tap(find.text('Remove'));
    expect(removed, 1);
  });

  testWidgets('a usable pick is passed on', (tester) async {
    final picked = <UploadedFile>[];
    await tester.pumpWidget(host(pick: () async => file('front.jpg'), picked: picked, rejected: []));

    await tester.tap(find.text('Choose Front'));
    await tester.pump();

    expect(picked.map((f) => f.name), ['front.jpg']);
  });

  testWidgets('an unusable pick is reported, not passed on', (tester) async {
    final picked = <UploadedFile>[];
    final rejected = <String>[];
    await tester.pumpWidget(host(pick: () async => file('scan.pdf'), picked: picked, rejected: rejected));

    await tester.tap(find.text('Choose Front'));
    await tester.pump();

    expect(picked, isEmpty);
    expect(rejected, ['Use a JPG, PNG or WebP picture.']);
  });

  testWidgets('cancelling the picker does nothing', (tester) async {
    final picked = <UploadedFile>[];
    final rejected = <String>[];
    await tester.pumpWidget(host(pick: () async => null, picked: picked, rejected: rejected));

    await tester.tap(find.text('Choose Front'));
    await tester.pump();

    expect(picked, isEmpty);
    expect(rejected, isEmpty);
  });
}
