import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'content_type.g.dart';

@HiveType(typeId: 9)
enum ContentType {
  @HiveField(0)
  video('video', 'Video File (MP4/WebM)', Icons.movie_outlined),

  @HiveField(1)
  externalUrl('external_url', 'External Video URL', Icons.link),

  @HiveField(2)
  youtubeVideo('youtube_video', 'YouTube Video', Icons.smart_display_outlined),

  @HiveField(3)
  youtubeChannel('youtube_channel', 'YouTube Channel', Icons.subscriptions_outlined),

  @HiveField(4)
  liveStream('live_stream', 'Live Stream (HLS)', Icons.live_tv),

  @HiveField(5)
  websiteLink('website_link', 'Website Link', Icons.public),

  @HiveField(6)
  playlist('playlist', 'Playlist', Icons.playlist_play),

  @HiveField(7)
  custom('custom', 'Custom Content', Icons.extension_outlined);

  final String value;
  final String label;
  final IconData icon;
  const ContentType(this.value, this.label, this.icon);

  static ContentType fromString(String? val) {
    if (val == null) return ContentType.video;
    for (final type in ContentType.values) {
      if (type.value.toLowerCase() == val.toLowerCase()) return type;
    }
    return ContentType.video;
  }
}
