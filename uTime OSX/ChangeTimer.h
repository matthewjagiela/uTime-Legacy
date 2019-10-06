//
//  ChangeTimer.h
//  uTime
//
//  Created by Matthew Jagiela on 10/3/16.
//  Copyright © 2016 Matthew Jagiela. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ChangeTimer : NSViewController
@property (weak) IBOutlet NSTextField *countdownName;
@property (weak) IBOutlet NSDatePicker *datePicker;

- (IBAction)doneChanging:(id)sender;
- (IBAction)todayButton:(id)sender;

@end
