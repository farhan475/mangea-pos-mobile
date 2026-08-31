import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

/// Status pesanan sesuai alur Kitchen/Bar -> Payment pada PRD.
enum OrderStatus { inProgress, ready, completed }

extension OrderStatusX on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.inProgress:
        return 'In Progress';
      case OrderStatus.ready:
        return 'Ready';
      case OrderStatus.completed:
        return 'Completed';
    }
  }

  Color get color {
    switch (this) {
      case OrderStatus.inProgress:
        return AppColors.statusInProgress;
      case OrderStatus.ready:
        return AppColors.statusReady;
      case OrderStatus.completed:
        return AppColors.statusCompleted;
    }
  }
}

class OrderModel {
  const OrderModel({
    required this.id,
    required this.tableCode,
    required this.customerName,
    required this.itemCount,
    required this.status,
    required this.totalAmount,
    required this.createdAt,
  });

  final String id;
  final String tableCode;
  final String customerName;
  final int itemCount;
  final OrderStatus status;
  final double totalAmount;
  final DateTime createdAt;
}
