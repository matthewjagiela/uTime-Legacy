//
//  TimerTableViewController.h
//  uTime
//
//  Created by Matthew Jagiela on 7/14/16.
//  Copyright © 2016 Matthew Jagiela. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TimerTableViewController : NSViewController <NSTableViewDataSource,NSTableViewDelegate>
@property (weak) IBOutlet NSTableView *tableView;
@property (weak) IBOutlet NSTextField *currentSelection;
@property (weak) IBOutlet NSButton *deleteTimer;

- (IBAction)deleteTimer:(id)sender;
- (IBAction)closeTable:(id)sender;

@end
