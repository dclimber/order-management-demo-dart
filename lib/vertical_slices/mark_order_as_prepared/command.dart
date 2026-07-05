import '../../api.dart';

final class MarkOrderAsPreparedCommand {
  const MarkOrderAsPreparedCommand({required this.orderId});

  final OrderId orderId;
}