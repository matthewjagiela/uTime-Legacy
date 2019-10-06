//
//  ViewController.h
//  uTime OSX
//
//  Created by Matthew Jagiela on 7/13/16.
//  Copyright © 2016 Matthew Jagiela. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SnowScene.h"
@import SpriteKit;


@interface ViewController : NSViewController <NSTableViewDataSource,NSTabViewDelegate,NSSearchFieldDelegate>
@property (strong) IBOutlet NSSearchField *searchBar;
@property (weak) IBOutlet NSTextField *currentTimeLabel;
@property (weak) IBOutlet NSTextField *countdownToLabel;
@property (weak) IBOutlet NSDatePicker *datePicker;
@property (weak) IBOutlet NSTextField *namePicker;
@property (weak) IBOutlet NSTextField *changeCurrentNameLabel;
@property (weak) IBOutlet NSTextField *changeCurrentTimeLabel;
@property (weak) IBOutlet NSButton *doneChangingButton; 
@property (weak) IBOutlet NSTextField *countdownLabel;
@property (weak) IBOutlet NSTableView *tableView;
@property (weak) IBOutlet NSVisualEffectView *blurEffect;
@property (weak) IBOutlet NSTextField *touchLabel;
//@property (weak) IBOutlet SKView *ParticleBackground;
@property (weak) IBOutlet NSVisualEffectView *deleteView;
@property (weak) IBOutlet NSTextField *touchbarDelete;
@property (weak) IBOutlet NSTextField *welcomeLabel;
@property (weak) IBOutlet NSButton *addTimerButton;
@property (strong) IBOutlet SKView *particleBackground;



-(void)goodbyetoeverybody;
-(IBAction)testBar:(id)sender;

- (IBAction)addTimer:(id)sender;
- (IBAction)doneChanging:(id)sender;
- (IBAction)changeTimer:(id)sender;
@property (weak) IBOutlet NSButton *resizeTest;
- (IBAction)resizeTestAction:(id)sender;
- (IBAction)getViewSize:(id)sender;
-(IBAction)deleteTouchBar:(id)sender;
-(void)updateCurrentTimeLabel;
-(void)countToLabel;
-(void)changeStore;
-(void)saveCurrentIndex;
-(NSString *)countDown;
-(void)setOldDate:(NSString *)date;
-(void)findIndex;

@end

