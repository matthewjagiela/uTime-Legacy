
//  InfoViewController.h
//  uTime
//
//  Created by Matthew Jagiela on 8/5/16.
//  Copyright © 2016 Matthew Jagiela. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface InfoViewController : NSViewController
@property (weak) IBOutlet NSTextField *uAppsNews;
@property (weak) IBOutlet NSTextField *newestVersion;
@property (weak) IBOutlet NSTextField *currentVersion;
@property (weak) IBOutlet NSTextField *touchLabel;
@property (weak) IBOutlet NSButton *sortDateCheck;
@property (weak) IBOutlet NSButton *sortNameCheck;
@property (weak) IBOutlet NSVisualEffectView *blurEffect;
@property (weak) IBOutlet NSTextField *webNewsLabel;
@property (weak) IBOutlet NSTextField *webNewVersion;
@property (strong) IBOutlet NSButton *privacyButton;
@property (weak) IBOutlet NSButton *uTime4Button;


- (IBAction)webSupport:(id)sender;
- (IBAction)uTimeiOS:(id)sender;
- (IBAction)sortDate:(id)sender;
- (IBAction)sortName:(id)sender;
- (IBAction)privacyView:(id)sender;


@end
