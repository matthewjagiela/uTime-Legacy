//
//  InfoViewController.m
//  uTime
//
//  Created by Matthew Jagiela on 8/5/16.
//  Copyright © 2016 Matthew Jagiela. All rights reserved.
//

#import "InfoViewController.h"
#import "ViewController.h"


@interface InfoViewController ()

@end

@implementation InfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    [_currentVersion setStringValue:@"Currently Running Version 3.0.8"];
    //[self internetLabels];
    NSTimer *countdownTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(touchBarStuff) userInfo:nil repeats:YES];
    if([[NSUbiquitousKeyValueStore defaultStore]boolForKey:@"sortDate"]){
        NSLog(@"There is a sort by date");
        _sortDateCheck.state = NSOnState;
    }
    else{
        NSLog(@"There is no sort by date");
        _sortDateCheck.state = NSOffState;
    }
    NSUbiquitousKeyValueStore *store = [NSUbiquitousKeyValueStore defaultStore];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(storeDidChange:)
                                                 name:NSUbiquitousKeyValueStoreDidChangeExternallyNotification
                                               object:store];
    [self internetLabels];
    [self checkTheme]; //Check the theme on the load of the view
    NSTimer *subCheck = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(checkTheme) userInfo:nil repeats:YES];
}
- (void)storeDidChange:(NSNotification *)notification{
    if([[NSUbiquitousKeyValueStore defaultStore]boolForKey:@"sortDate"]){
        _sortDateCheck.state = NSOnState;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"sortDate"
                                                            object:nil];
    }
    else{
        _sortDateCheck.state = NSOffState;
    }
}
-(void)viewDidAppear{
    [self internetLabels]; // Used to take the data from the web

}
-(void)checkTheme{
    NSString *osxMode= [[NSUserDefaults standardUserDefaults]stringForKey:@"AppleInterfaceStyle"];
    if(osxMode == nil){ //Light mode
        [_blurEffect setMaterial:NSVisualEffectMaterialLight];
        [_blurEffect setAppearance:[NSAppearance appearanceNamed:NSAppearanceNameVibrantLight]];
    }
    else{ //Dark Mode
        [_blurEffect setMaterial:NSVisualEffectMaterialUltraDark];
        [_blurEffect setAppearance:[NSAppearance appearanceNamed:NSAppearanceNameVibrantDark]];
    }
}
-(void)touchBarStuff{
    ViewController *home = [[ViewController alloc]init];
    [_touchLabel setStringValue:[home countDown]];
    
}
-(void)internetLabels{ //if sandbox networking (out and in) are off this will fail.
    NSString *getWebInfo = @"https://matthewjagiela.github.io/uApps-HTML/"; //The url of the file to read
    
    NSError *error; //Error
    
    
    NSURL *URLFormat = [NSURL URLWithString:getWebInfo];
    
    @try{
        NSString *webFormat = [NSString stringWithContentsOfURL:URLFormat encoding:NSASCIIStringEncoding error:&error];
        NSCharacterSet *newlineCharSet = [NSCharacterSet newlineCharacterSet];
        NSArray *lines = [webFormat componentsSeparatedByCharactersInSet:newlineCharSet];
        for (int i = 0; i < lines.count; i++) {
            NSLog(@"I = %i = %@",i,lines[i]);
        }
        [_webNewVersion setStringValue:lines[3]];
        [_webNewsLabel setStringValue:lines[4]];

    }
    @catch(NSException *exception)
    {
        
    }
    
}
- (IBAction)webSupport:(id)sender {
    NSURL *supportURL = [NSURL URLWithString:@"https://uappsios.com/utime-macos-support/"];
    [[NSWorkspace sharedWorkspace]openURL:supportURL];
    
}

- (IBAction)uTimeiOS:(id)sender {
    [[NSWorkspace sharedWorkspace]openURL:[NSURL URLWithString:@"https://itunes.apple.com/us/app/utime-universal/id1125889944?mt=8"]];
}

- (IBAction)sortDate:(id)sender {
    if(_sortDateCheck.state == NSOnState){
        [[NSUbiquitousKeyValueStore defaultStore]setBool:true forKey:@"sortDate"];
        NSLog(@"On state");
    }
    else{
        NSLog(@"The switch is off");
        [[NSUbiquitousKeyValueStore defaultStore]setBool:false forKey:@"sortDate"];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"sortDate"
                                                        object:nil];
}

- (IBAction)sortNameCheck:(id)sender {
    if(_sortNameCheck.state == NSOnState){
        [[NSUbiquitousKeyValueStore defaultStore]setBool:true forKey:@"sortName"];
    }
    else{
        [[NSUbiquitousKeyValueStore defaultStore]setBool:false forKey:@"sortName"];
    }
}

- (IBAction)privacyView:(id)sender {
    NSURL *supportURL = [NSURL URLWithString:@"https://uappsios.com/utime-privacy-policy/"];
    [[NSWorkspace sharedWorkspace]openURL:supportURL];
}
- (IBAction)uTime4Info:(id)sender {
    //This method is going to either go to the web page with uTime 4 macOS info or to the macOS Download page
   NSURL *supportURL = [NSURL URLWithString:@"https://uappsios.com/utime-4-macos-migration-info/"];
      [[NSWorkspace sharedWorkspace]openURL:supportURL];
}
@end
