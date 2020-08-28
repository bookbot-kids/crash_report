import 'package:flutter_test/flutter_test.dart';
import 'package:crash_report/crash_report.dart';
import 'package:logger/logger.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('setupReport', () async {
    await CrashReport.instance.init(Logger());
    expect(true, true);
  });

  test('testCrash', () async {
    await CrashReport.instance.crash();
  });
}
