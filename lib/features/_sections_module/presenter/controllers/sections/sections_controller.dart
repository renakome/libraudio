import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:musily/core/domain/presenter/app_controller.dart';
import 'package:musily/core/presenter/controllers/core/core_controller.dart';
import 'package:musily/features/_library_module/domain/entities/library_item_entity.dart';
import 'package:musily/features/_library_module/domain/usecases/get_library_items_usecase.dart';
import 'package:musily/features/_sections_module/data/services/recommendations_color_processor.dart';
import 'package:musily/features/_sections_module/domain/entities/section_entity.dart';
import 'package:musily/features/_sections_module/domain/usecases/get_sections_usecase.dart';
import 'package:musily/features/_sections_module/presenter/controllers/sections/sections_data.dart';
import 'package:musily/features/_sections_module/presenter/controllers/sections/sections_methods.dart';
import 'package:musily/features/artist/domain/usecases/get_artist_usecase.dart';
import 'package:musily/features/playlist/domain/usecases/get_playlist_usecase.dart';
import 'package:musily/features/track/domain/entities/track_entity.dart';
import 'package:musily/core/domain/usecases/get_upnext_usecase.dart';
import 'dart:developer' as dev;

class SectionsController extends BaseController<SectionsData, SectionsMethods> {
  late final GetSectionsUsecase _getSectionsUsecase;
  late final GetLibraryItemsUsecase _getLibraryItemsUsecase;
  late final GetUpNextUsecase _getUpNextUsecase;
  late final GetArtistUsecase _getArtistUsecase;
  late final GetPlaylistUsecase _getPlaylistUsecase;
  late final CoreController _coreController;

  SectionsController({
    required GetSectionsUsecase getSectionsUsecase,
    required GetLibraryItemsUsecase getLibraryItemsUsecase,
    required GetUpNextUsecase getUpNextUsecase,
    required GetArtistUsecase getArtistUsecase,
    required GetPlaylistUsecase getPlaylistUsecase,
    required CoreController coreController,
  }) {
    _getSectionsUsecase = getSectionsUsecase;
    _getLibraryItemsUsecase = getLibraryItemsUsecase;
    _getUpNextUsecase = getUpNextUsecase;
    _getArtistUsecase = getArtistUsecase;
    _getPlaylistUsecase = getPlaylistUsecase;
    _coreController = coreController;

    _coreController.networkListeners.add(methods.getSections);
  }

  @override
  SectionsData defineData() {
    return SectionsData(
      loadingSections: true,
      sections: [],
      carouselRecommendedTracks: [],
      gridRecommendedTracks: [],
      librarySection: HomeSectionEntity(
        id: 'library',
        title: 'library',
        content: [],
      ),
    );
  }

