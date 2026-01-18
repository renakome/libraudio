import 'package:media_kit/media_kit.dart';
import 'package:musily/features/track/domain/entities/track_entity.dart';

/// Interface para filas de reprodução, incluindo rádios
abstract class MusilyQueue {
  /// Item a ser pré-carregado antes de iniciar a fila
  TrackEntity? get preloadItem;

  /// Obtém o status inicial da fila
  Future<QueueStatus> getInitialStatus();

  /// Verifica se há uma próxima página disponível
  bool hasNextPage();

  /// Obtém a próxima página de itens
  Future<List<Media>> nextPage();
}

/// Status da fila com informações sobre os itens e posição atual
class QueueStatus {
  final String? title;
  final List<Media> items;
  final int mediaItemIndex;
  final Duration position;

  const QueueStatus({
    this.title,
    required this.items,
    this.mediaItemIndex = 0,
    this.position = Duration.zero,
  });

  QueueStatus copyWith({
    String? title,
    List<Media>? items,
    int? mediaItemIndex,
    Duration? position,
  }) {
    return QueueStatus(
      title: title ?? this.title,
      items: items ?? this.items,
      mediaItemIndex: mediaItemIndex ?? this.mediaItemIndex,
      position: position ?? this.position,
    );
  }
}
