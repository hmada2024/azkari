// test/test_helpers.dart
import 'package:azkari/core/error/failures.dart';
import 'package:azkari/core/services/messenger_service.dart';
import 'package:azkari/core/services/notification_service.dart';
import 'package:azkari/data/models/managed_goal_model.dart';
import 'package:azkari/data/models/tasbih_model.dart';
import 'package:azkari/data/repositories/azkar_repository.dart';
import 'package:azkari/data/repositories/goals_repository.dart';
import 'package:azkari/data/repositories/tasbih_repository.dart';
import 'package:azkari/features/goal_management/use_cases/add_tasbih_use_case.dart';
import 'package:azkari/features/prayer_times/data/repositories/prayer_settings_repository.dart';
import 'package:azkari/features/prayer_times/data/services/location_service.dart';
import 'package:azkari/features/settings/use_cases/update_evening_notification_use_case.dart';
import 'package:azkari/features/settings/use_cases/update_font_scale_use_case.dart';
import 'package:azkari/features/settings/use_cases/update_morning_notification_use_case.dart';
import 'package:azkari/features/settings/use_cases/update_theme_use_case.dart';
import 'package:azkari/features/tasbih/use_cases/increment_daily_count_use_case.dart';
import 'package:azkari/features/tasbih/use_cases/reset_daily_progress_use_case.dart';
import 'package:azkari/features/tasbih/use_cases/set_active_tasbih_use_case.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

@GenerateNiceMocks([
  MockSpec<TasbihRepository>(),
  MockSpec<GoalsRepository>(),
  MockSpec<AzkarRepository>(),
  MockSpec<PrayerSettingsRepository>(),
  MockSpec<LocationService>(),
  MockSpec<NotificationService>(),
  MockSpec<SharedPreferences>(),
  MockSpec<MessengerService>(),
  MockSpec<AddTasbihUseCase>(),
  MockSpec<UpdateThemeUseCase>(),
  MockSpec<UpdateFontScaleUseCase>(),
  MockSpec<UpdateMorningNotificationUseCase>(),
  MockSpec<UpdateEveningNotificationUseCase>(),
  MockSpec<IncrementDailyCountUseCase>(),
  MockSpec<ResetDailyProgressUseCase>(),
  MockSpec<SetActiveTasbihUseCase>(),
])
export 'test_helpers.mocks.dart';

class Listener<T> extends Mock {
  void call(T? previous, T value);
}

final tTasbihModel = TasbihModel(
  id: 1,
  text: 'سبحان الله',
  sortOrder: 1,
  isMandatory: true,
);
final tManagedGoal = ManagedGoal(
  tasbih: tTasbihModel,
  isActive: true,
  targetCount: 100,
);
const tDatabaseFailure = DatabaseFailure('Test DB Failure');

ProviderContainer createContainer({
  List<Override> overrides = const [],
}) {
  final container = ProviderContainer(overrides: overrides);
  addTearDown(container.dispose);
  return container;
}

void arrangeRepositoryCall<T>({
  required Mock mock,
  required Future<Either<Failure, T>> Function() call,
  required Either<Failure, T> returns,
}) {
  when(call()).thenAnswer((_) async => returns);
}
