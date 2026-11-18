import 'package:hive/hive.dart';

part 'banner_action.g.dart';

@HiveType(typeId: 10)
enum BannerAction {
  @HiveField(0)
  content('content', 'Open Content Item'),

  @HiveField(1)
  category('category', 'Open Category'),

  @HiveField(2)
  external('external', 'Open External Link'),

  @HiveField(3)
  live('live', 'Watch Live Stream');

  final String value;
  final String label;
  const BannerAction(this.value, this.label);

  static BannerAction fromString(String? val) {
    if (val == null) return BannerAction.content;
    for (final action in BannerAction.values) {
      if (action.value.toLowerCase() == val.toLowerCase()) return action;
    }
    return BannerAction.content;
  }
}
