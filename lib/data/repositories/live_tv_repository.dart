import '../datasources/remote/api_data_source.dart';
import '../models/live_channel_model.dart';

class LiveTvRepository {
  final ApiDataSource _dataSource;
  LiveTvRepository(this._dataSource);

  Future<List<LiveChannelModel>> getLiveChannels({bool onlyActive = true}) =>
      _dataSource.getLiveChannels(onlyActive: onlyActive);

  Future<LiveChannelModel> saveLiveChannel(LiveChannelModel channel) =>
      _dataSource.saveLiveChannel(channel);

  Future<void> deleteLiveChannel(String id) => _dataSource.deleteLiveChannel(id);
}
