import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/youtube_channel_model.dart';
import '../../data/repositories/youtube_repository.dart';
import 'auth_provider.dart';

final youtubeRepositoryProvider = Provider<YoutubeRepository>((ref) {
  final ds = ref.watch(apiDataSourceProvider);
  return YoutubeRepository(ds);
});

final youtubeChannelsProvider =
    FutureProvider<List<YoutubeChannelModel>>((ref) async {
  final repo = ref.watch(youtubeRepositoryProvider);
  return repo.getYoutubeChannels();
});