  @override
  SectionsMethods defineMethods() {
    return SectionsMethods(
      getSections: () async {
        if (_coreController.data.offlineMode) {
          return;
        }

        // Verificar cache antes de recarregar
        if (data.isCacheValid && data.sections.isNotEmpty) {
          dev.log('Using cached sections data');
          return; // Usar dados em cache
        }

        updateData(
          data.copyWith(
            loadingSections: true,
          ),
        );
        try {
          // Carregar dados locais primeiro (otimizado com limite)
          final libraryItems = await _getLibraryItemsUsecase.execOptimized(
            limit: 50, // Limitar para performance inicial
            includeOnlyWithTracks: true, // Apenas itens com conteúdo
          );

          // Atualizar UI com dados locais imediatamente
          updateData(
            data.copyWith(
              librarySection: HomeSectionEntity(
                id: 'library',
                title: 'library',
                content: libraryItems,
              ),
            ),
          );

          // Carregar dados remotos em paralelo com lazy loading
          final sectionsFuture = _getSectionsUsecase.exec();

          // Iniciar carregamento de recomendações em background (lazy)
          _loadRecommendationsInBackground(libraryItems);

          final sections = await sectionsFuture;

          updateData(
            data.copyWith(
              sections: sections,
              lastDataUpdate: DateTime.now(), // Atualizar cache timestamp
              // Recomendações serão carregadas depois via _loadRecommendationsInBackground
            ),
          );
        } catch (e) {
          catchError(e);
        }
        updateData(
          data.copyWith(
            loadingSections: false,
          ),
        );
      },
      generateRecommendations: () async {
        try {
          final libraryItems = await _getLibraryItemsUsecase.exec();
          final shuffledLibraryItems = List.from(libraryItems)..shuffle();

          List<TrackEntity> seedTracks = [];
          final random = Random();

          final randomAlbums = shuffledLibraryItems
              .where((item) => item.album != null)
              .toList()
              .take(3)
              .toList();
          final randomArtist = shuffledLibraryItems
              .where((item) => item.artist != null)
              .toList()
              .take(1)
              .toList();
          final randomPlaylist = shuffledLibraryItems
              .where((item) => item.playlist != null)
              .toList()
              .take(1)
              .toList();

          for (final album in randomAlbums) {
            try {
              final tracks = album.album!.tracks;
              seedTracks.addAll(tracks);
            } catch (e) {
              dev.log(
                  'Error getting tracks from album ${album.album?.title}: $e');
              continue;
            }
          }
          for (final artist in randomArtist) {
            try {
              final artistEntity = await _getArtistUsecase.exec(artist.id);
              if (artistEntity != null) {
                seedTracks.addAll(artistEntity.topTracks);
              }
            } catch (e) {
              dev.log(
                  'Error getting tracks from artist ${artist.artist?.name}: $e');
            }
          }
          for (final playlist in randomPlaylist) {
            try {
              final playlistEntity =
                  await _getPlaylistUsecase.exec(playlist.id);
              if (playlistEntity != null) {
                seedTracks.addAll(playlistEntity.tracks);
              }
            } catch (e) {
              dev.log(
                  'Error getting tracks from playlist ${playlist.playlist?.title}: $e');
            }
          }

          if (seedTracks.isNotEmpty) {
            seedTracks.shuffle(random);
            seedTracks = seedTracks.take(3).toList();
          }

          List<TrackEntity> upNextTracks = [];

          for (final seedTrack in seedTracks) {
            try {
              final upNext = await _getUpNextUsecase.exec(seedTrack);
              upNextTracks.addAll(upNext);
            } catch (e) {
              dev.log('Error getting UpNext for ${seedTrack.title}: $e');
            }
          }

          final imageUrls = upNextTracks
              .map((track) => track.lowResImg ?? '')
              .where((url) => url.isNotEmpty)
              .toList();

          List<Map<String, int>> colorResults = [];
          if (imageUrls.isNotEmpty) {
            try {
              colorResults = await processMultipleImageColors(imageUrls);
            } catch (e) {
              dev.log('Error processing image colors in isolate: $e');
            }
          }

          List<RecommendedTrackModel> recommendedTracks = [];
          int colorIndex = 0;

          for (final track in upNextTracks) {
            if (track.lowResImg == null || track.lowResImg!.isEmpty) {
              recommendedTracks.add(RecommendedTrackModel(
                track: track,
                backgroundColor: const Color(0xFFD8B4FA),
                textColor: Colors.black,
              ));
              continue;
            }

            if (colorIndex < colorResults.length) {
              final colorData = colorResults[colorIndex];
              recommendedTracks.add(RecommendedTrackModel(
                track: track,
                backgroundColor: Color(colorData['backgroundColor']!),
                textColor: Color(colorData['textColor']!),
              ));
              colorIndex++;
            } else {
              recommendedTracks.add(RecommendedTrackModel(
                track: track,
                backgroundColor: const Color(0xFFD8B4FA),
                textColor: Colors.black,
              ));
            }
          }

          updateData(
            data.copyWith(
              carouselRecommendedTracks:
                  recommendedTracks.sublist(0, recommendedTracks.length ~/ 2),
              gridRecommendedTracks: recommendedTracks.sublist(
                  recommendedTracks.length ~/ 2, recommendedTracks.length),
            ),
          );
        } catch (e) {
          catchError(e);
        }
      },
    );
  }

  // Método auxiliar para selecionar seeds otimizados
  List<TrackEntity> _selectOptimalSeeds(List<LibraryItemEntity> libraryItems) {
    if (libraryItems.isEmpty) return [];

    final random = Random();
    final shuffledItems = List.from(libraryItems)..shuffle(random);

    final seedTracks = <TrackEntity>[];

    // Priorizar álbuns com mais tracks
    final albums = shuffledItems
        .where((item) => item.album != null && item.album!.tracks.isNotEmpty)
        .take(2)
        .toList();

    for (final album in albums) {
      try {
        final tracks = album.album!.tracks.take(5).toList(); // Limitar tracks por álbum
        seedTracks.addAll(tracks);
      } catch (e) {
        continue;
      }
    }

        // Adicionar alguns tracks de álbuns se não temos suficientes
        if (seedTracks.length < 3) {
          final additionalAlbums = shuffledItems
              .where((item) => item.album != null && item.album!.tracks.isNotEmpty)
              .skip(2) // Pular os primeiros que já processamos
              .take(3)
              .toList();

          for (final album in additionalAlbums) {
            final tracks = album.album!.tracks.take(2).toList();
            seedTracks.addAll(tracks);
          }
        }

    return seedTracks.take(5).toList(); // Máximo 5 seeds
  }

