import 'package:freezed_annotation/freezed_annotation.dart';

part 'history_item.freezed.dart';
part 'history_item.g.dart';

@freezed
class HistoryItem with _$HistoryItem {
  const factory HistoryItem({
    required String title,
    required String subtitle,
    required String imageUrl,
  }) = _HistoryItem;

  factory HistoryItem.fromJson(Map<String, dynamic> json) =>
      _$HistoryItemFromJson(json);
}
