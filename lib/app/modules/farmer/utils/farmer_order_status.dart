import 'package:harvest_hub/app/core/constants/app_constants.dart';

/// Display + transition helpers for order status.
///
/// Both delegate to [OrderStatus] so the state machine and the labels have a
/// single definition shared by the data, farmer and admin layers.
String orderStatusLabel(String status) => OrderStatus.label(status);

List<String> nextFarmerStatuses(String status) => OrderStatus.next(status);
