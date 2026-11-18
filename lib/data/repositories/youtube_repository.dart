import '../datasources/remote/api_data_source.dart';
import '../models/youtube_channel_model.dart';

class YoutubeRepository {
  final ApiDataSource _dataSource;
  YoutubeRepository(this._dataSource);

  Future<List<YoutubeChannelModel>> getYoutubeChannels() =>
      _dataSource.getYoutubeChannels();
}
