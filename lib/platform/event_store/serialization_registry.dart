import '../../api.dart';

typedef EventEncoder = Map<String, dynamic> Function(Event event);
typedef EventDecoder = Event Function(Map<String, dynamic> json);

/// Per-slice event codec registry (D8).
final class SerializationRegistry {
  final _encoders = <Type, EventEncoder>{};
  final _decoders = <String, EventDecoder>{};

  void register({
    required Type eventType,
    required String kind,
    required EventEncoder encode,
    required EventDecoder decode,
  }) {
    _encoders[eventType] = encode;
    _decoders[kind] = decode;
  }

  bool get isEmpty => _encoders.isEmpty;

  Map<String, dynamic> encode(Event event) {
    final encoder = _encoders[event.runtimeType];
    if (encoder == null) {
      throw StateError('No encoder registered for ${event.runtimeType}');
    }
    return encoder(event);
  }

  Event decode(Map<String, dynamic> json) {
    final kind = json['kind'] as String?;
    if (kind == null) throw const FormatException('Missing event kind');
    final decoder = _decoders[kind];
    if (decoder == null) {
      throw FormatException('Unknown event kind: $kind');
    }
    return decoder(json);
  }
}
