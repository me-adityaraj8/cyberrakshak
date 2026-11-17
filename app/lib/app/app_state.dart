import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../detection/detector.dart';
import '../detection/scam_model.dart';
import 'tr.dart';

class HistoryEntry {
  const HistoryEntry(this.text, this.level, this.at);
  final String text;
  final RiskLevel level;
  final DateTime at;

  Map<String, Object> toJson() => {
    't': text,
    'l': level.index,
    'a': at.millisecondsSinceEpoch,
  };
  static HistoryEntry fromJson(Map<String, dynamic> j) => HistoryEntry(
    j['t'] as String,
    RiskLevel.values[j['l'] as int],
    DateTime.fromMillisecondsSinceEpoch(j['a'] as int),
  );
}

/// App-wide state: language, profile, detection engine, local history.
/// Everything is stored on the device only.
class AppState extends ChangeNotifier {
  late SharedPreferences _prefs;
  late Detector detector;
  late NumberCheck numberCheck;

  Lang lang = Lang.hi;
  bool onboarded = false;
  String name = '';
  String familyNumber = '';
  int checkedCount = 0;
  int caughtCount = 0;
  List<HistoryEntry> history = [];
  Set<String> completedLessons = {};
  Set<String> reportedNumbers = {};
  Set<String> passedCalls = {};

  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();
    final model = ScamModel.fromJson(
      await rootBundle.loadString('assets/model/scam_model.json'),
    );
    detector = Detector(model);
    final seed = (jsonDecode(
      await rootBundle.loadString('assets/model/reported_numbers.json'),
    ) as List).cast<String>();

    lang = Lang.values[_prefs.getInt('lang') ?? Lang.hi.index];
    onboarded = _prefs.getBool('onboarded') ?? false;
    name = _prefs.getString('name') ?? '';
    familyNumber = _prefs.getString('family') ?? '';
    checkedCount = _prefs.getInt('checked') ?? 0;
    caughtCount = _prefs.getInt('caught') ?? 0;
    completedLessons = (_prefs.getStringList('lessons') ?? []).toSet();
    reportedNumbers = (_prefs.getStringList('reported') ?? []).toSet();
    passedCalls = (_prefs.getStringList('calls') ?? []).toSet();
    history = (_prefs.getStringList('history') ?? [])
        .map(
          (s) => HistoryEntry.fromJson(jsonDecode(s) as Map<String, dynamic>),
        )
        .toList();
    numberCheck = NumberCheck({...seed, ...reportedNumbers});
  }

  String t(Tr tr) => tr.of(lang);

  void setLang(Lang l) {
    lang = l;
    _prefs.setInt('lang', l.index);
    notifyListeners();
  }

  void completeOnboarding(String newName) {
    name = newName.trim();
    onboarded = true;
    _prefs.setString('name', name);
    _prefs.setBool('onboarded', true);
    notifyListeners();
  }

  void setName(String v) {
    name = v.trim();
    _prefs.setString('name', name);
    notifyListeners();
  }

  void setFamily(String v) {
    familyNumber = v.trim();
    _prefs.setString('family', familyNumber);
    notifyListeners();
  }

  void recordCheck(String text, RiskLevel level) {
    checkedCount++;
    if (level == RiskLevel.scam) caughtCount++;
    history = [
      HistoryEntry(text, level, DateTime.now()),
      ...history,
    ].take(12).toList();
    _prefs.setInt('checked', checkedCount);
    _prefs.setInt('caught', caughtCount);
    _prefs.setStringList(
      'history',
      history.map((h) => jsonEncode(h.toJson())).toList(),
    );
    notifyListeners();
  }

  void completeLesson(String id) {
    completedLessons = {...completedLessons, id};
    _prefs.setStringList('lessons', completedLessons.toList());
    notifyListeners();
  }

  /// A practice call the user got through without being cheated.
  void passCall(String id) {
    if (passedCalls.contains(id)) return;
    passedCalls = {...passedCalls, id};
    _prefs.setStringList('calls', passedCalls.toList());
    notifyListeners();
  }

  /// Stores a reported number locally (and later syncs it to Firebase).
  void reportNumber(String normalised) {
    reportedNumbers = {...reportedNumbers, normalised};
    _prefs.setStringList('reported', reportedNumbers.toList());
    numberCheck = NumberCheck({...numberCheck.reported, normalised});
    notifyListeners();
  }
}
