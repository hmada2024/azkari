// test/features/goal_management/use_cases/add_tasbih_use_case_test.dart
import 'package:azkari/core/error/failures.dart';
import 'package:azkari/features/goal_management/use_cases/add_tasbih_use_case.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../../test_helpers.dart';

void main() {
  late AddTasbihUseCase useCase;
  late MockTasbihRepository mockTasbihRepository;

  setUp(() {
    mockTasbihRepository = MockTasbihRepository();
    useCase = AddTasbihUseCase(mockTasbihRepository);
  });

  group('AddTasbihUseCase', () {
    const tText = 'استغفر الله';

    test(
      'should call tasbihRepository.addTasbih when text is valid',
      () async {
        when(mockTasbihRepository.addTasbih(any))
            .thenAnswer((_) async => tTasbihModel);

        final result = await useCase.execute(tText);

        expect(result, const Right(null));
        verify(mockTasbihRepository.addTasbih(tText));
        verifyNoMoreInteractions(mockTasbihRepository);
      },
    );

    test(
      'should return DatabaseFailure when text is empty',
      () async {
        final result = await useCase.execute('');

        expect(result, const Left(DatabaseFailure("لا يمكن إضافة ذكر فارغ.")));
        verifyZeroInteractions(mockTasbihRepository);
      },
    );

    test(
      'should return DatabaseFailure when text is only whitespace',
      () async {
        final result = await useCase.execute('   ');

        expect(result, const Left(DatabaseFailure("لا يمكن إضافة ذكر فارغ.")));
        verifyZeroInteractions(mockTasbihRepository);
      },
    );

    test(
      'should return DatabaseFailure when repository throws an exception',
      () async {
        when(mockTasbihRepository.addTasbih(any)).thenThrow(Exception());

        final result = await useCase.execute(tText);

        expect(
            result,
            const Left(
                DatabaseFailure("فشلت عملية إضافة الذكر إلى قاعدة البيانات.")));
        verify(mockTasbihRepository.addTasbih(tText));
      },
    );
  });
}