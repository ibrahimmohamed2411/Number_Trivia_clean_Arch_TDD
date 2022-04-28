import 'package:clean_architecture/core/network/network_info.dart';
import 'package:data_connection_checker_tv/data_connection_checker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDataConnectionChecker extends Mock implements DataConnectionChecker {}

void main() {
  late MockDataConnectionChecker mockDataConnectionChecker;
  late NetworkInfoImp networkInfoImp;
  setUp(() {
    mockDataConnectionChecker = MockDataConnectionChecker();
    networkInfoImp = NetworkInfoImp(mockDataConnectionChecker);
  });
  group('isConnected', () {
    test('should forward the call to DataConnectionChecker ', () async {
      when(() => mockDataConnectionChecker.hasConnection)
          .thenAnswer((_) async => true);
      final result = await networkInfoImp.isConnected;
      verify(() => mockDataConnectionChecker.hasConnection);
      expect(result, true);
    });
  });
}
