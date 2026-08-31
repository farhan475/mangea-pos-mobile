import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mangea_app/features/reports/data/daily_report_model.dart';
import 'package:mangea_app/features/reports/domain/report_repository.dart';
import 'package:mangea_app/features/reports/presentation/bloc/report_bloc.dart';
import 'package:mangea_app/features/reports/presentation/bloc/report_event.dart';
import 'package:mangea_app/features/reports/presentation/bloc/report_state.dart';
import 'package:mocktail/mocktail.dart';

class MockReportRepository extends Mock implements ReportRepository {}

void main() {
  late ReportBloc reportBloc;
  late MockReportRepository mockRepository;

  setUp(() {
    mockRepository = MockReportRepository();
    reportBloc = ReportBloc(mockRepository);
  });

  tearDown(() {
    reportBloc.close();
  });

  group('ReportBloc', () {
    final testDate = DateTime(2024, 1, 1);
    final testReport = DailyReportModel(
      date: testDate,
      totalOrders: 10,
      totalRevenue: 500000,
      totalTax: 50000,
      completedOrders: 8,
      cancelledOrders: 2,
      topProducts: const [],
      hourlySales: const [],
    );

    test('initial state is ReportInitial', () {
      expect(reportBloc.state, equals(ReportInitial()));
    });

    blocTest<ReportBloc, ReportState>(
      'emits [ReportLoading, ReportLoaded] when LoadDailyReport succeeds',
      build: () {
        when(() => mockRepository.getDailyReport(testDate))
            .thenAnswer((_) async => testReport);
        return reportBloc;
      },
      act: (bloc) => bloc.add(LoadDailyReport(testDate)),
      expect: () => [
        ReportLoading(),
        ReportLoaded(testReport),
      ],
      verify: (_) {
        verify(() => mockRepository.getDailyReport(testDate)).called(1);
      },
    );

    blocTest<ReportBloc, ReportState>(
      'emits [ReportLoading, ReportError] when LoadDailyReport fails',
      build: () {
        when(() => mockRepository.getDailyReport(testDate))
            .thenThrow(Exception('Failed to load report'));
        return reportBloc;
      },
      act: (bloc) => bloc.add(LoadDailyReport(testDate)),
      expect: () => [
        ReportLoading(),
        isA<ReportError>(),
      ],
    );

    blocTest<ReportBloc, ReportState>(
      'emits [ReportLoading, ReportExported] when ExportReportToCSV succeeds',
      build: () {
        when(() => mockRepository.exportToCSV(testReport))
            .thenAnswer((_) async => '/path/to/report.csv');
        return reportBloc;
      },
      act: (bloc) => bloc.add(ExportReportToCSV(testReport)),
      expect: () => [
        ReportLoading(),
        const ReportExported('/path/to/report.csv', 'CSV'),
      ],
      verify: (_) {
        verify(() => mockRepository.exportToCSV(testReport)).called(1);
      },
    );

    blocTest<ReportBloc, ReportState>(
      'emits [ReportLoading, ReportExported] when ExportReportToPDF succeeds',
      build: () {
        when(() => mockRepository.exportToPDF(testReport))
            .thenAnswer((_) async => '/path/to/report.txt');
        return reportBloc;
      },
      act: (bloc) => bloc.add(ExportReportToPDF(testReport)),
      expect: () => [
        ReportLoading(),
        const ReportExported('/path/to/report.txt', 'PDF'),
      ],
      verify: (_) {
        verify(() => mockRepository.exportToPDF(testReport)).called(1);
      },
    );

    blocTest<ReportBloc, ReportState>(
      'emits [ReportLoading, ReportRangeLoaded] when LoadReportRange succeeds',
      build: () {
        when(() => mockRepository.getReportRange(any(), any()))
            .thenAnswer((_) async => [testReport]);
        return reportBloc;
      },
      act: (bloc) => bloc.add(LoadReportRange(testDate, testDate)),
      expect: () => [
        ReportLoading(),
        ReportRangeLoaded([testReport]),
      ],
    );
  });
}
