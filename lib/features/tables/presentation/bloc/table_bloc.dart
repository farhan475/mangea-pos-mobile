import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/activity_log_service.dart';
import '../../../../data/local/entities/table_entity.dart';
import '../../../../domain/repository_interfaces/table_repository.dart';

part 'table_event.dart';
part 'table_state.dart';

class TableBloc extends Bloc<TableEvent, TableState> {
  final TableRepository _tableRepository;
  final ActivityLogService? _activityLogService;

  TableBloc(this._tableRepository, {ActivityLogService? activityLogService})
      : _activityLogService = activityLogService,
        super(TableInitial()) {
    on<LoadTables>(_onLoadTables);
    on<LoadTablesByStatus>(_onLoadTablesByStatus);
    on<CreateTable>(_onCreateTable);
    on<UpdateTable>(_onUpdateTable);
    on<UpdateTableStatus>(_onUpdateTableStatus);
    on<DeleteTable>(_onDeleteTable);
  }

  Future<void> _onLoadTables(
    LoadTables event,
    Emitter<TableState> emit,
  ) async {
    emit(TableLoading());
    try {
      final tables = await _tableRepository.getTables();
      emit(TableLoaded(tables));
    } catch (e) {
      emit(TableError(e.toString()));
    }
  }

  Future<void> _onLoadTablesByStatus(
    LoadTablesByStatus event,
    Emitter<TableState> emit,
  ) async {
    emit(TableLoading());
    try {
      final tables = await _tableRepository.getTablesByStatus(event.status);
      emit(TableLoaded(tables));
    } catch (e) {
      emit(TableError(e.toString()));
    }
  }

  Future<void> _onCreateTable(
    CreateTable event,
    Emitter<TableState> emit,
  ) async {
    try {
      await _tableRepository.createTable(event.table);
      
      // Log activity
      await _activityLogService?.logTableCreated(
        event.table.id,
        event.table.tableNumber,
        event.table.capacity,
      );
      
      add(LoadTables());
    } catch (e) {
      emit(TableError(e.toString()));
    }
  }

  Future<void> _onUpdateTable(
    UpdateTable event,
    Emitter<TableState> emit,
  ) async {
    try {
      await _tableRepository.updateTable(event.table);
      add(LoadTables());
    } catch (e) {
      emit(TableError(e.toString()));
    }
  }

  Future<void> _onUpdateTableStatus(
    UpdateTableStatus event,
    Emitter<TableState> emit,
  ) async {
    try {
      // Get old table for comparison
      final oldTable = await _tableRepository.getTableById(event.tableId);
      
      await _tableRepository.updateTableStatus(event.tableId, event.status);
      
      // Log activity
      if (oldTable != null) {
        await _activityLogService?.logTableStatusChanged(
          event.tableId,
          oldTable.tableNumber,
          oldTable.status.name,
          event.status.name,
        );
      }
      
      add(LoadTables());
    } catch (e) {
      emit(TableError(e.toString()));
    }
  }

  Future<void> _onDeleteTable(
    DeleteTable event,
    Emitter<TableState> emit,
  ) async {
    try {
      // Get table before deleting for logging
      final table = await _tableRepository.getTableById(event.tableId);
      
      await _tableRepository.deleteTable(event.tableId);
      
      // Log activity
      if (table != null) {
        await _activityLogService?.logTableDeleted(
          event.tableId,
          table.tableNumber,
        );
      }
      
      add(LoadTables());
    } catch (e) {
      emit(TableError(e.toString()));
    }
  }
}
