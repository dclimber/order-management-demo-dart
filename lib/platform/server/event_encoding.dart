import '../../api.dart';
import '../event_store/serialization.dart';

List<Map<String, dynamic>> encodeEvents(Iterable<Event> events) => events.map(encodeEvent).toList();
