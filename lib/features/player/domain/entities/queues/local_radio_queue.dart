import 'dart:math';
import 'package:media_kit/media_kit.dart';
import 'package:musily/core/domain/repositories/musily_repository.dart';
import 'package:musily/features/player/domain/entities/queue.dart';
import 'package:musily/features/track/domain/entities/track_entity.dart';

class LocalRadioQueue implements MusilyQueue {
  final TrackEntity initialTrack;
  final MusilyRepository _musilyRepository;

  LocalRadioQueue(
    this.initialTrack,
    this._musilyRepository,
  );

  @override
  TrackEntity? get preloadItem => initialTrack;

  @override
  Future<QueueStatus> getInitialStatus() async {
    try {
      // Busca por músicas do mesmo artista
      final artistTracks = await _musilyRepository.searchTracks(initialTrack.artist.name);

      // Filtra apenas músicas locais (não do YouTube)
      final localTracks = artistTracks.where((track) =>
        track.source != 'youtube' &&
        track.id != initialTrack.id
      ).toList();

      // Se não encontrou músicas suficientes do artista, busca por gênero
      if (localTracks.length < 5) {
        final genreQuery = _extractGenreFromTrack(initialTrack);
        if (genreQuery.isNotEmpty) {
          final genreTracks = await _musilyRepository.searchTracks(genreQuery);
          final additionalTracks = genreTracks.where((track) =>
            track.source != 'youtube' &&
            track.id != initialTrack.id &&
            !localTracks.any((existing) => existing.id == track.id)
          ).take(10 - localTracks.length).toList();

          localTracks.addAll(additionalTracks);
        }
      }

      // Embaralha as músicas encontradas
      localTracks.shuffle(Random());

      // Limita a 15 músicas
      final radioTracks = localTracks.take(15).toList();

      // Converte para Media
      final mediaItems = radioTracks.map((track) {
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
        title: 'Rádio Local: ${initialTrack.artist.name}',
        items: mediaItems,
        mediaItemIndex: 0,
      );
    } catch (e) {
      // Fallback: retorna apenas a música inicial
      return QueueStatus(
        title: 'Rádio Local: ${initialTrack.title}',
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
  bool hasNextPage() => false; // Sem paginação infinita por enquanto

  @override
  Future<List<Media>> nextPage() async => [];

  String _extractGenreFromTrack(TrackEntity track) {
    // Tenta extrair gênero do título da música ou do nome do artista
    // Isso é uma implementação básica - poderia ser melhorado com metadados
    final title = track.title.toLowerCase();
    final artist = track.artist.name.toLowerCase();

    // Palavras-chave de gênero (poderia ser expandido)
    final genres = [
      'rock', 'pop', 'jazz', 'blues', 'classical', 'electronic',
      'hip hop', 'rap', 'country', 'folk', 'reggae', 'punk',
      'metal', 'indie', 'alternative', 'dance', 'house', 'techno'
    ];

    for (final genre in genres) {
      if (title.contains(genre) || artist.contains(genre)) {
        return genre;
      }
    }

    // Fallback: usa o nome do artista como base para busca
    return artist.split(' ').first; // Primeira palavra do nome do artista
  }
}