  // Lazy loading de recomendações em background
  void _loadRecommendationsInBackground(List<LibraryItemEntity> libraryItems) {
    // Executar em background para não bloquear UI
    Future.microtask(() async {
      try {
        final recommendations = await _generateRecommendationsParallel(libraryItems);

        // Atualizar UI quando recomendações estiverem prontas
        updateData(
          data.copyWith(
            carouselRecommendedTracks: recommendations.take(10).toList(),
            gridRecommendedTracks: recommendations.skip(10).take(20).toList(),
          ),
        );
      } catch (e) {
        dev.log('Error loading recommendations in background: $e');
        // Não atualizar em caso de erro para manter UI responsiva
      }
    });
  }

  // Método otimizado para gerar recomendações em paralelo
  Future<List<RecommendedTrackModel>> _generateRecommendationsParallel(List<LibraryItemEntity> libraryItems) async {
    if (libraryItems.isEmpty) return [];

    try {
      // Selecionar seeds de forma mais eficiente
      final seeds = _selectOptimalSeeds(libraryItems);
      if (seeds.isEmpty) return [];

      // Buscar UpNext em paralelo com limite
      final upNextFutures = seeds.map((seed) =>
        _getUpNextUsecase.exec(seed).catchError((e) {
          dev.log('Error getting UpNext for ${seed.title}: $e');
          return <TrackEntity>[];
        })
      ).toList();

      final upNextResults = await Future.wait(upNextFutures);
      final upNextTracks = upNextResults.expand((tracks) => tracks).toList();

      // Limitar e embaralhar para performance
      upNextTracks.shuffle();
      final limitedTracks = upNextTracks.take(30).toList();

      // Processar cores em isolate (background)
      return await _processRecommendationsInIsolate(limitedTracks);
    } catch (e) {
      dev.log('Error in parallel recommendations: $e');
      return [];
    }
  }

  // Processamento de recomendações em isolate para melhor performance
  Future<List<RecommendedTrackModel>> _processRecommendationsInIsolate(List<TrackEntity> tracks) async {
    if (tracks.isEmpty) return [];

    try {
      // Preparar dados para processamento em isolate
      final imageUrls = tracks
          .map((track) => track.lowResImg ?? '')
          .where((url) => url.isNotEmpty)
          .take(10) // Limitar processamento
          .toList();

      List<Map<String, int>> colorResults = [];
      if (imageUrls.isNotEmpty) {
        colorResults = await compute(processMultipleImageColors, imageUrls);
      }

      final recommendedTracks = <RecommendedTrackModel>[];
      int colorIndex = 0;

      for (final track in tracks.take(20)) { // Limitar a 20 recomendações
        if (track.lowResImg == null || track.lowResImg!.isEmpty) {
          recommendedTracks.add(RecommendedTrackModel(
            track: track,
            backgroundColor: const Color(0xFFD8B4FA),
            textColor: Colors.black,
          ));
          continue;
        }

        Color backgroundColor = const Color(0xFFD8B4FA);
        Color textColor = Colors.black;

        if (colorIndex < colorResults.length) {
          final colorData = colorResults[colorIndex];
          backgroundColor = Color.fromRGBO(
            colorData['r'] ?? 216,
            colorData['g'] ?? 180,
            colorData['b'] ?? 250,
            1.0,
          );
          textColor = ThemeData.estimateBrightnessForColor(backgroundColor) ==
                  Brightness.dark
              ? Colors.white
              : Colors.black;
          colorIndex++;
        }

        recommendedTracks.add(RecommendedTrackModel(
          track: track,
          backgroundColor: backgroundColor,
          textColor: textColor,
        ));
      }

      return recommendedTracks;
    } catch (e) {
      dev.log('Error processing recommendations in isolate: $e');
      // Fallback: retornar tracks sem cores processadas
      return tracks.take(10).map((track) => RecommendedTrackModel(
        track: track,
        backgroundColor: const Color(0xFFD8B4FA),
        textColor: Colors.black,
      )).toList();
    }
  }
}
