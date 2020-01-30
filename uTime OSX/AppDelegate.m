//
//  AppDelegate.m
//  uTime OSX
//
//  Created by Matthew Jagiela on 7/13/16.
//  Copyright © 2016 Matthew Jagiela. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "uTime-Swift.h"

@interface AppDelegate ()
@property (weak) IBOutlet NSWindow *window;
@end


@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    NSMutableArray *nameArray = [[NSUbiquitousKeyValueStore defaultStore]arrayForKey:@"nameArray"];
    NSUserDefaults *launchDefaults = [[NSUserDefaults alloc]initWithSuiteName:@"group.com.uapps.utime"];
    if([launchDefaults integerForKey:@"currentIndex"]>nameArray.count){
        [launchDefaults setInteger:nameArray.count - 1 forKey:@"currentIndex"];
    }
    NSString *osxMode = [[NSUserDefaults standardUserDefaults] stringForKey:@"AppleInterfaceStyle"];
    if(osxMode == nil){
        NSLog(@"light");
    }
    else{
        NSLog(@"Dark");
    }
    [_window center];
    [[NSUserNotificationCenter defaultUserNotificationCenter]setDelegate:self];
    [_window setLevel:NSFloatingWindowLevel];
    [self.window setLevel:NSFloatingWindowLevel];
    [[NSUserNotificationCenter defaultUserNotificationCenter]removeAllDeliveredNotifications];
}
- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification{
    return YES;
}
- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication {
    return YES;
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
    NSLog(@"Quitting App");
    ViewController *home = [[ViewController alloc]init];
    [home saveCurrentIndex];
}

@end
