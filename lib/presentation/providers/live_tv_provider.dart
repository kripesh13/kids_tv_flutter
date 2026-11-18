import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/live_channel_model.dart';
import '../../data/repositories/live_tv_repository.dart';
import 'auth_provider.dart';

final liveTvRepositoryProvider = Provider<LiveTvRepository>((ref) {
  final ds = ref.watch(apiDataSourceProvider);
  return LiveTvRepository(ds);
});

class LiveTvState {
  final List<LiveChannelModel> channels;
  final LiveChannelModel? selectedChannel;
  final bool isLoading;
  final String? error;

  const LiveTvState({
    this.channels = const [],
    this.selectedChannel,
    this.isLoading = false,
    this.error,
  });

  List<LiveChannelModel> get activeChannels =>
      channels.where((c) => c.isActive).toList()
        ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

  LiveTvState copyWith({
    List<LiveChannelModel>? channels,
    LiveChannelModel? selectedChannel,
    bool? isLoading,
    String? error,
  }) {
    return LiveTvState(
      channels: channels ?? this.channels,
      selectedChannel: selectedChannel ?? this.selectedChannel,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class LiveTvNotifier extends StateNotifier<LiveTvState> {
  final LiveTvRepository _repo;

  LiveTvNotifier(this._repo) : super(const LiveTvState()) {
    loadChannels();
  }

  Future<void> loadChannels({bool adminMode = false}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final list = await _repo.getLiveChannels(onlyActive: !adminMode);
      final currentSelected = state.selectedChannel != null &&
              list.any((c) => c.id == state.selectedChannel!.id)
          ? state.selectedChannel
          : (list.isNotEmpty ? list.first : null);

      state = state.copyWith(
        channels: list,
        selectedChannel: currentSelected,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void selectChannel(LiveChannelModel channel) {
    state = state.copyWith(selectedChannel: channel);
  }

  void selectNextChannel() {
    final active = state.activeChannels;
    if (active.isEmpty) return;
    final currentIndex = active.indexWhere((c) => c.id == state.selectedChannel?.id);
    final nextIndex = (currentIndex + 1) % active.length;
    state = state.copyWith(selectedChannel: active[nextIndex]);
  }

  void selectPreviousChannel() {
    final active = state.activeChannels;
    if (active.isEmpty) return;
    final currentIndex = active.indexWhere((c) => c.id == state.selectedChannel?.id);
    final prevIndex = (currentIndex - 1 + active.length) % active.length;
    state = state.copyWith(selectedChannel: active[prevIndex]);
  }

  Future<void> saveChannel(LiveChannelModel channel) async {
    try {
      await _repo.saveLiveChannel(channel);
      loadChannels();
    } catch (_) {}
  }

  Future<void> deleteChannel(String id) async {
    try {
      await _repo.deleteLiveChannel(id);
      loadChannels();
    } catch (_) {}
  }
}

final liveTvProvider =
    StateNotifierProvider<LiveTvNotifier, LiveTvState>((ref) {
  final repo = ref.watch(liveTvRepositoryProvider);
  return LiveTvNotifier(repo);
});
