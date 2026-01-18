import 'package:media_kit/media_kit.dart';
import 'package:musily/core/data/datasources/youtube_datasource.dart';
import 'package:musily/features/player/domain/entities/queue.dart';
import 'package:musily/features/track/domain/entities/track_entity.dart';

class YouTubeRadioQueue implements MusilyQueue {
  final TrackEntity initialTrack;
  final YoutubeDatasource _youtubeDatasource;

  YouTubeRadioQueue(
    this.initialTrack,
    this._youtubeDatasource,
  );

  @override
  TrackEntity? get preloadItem => initialTrack;

  @override
  Future<QueueStatus> getInitialStatus() async {
    try {
      final upNextTracks = await _youtubeDatasource.getUpNext(initialTrack);

      // Converte as tracks para Media
      final mediaItems = upNextTracks.map((track) {
        return Media(track.id, extras: {
          'title': track.title,
          'artist': track.artist.name,
          'album': track.album.title,
          'duration': track.duration.inSeconds.toString(),
          'lowResImg': track.lowResImg,
          'highResImg': track.highResImg,
        });
      }).toList();

      return QueueStatus(
        title: 'Rádio: ${initialTrack.title}',
        items: mediaItems,
        mediaItemIndex: 0,
      );
    } catch (e) {
      // Fallback: retorna apenas a música inicial
      return QueueStatus(
        title: 'Rádio: ${initialTrack.title}',
        items: [
          Media(initialTrack.id, extras: {
            'title': initialTrack.title,
            'artist': initialTrack.artist.name,
            'album': initialTrack.album.title,
            'duration': initialTrack.duration.inSeconds.toString(),
            'lowResImg': initialTrack.lowResImg,
            'highResImg': initialTrack.highResImg,
          })
        ],
        mediaItemIndex: 0,
      );
    }
  }

  @override
  bool hasNextPage() => false; // Por enquanto, sem paginação infinita

  @override
  Future<List<Media>> nextPage() async => []; // Não implementado ainda
}
