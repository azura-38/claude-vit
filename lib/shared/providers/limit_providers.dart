import 'package:sembast/sembast.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'premium_provider.dart';
import '../../core/di/service_providers.dart';
import '../data/services/limit_service.dart';
import '../data/services/analytics_service.dart';

class LimitData {
  final int extraDocs;
  final int extraMedicine;
  final int extraAppointment;

  LimitData({this.extraDocs = 0, this.extraMedicine = 0, this.extraAppointment = 0});

  LimitData copyWith({int? extraDocs, int? extraMedicine, int? extraAppointment}) {
    return LimitData(
      extraDocs: extraDocs ?? this.extraDocs,
      extraMedicine: extraMedicine ?? this.extraMedicine,
      extraAppointment: extraAppointment ?? this.extraAppointment,
    );
  }

  Map<String, dynamic> toJson() => {
        'extraDocs': extraDocs,
        'extraMedicine': extraMedicine,
        'extraAppointment': extraAppointment,
      };

  factory LimitData.fromJson(Map<String, dynamic> json) {
    return LimitData(
      extraDocs: json['extraDocs'] as int? ?? 0,
      extraMedicine: json['extraMedicine'] as int? ?? 0,
      extraAppointment: json['extraAppointment'] as int? ?? 0,
    );
  }
}

final limitProvider = NotifierProvider<LimitNotifier, LimitData>(LimitNotifier.new);

class LimitNotifier extends Notifier<LimitData> {
  final _store = StoreRef<String, dynamic>.main();
  static const String _limitKey = 'app_limits_data';

  @override
  LimitData build() {
    _load();
    return LimitData();
  }

  Future<Database> get _db async => ref.read(sembastDatabaseProvider).ready;

  Future<void> _load() async {
    final db = await _db;
    final json = await _store.record(_limitKey).get(db) as Map<String, dynamic>?;
    if (json != null) state = LimitData.fromJson(json);
  }

  Future<void> increaseExtraDocs(int amount) async {
    state = state.copyWith(extraDocs: state.extraDocs + amount);
    await _save();
  }

  Future<void> increaseExtraMedicine(int amount) async {
    state = state.copyWith(extraMedicine: state.extraMedicine + amount);
    await _save();
  }

  Future<void> increaseExtraAppointment(int amount) async {
    state = state.copyWith(extraAppointment: state.extraAppointment + amount);
    await _save();
  }

  Future<void> onRewardedAdCompleted() async {}

  void _trackLimitBreaker(String type) {
    AnalyticsService.log(AnalyticsService.limitReached, {'type': type});
  }

  Future<void> _save() async {
    final db = await _db;
    await _store.record(_limitKey).put(db, state.toJson());
  }

  bool canAddDocument(int currentCount) {
    final can = LimitService.canAdd(
      current: currentCount,
      baseLimit: LimitService.documentLimit,
      extra: state.extraDocs,
      isPremium: ref.read(premiumProvider),
    );
    if (!can) _trackLimitBreaker('document');
    return can;
  }

  bool canAddMedicine(int currentCount) {
    final can = LimitService.canAdd(
      current: currentCount,
      baseLimit: LimitService.medicineLimit,
      extra: state.extraMedicine,
      isPremium: ref.read(premiumProvider),
    );
    if (!can) _trackLimitBreaker('medicine');
    return can;
  }

  bool canAddAppointment(int currentCount) {
    final can = LimitService.canAdd(
      current: currentCount,
      baseLimit: LimitService.appointmentLimit,
      extra: state.extraAppointment,
      isPremium: ref.read(premiumProvider),
    );
    if (!can) _trackLimitBreaker('appointment');
    return can;
  }
}
