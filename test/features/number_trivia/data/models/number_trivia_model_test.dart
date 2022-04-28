import 'dart:convert';

import 'package:clean_architecture/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:clean_architecture/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../fixtures/fixture_reader.dart';

void main() {
  final tNumberTriviaModel = NumberTriviaModel(number: 1, text: 'Test Text');
  test('should be subclass of Number Trivia Entity', () async {
    expect(tNumberTriviaModel, isA<NumberTrivia>());
  });
  group('fromJson', () {
    test('should return a valid model when the json number is an integer', () {
      final Map<String, dynamic> jsonMap = json.decode(fixture('trivia.json'));
      final result = NumberTriviaModel.fromJson(jsonMap);
      expect(result, equals(tNumberTriviaModel));
    });

    test(
        'should return a valid model when the json number is regarded as a double',
        () {
      final Map<String, dynamic> jsonMap =
          json.decode(fixture('trivia_double.json'));
      final result = NumberTriviaModel.fromJson(jsonMap);
      expect(result, equals(tNumberTriviaModel));
    });
  });
  group('toJson', () {
    test('should return a json map containing the proper data', () {
      final result = tNumberTriviaModel.toJson();
      final expectedMap = {
        'text': 'Test Text',
        'number': 1,
      };
      expect(result, expectedMap);
    });
  });
}
