import 'dart:convert';

import 'package:clean_architecture/core/error/exceptions.dart';
import 'package:clean_architecture/features/number_trivia/data/datasources/number_trivia_remote_data_source.dart';
import 'package:clean_architecture/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';

import '../../../../fixtures/fixture_reader.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  late NumberTriviaRemoteDataSourceImp dataSource;
  late MockHttpClient mockHttpClient;
  setUp(() {
    mockHttpClient = MockHttpClient();
    dataSource = NumberTriviaRemoteDataSourceImp(client: mockHttpClient);
  });
  void setUpMockHttpClientSuccess200(Uri uri) {
    when(() => mockHttpClient.get(uri, headers: any(named: 'headers')))
        .thenAnswer((_) async => http.Response(fixture('trivia.json'), 200));
  }

  void setUpMockHttpClientFailure404(Uri uri) {
    when(() => mockHttpClient.get(uri, headers: any(named: 'headers')))
        .thenAnswer((_) async => http.Response('Something went wrong', 404));
  }

  group('getConcreteNumberTrivia', () {
    final tNumber = 1;
    final uri = Uri.parse('http://numbersapi.com/$tNumber');
    final tNumberTriviaModel =
        NumberTriviaModel.fromJson(json.decode(fixture('trivia.json')));
    test("""should perform a get request on a URL 
        with number being the endpoint 
        and with application/json header""", () async {
      setUpMockHttpClientSuccess200(uri);
      await dataSource.getConcreteNumberTrivia(tNumber);

      verify(
        () => mockHttpClient.get(uri, headers: {
          'CONTENT-TYPE': 'application/json',
        }),
      );
    });
    test('should return NumberTrivia when response code is 200 (success)',
        () async {
      setUpMockHttpClientSuccess200(uri);

      final result = await dataSource.getConcreteNumberTrivia(tNumber);
      expect(result, equals(tNumberTriviaModel));
    });
    test('should throw a ServerException when response code is 404 or other ',
        () async {
      setUpMockHttpClientFailure404(uri);
      final call = await dataSource.getConcreteNumberTrivia;
      expect(() => call(tNumber), throwsA(TypeMatcher<ServerException>()));
    });
  });
  group('getRandomNumberTrivia', () {
    final uri = Uri.parse('http://numbersapi.com/random');
    final tNumberTriviaModel =
        NumberTriviaModel.fromJson(json.decode(fixture('trivia.json')));
    test("""should perform a get request on a URL 
        with number being the endpoint 
        and with application/json header""", () async {
      setUpMockHttpClientSuccess200(uri);
      await dataSource.getRandomNumberTrivia();

      verify(
        () => mockHttpClient.get(uri, headers: {
          'CONTENT-TYPE': 'application/json',
        }),
      );
    });
    test('should return NumberTrivia when response code is 200 (success)',
        () async {
      setUpMockHttpClientSuccess200(uri);

      final result = await dataSource.getRandomNumberTrivia();
      expect(result, equals(tNumberTriviaModel));
    });
    test('should throw a ServerException when response code is 404 or other ',
        () async {
      setUpMockHttpClientFailure404(uri);
      final call = await dataSource.getRandomNumberTrivia;
      expect(() => call(), throwsA(TypeMatcher<ServerException>()));
    });
  });
}
