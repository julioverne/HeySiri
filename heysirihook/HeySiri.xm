#import <objc/runtime.h>
#import <notify.h>
#import <substrate.h>

extern const char *__progname;

#define NSLog(...)

#define PLIST_PATH_Settings "/var/mobile/Library/Preferences/com.julioverne.heysiri.plist"


static BOOL Enabled;

%group mediaserverdHooks
%hook VTBatteryMonitor
-(int)batteryState
{
	if(Enabled) {
		return 1;
	}
	return %orig;
}
%end
%end

#import <libactivator/libactivator.h>
#import <Flipswitch/Flipswitch.h>

static void settingsChangedHeySiri(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
	@autoreleasepool {
		NSDictionary *Prefs = [[[NSDictionary alloc] initWithContentsOfFile:@PLIST_PATH_Settings]?:@{} copy];
		Enabled = (BOOL)[Prefs[@"Enabled"]?:@YES boolValue];
		if(!strcmp(__progname, "SpringBoard")) {
			[[%c(FSSwitchPanel) sharedPanel] stateDidChangeForSwitchIdentifier:@"com.julioverne.heysiri"];
		}
		notify_post("com.julioverne.heysiri/SettingsChanged/Toogle");
		notify_post("kAFPreferencesDidChangeDarwinNotification");
		notify_post("AFInternalPreferencesDidChangeDarwinNotification");
		notify_post("kVTPreferencesVoiceTriggerEnabledDidChangeDarwinNotification");
	}
}


@interface HeySiriActivatorSwitch : NSObject <FSSwitchDataSource>
+ (id)sharedInstance;
+ (BOOL)sharedInstanceExist;
- (void)RegisterActions;
@end

@implementation HeySiriActivatorSwitch
__strong static id _sharedObject;
+ (id)sharedInstance
{
	if (!_sharedObject) {
		_sharedObject = [[self alloc] init];
	}
	return _sharedObject;
}
+ (BOOL)sharedInstanceExist
{
	if (_sharedObject) {
		return YES;
	}
	return NO;
}
- (void)RegisterActions
{
    if (access("/usr/lib/libactivator.dylib", F_OK) == 0) {
		dlopen("/usr/lib/libactivator.dylib", RTLD_LAZY);
	    if (Class la = objc_getClass("LAActivator")) {
			[[la sharedInstance] registerListener:(id<LAListener>)self forName:@"com.julioverne.heysiri"];
		}
	}
}
- (NSString *)activator:(LAActivator *)activator requiresLocalizedTitleForListenerName:(NSString *)listenerName
{
	return @"HeySiri";
}
- (NSString *)activator:(LAActivator *)activator requiresLocalizedDescriptionForListenerName:(NSString *)listenerName
{
	return @"Action For Toggle Enabled/Disabled.";
}
- (UIImage *)activator:(LAActivator *)activator requiresIconForListenerName:(NSString *)listenerName scale:(CGFloat)scale
{
    static __strong UIImage* listenerIcon;
    if (!listenerIcon) {
		listenerIcon = [[UIImage alloc] initWithContentsOfFile:[[NSBundle bundleWithPath:@"/Library/PreferenceBundles/HeySiriSettings.bundle"] pathForResource:scale==2.0f?@"icon@2x":@"icon" ofType:@"png"]];
	}
    return listenerIcon;
}
- (UIImage *)activator:(LAActivator *)activator requiresSmallIconForListenerName:(NSString *)listenerName scale:(CGFloat)scale
{
    static __strong UIImage* listenerIcon;
    if (!listenerIcon) {
		listenerIcon = [[UIImage alloc] initWithContentsOfFile:[[NSBundle bundleWithPath:@"/Library/PreferenceBundles/HeySiriSettings.bundle"] pathForResource:scale==2.0f?@"icon@2x":@"icon" ofType:@"png"]];
	}
    return listenerIcon;
}
- (void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event
{
	@autoreleasepool {
		NSMutableDictionary *Prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@PLIST_PATH_Settings]?:[NSMutableDictionary dictionary];
		Prefs[@"Enabled"] = [Prefs[@"Enabled"]?:@YES boolValue]?@NO:@YES;
		[Prefs writeToFile:@PLIST_PATH_Settings atomically:YES];
		notify_post("com.julioverne.heysiri/SettingsChanged");
	}
}
- (FSSwitchState)stateForSwitchIdentifier:(NSString *)switchIdentifier
{
	return Enabled?FSSwitchStateOn:FSSwitchStateOff;
}
- (void)applyActionForSwitchIdentifier:(NSString *)switchIdentifier
{
	[self activator:nil receiveEvent:nil];
}
- (void)applyAlternateActionForSwitchIdentifier:(NSString *)switchIdentifier
{
	[[%c(FSSwitchPanel) sharedPanel] openURLAsAlternateAction:[NSURL URLWithString:@"prefs:root=HeySiri"]];
}
@end


%ctor
{
	@autoreleasepool {
		CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, settingsChangedHeySiri, CFSTR("com.julioverne.heysiri/SettingsChanged"), NULL, CFNotificationSuspensionBehaviorCoalesce);
		settingsChangedHeySiri(NULL, NULL, NULL, NULL, NULL);
		if(!strcmp(__progname, "mediaserverd")) {
			dlopen("/System/Library/PrivateFrameworks/VoiceTrigger.framework/VoiceTrigger", RTLD_LAZY);
			%init(mediaserverdHooks);
		} else {
			[[HeySiriActivatorSwitch sharedInstance] RegisterActions];
		}
	}
}
