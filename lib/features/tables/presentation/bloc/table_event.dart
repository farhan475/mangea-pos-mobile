part of 'table_bloc.dart';

abstract class TableEvent extends Equatable {
  const TableEvent();

  @override
  List<Object?> get props => [];
}

class LoadTables extends TableEvent {}

class LoadTablesByStatus extends TableEvent {
  final TableStatus status;

  const LoadTablesByStatus(this.status);

  @override
  List<Object?> get props => [status];
}

class CreateTable extends TableEvent {
  final TableEntity table;

  const CreateTable(this.table);

  @override
  List<Object?> get props => [table];
}

class UpdateTable extends TableEvent {
  final TableEntity table;

  const UpdateTable(this.table);

  @override
  List<Object?> get props => [table];
}

class UpdateTableStatus extends TableEvent {
  final String tableId;
  final TableStatus status;

  const UpdateTableStatus(this.tableId, this.status);

  @override
  List<Object?> get props => [tableId, status];
}

class DeleteTable extends TableEvent {
  final String tableId;

  const DeleteTable(this.tableId);

  @override
  List<Object?> get props => [tableId];
}
