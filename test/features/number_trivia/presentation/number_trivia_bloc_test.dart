import 'package:clean_architecture/core/error/failures.dart';
import 'package:clean_architecture/core/presentation/util/input_converter.dart';
import 'package:clean_architecture/core/usecases/usecase.dart';
import 'package:clean_architecture/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:clean_architecture/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:clean_architecture/features/number_trivia/domain/usecases/get_random_number_trivia.dart';
import 'package:clean_architecture/features/number_trivia/presentation/bloc/number_trivia_bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetConcreteNumberTrivia extends Mock
    implements GetConcreteNumberTrivia {}

class MockGetRandomNumberTrivia extends Mock implements GetRandomNumberTrivia {}

class MockInputConverter extends Mock implements InputConverter {}

void main() {
  late MockGetConcreteNumberTrivia mockGetConcreteNumberTrivia;
  late MockGetRandomNumberTrivia mockGetRandomNumberTrivia;
  late MockInputConverter mockInputConverter;

  late NumberTriviaBloc bloc;
  setUp(() {
    mockGetConcreteNumberTrivia = MockGetConcreteNumberTrivia();
    mockGetRandomNumberTrivia = MockGetRandomNumberTrivia();
    mockInputConverter = MockInputConverter();

    bloc = NumberTriviaBloc(
        inputConverter: mockInputConverter,
        getRandomNumberTrivia: mockGetRandomNumberTrivia,
        getConcreteNumberTrivia: mockGetConcreteNumberTrivia);
  });
  test('initial state should be empty', () {
    expect(bloc.state, equals(Empty()));
  });
  group('GetTriviaForConcreteNumber', () {
    final tNumberString = '1';
    final tNumberParsed = 1;
    final tNumberTrivia = NumberTrivia(text: 'test trivia', number: 1);
    void setUpMockInputConverterSuccess() =>
        when(() => mockInputConverter.stringToUnsignedInt(any()))
            .thenReturn(Right(tNumberParsed));
    test(
        'should call the InputConverter to validate and convert the string to unsigned integer',
        () async {
      setUpMockInputConverterSuccess();
      Params params = Params(number: tNumberParsed);
      when(() => mockGetConcreteNumberTrivia(params))
          .thenAnswer((_) async => Right(tNumberTrivia));
      bloc.add(GetTriviaForConcreteNumber(tNumberString));
      await untilCalled(() => mockInputConverter.stringToUnsignedInt(any()));
      verify(() => mockInputConverter.stringToUnsignedInt(tNumberString));
    });
    test('should emit [error] when the input is invalid', () {
      when(() => mockInputConverter.stringToUnsignedInt(any()))
          .thenReturn(Left(InvalidInputFailure()));
      final expected = [
        Error(message: INVALID_INPUT_FAILURE_MESSAGE),
      ];
      expectLater(bloc.stream.asBroadcastStream(), emitsInOrder(expected));
      bloc.add(GetTriviaForConcreteNumber(tNumberString));
    });
    test('should get data from concrete use case', () async {
      setUpMockInputConverterSuccess();

      Params params = Params(number: tNumberParsed);
      when(() => mockGetConcreteNumberTrivia(params))
          .thenAnswer((_) async => Right(tNumberTrivia));
      bloc.add(GetTriviaForConcreteNumber(tNumberString));
      await untilCalled(() => mockGetConcreteNumberTrivia(params));
      verify(() => mockGetConcreteNumberTrivia(params));
    });
    test('should emit [Loading,Loaded] when data is gotten successfully',
        () async {
      setUpMockInputConverterSuccess();
      Params params = Params(number: tNumberParsed);
      when(() => mockGetConcreteNumberTrivia(params))
          .thenAnswer((_) async => Right(tNumberTrivia));

      final expected = [
        Loading(),
        Loaded(trivia: tNumberTrivia),
      ];
      expectLater(bloc.stream.asBroadcastStream(), emitsInOrder(expected));
      bloc.add(GetTriviaForConcreteNumber(tNumberString));
    });
    test('should emit [Loading,Error] when getting data fails ', () async {
      setUpMockInputConverterSuccess();
      Params params = Params(number: tNumberParsed);
      when(() => mockGetConcreteNumberTrivia(params))
          .thenAnswer((_) async => Left(ServerFailure()));

      final expected = [
        Loading(),
        Error(message: SERVER_FAILURE_MESSAGE),
      ];
      expectLater(bloc.stream.asBroadcastStream(), emitsInOrder(expected));
      bloc.add(GetTriviaForConcreteNumber(tNumberString));
    });
    test(
        'should emit [Loading,Error] with a proper message for the error when getting data fails ',
        () async {
      setUpMockInputConverterSuccess();
      Params params = Params(number: tNumberParsed);
      when(() => mockGetConcreteNumberTrivia(params))
          .thenAnswer((_) async => Left(CacheFailure()));

      final expected = [
        Loading(),
        Error(message: CACHE_FAILURE_MESSAGE),
      ];
      expectLater(bloc.stream.asBroadcastStream(), emitsInOrder(expected));
      bloc.add(GetTriviaForConcreteNumber(tNumberString));
    });
  });
  group('GetTriviaForRandomNumber', () {
    final tNumberTrivia = NumberTrivia(text: 'test trivia', number: 1);

    test('should get data from random use case', () async {
      when(() => mockGetRandomNumberTrivia(NoParams()))
          .thenAnswer((_) async => Right(tNumberTrivia));
      bloc.add(GetTriviaForRandomNumber());
      await untilCalled(() => mockGetRandomNumberTrivia(NoParams()));
      verify(() => mockGetRandomNumberTrivia(NoParams()));
    });
    test('should emit [Loading,Loaded] when data is gotten successfully',
        () async {
      when(() => mockGetRandomNumberTrivia(NoParams()))
          .thenAnswer((_) async => Right(tNumberTrivia));

      final expected = [
        Loading(),
        Loaded(trivia: tNumberTrivia),
      ];
      expectLater(bloc.stream.asBroadcastStream(), emitsInOrder(expected));
      bloc.add(GetTriviaForRandomNumber());
    });
    test('should emit [Loading,Error] when getting data fails ', () async {
      when(() => mockGetRandomNumberTrivia(NoParams()))
          .thenAnswer((_) async => Left(ServerFailure()));

      final expected = [
        Loading(),
        Error(message: SERVER_FAILURE_MESSAGE),
      ];
      expectLater(bloc.stream.asBroadcastStream(), emitsInOrder(expected));
      bloc.add(GetTriviaForRandomNumber());
    });
    test(
        'should emit [Loading,Error] with a proper message for the error when getting data fails ',
        () async {
      when(() => mockGetRandomNumberTrivia(NoParams()))
          .thenAnswer((_) async => Left(CacheFailure()));

      final expected = [
        Loading(),
        Error(message: CACHE_FAILURE_MESSAGE),
      ];
      expectLater(bloc.stream.asBroadcastStream(), emitsInOrder(expected));
      bloc.add(GetTriviaForRandomNumber());
    });
  });
}
