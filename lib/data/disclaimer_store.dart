import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ホームの非公式アプリ表示を、初回表示後は折りたたむための端末内保存。
class DisclaimerStore {
  DisclaimerStore(this.appId);

  final String appId;

  String get _key => '${appId}_disclaimer_seen';

  Future<bool> read() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? false;
  }

  Future<void> markSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
  }
}

final disclaimerStoreProvider = Provider<DisclaimerStore>(
  (ref) => DisclaimerStore('app'),
);

/// 非公式アプリの表示文を見たかどうか。`load()` で保存値を読み込む。
class DisclaimerSeenNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  Future<void> load() async {
    state = await ref.read(disclaimerStoreProvider).read();
  }

  Future<void> markSeen() async {
    if (state) return;
    state = true;
    await ref.read(disclaimerStoreProvider).markSeen();
  }
}

final disclaimerSeenProvider = NotifierProvider<DisclaimerSeenNotifier, bool>(
  DisclaimerSeenNotifier.new,
);
