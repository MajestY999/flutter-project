// Определяет модель карточки обещаний, её статистику и демонстрационные данные.
import 'package:flutter/material.dart';

import 'trust_level.dart';

const _avatarColors = <Color>[
  Color(0xFFAA8FFF),
  Color(0xFFFF9B85),
  Color(0xFF83D9C4),
  Color(0xFF91B9FF),
  Color(0xFFFFC978),
];

Color avatarColorFor(int index) => _avatarColors[index % _avatarColors.length];

class TrackedPerson {
  const TrackedPerson({
    required this.id,
    required this.name,
    required this.promise,
    required this.broken,
    required this.kept,
    required this.color,
    required this.isSelf,
    required this.history,
  });

  final String id;
  final String name;
  final String promise;
  final int broken;
  final int kept;
  final int color;
  final bool isSelf;
  final List<int> history;

  int get total => broken + kept;
  int get trust => total == 0 ? 0 : (kept * 100 / total).round();
  Color get avatarColor => Color(color);

  String get status => levelForStats(trust: trust, kept: kept).name;

  TrackedPerson copyWith({
    String? name,
    String? promise,
    int? broken,
    int? kept,
    int? color,
    bool? isSelf,
    List<int>? history,
  }) {
    return TrackedPerson(
      id: id,
      name: name ?? this.name,
      promise: promise ?? this.promise,
      broken: broken ?? this.broken,
      kept: kept ?? this.kept,
      color: color ?? this.color,
      isSelf: isSelf ?? this.isSelf,
      history: history ?? this.history,
    );
  }

  Map<String, Object?> toJson() => {
    'id': id,
    'name': name,
    'promise': promise,
    'broken': broken,
    'kept': kept,
    'color': color,
    'isSelf': isSelf,
    'history': history,
  };

  factory TrackedPerson.fromJson(Map<String, dynamic> json) {
    return TrackedPerson(
      id: json['id'] as String? ?? json['name'] as String,
      name: json['name'] as String,
      promise: json['promise'] as String,
      broken: json['broken'] as int,
      kept: json['kept'] as int,
      color: json['color'] as int,
      isSelf: json['isSelf'] as bool? ?? false,
      history: (json['history'] as List<dynamic>).cast<int>(),
    );
  }
}

List<TrackedPerson> samplePeople() => [
  TrackedPerson(
    id: 'mark',
    name: 'Марк',
    promise: '«На следующей неделе точно»',
    broken: 8,
    kept: 2,
    color: avatarColorFor(0).toARGB32(),
    isSelf: false,
    history: [1, 2, 2, 1, 3, 2, 4],
  ),
  TrackedPerson(
    id: 'sonya',
    name: 'Соня',
    promise: '«Бросаю с понедельника»',
    broken: 1,
    kept: 9,
    color: avatarColorFor(2).toARGB32(),
    isSelf: false,
    history: [2, 1, 1, 2, 1, 1, 0],
  ),
  TrackedPerson(
    id: 'ilya',
    name: 'Илья',
    promise: '«Верну до пятницы»',
    broken: 4,
    kept: 5,
    color: avatarColorFor(1).toARGB32(),
    isSelf: false,
    history: [0, 1, 2, 1, 2, 3, 2],
  ),
];
