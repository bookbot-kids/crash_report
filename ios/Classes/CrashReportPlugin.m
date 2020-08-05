#import "CrashReportPlugin.h"
#if __has_include(<crash_report/crash_report-Swift.h>)
#import <crash_report/crash_report-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "crash_report-Swift.h"
#endif

@implementation CrashReportPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftCrashReportPlugin registerWithRegistrar:registrar];
}
@end
