//
//  ChangeTimer.m
//  uTime
//
//  Created by Matthew Jagiela on 10/3/16.
//  Copyright © 2016 Matthew Jagiela. All rights reserved.
//

#import "ChangeTimer.h"
#import "ViewController.h"

@interface ChangeTimer ()

@end

@implementation ChangeTimer
int currentIndexChange;
NSUserDefaults *changeDefaults;
NSMutableArray *nameArrayChange;
NSMutableArray *timeArrayChange;
NSDateFormatter *dateFormatterChange;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    dateFormatterChange = [[NSDateFormatter alloc]init];
    changeDefaults = [[NSUserDefaults alloc]initWithSuiteName:@"group.com.uapps.utime"];
    nameArrayChange = [[[NSUbiquitousKeyValueStore defaultStore]arrayForKey:@"nameArray"]mutableCopy];
    timeArrayChange = [[[NSUbiquitousKeyValueStore defaultStore]arrayForKey:@"timeArray"]mutableCopy];
    
    
    currentIndexChange = [changeDefaults integerForKey:@"currentIndex"];
    [_countdownName setStringValue:[nameArrayChange objectAtIndex:currentIndexChange]];
    
    NSLog(@"The current index says this is the time %@",[timeArrayChange objectAtIndex:currentIndexChange]);
    NSLog(@"CURRENT INDEX CHANGE TIMER = %i",currentIndexChange);
    
    [dateFormatterChange setDateFormat:@"MM-dd-yyyy hh:mm:ss a"];
    [_datePicker setDateValue:[dateFormatterChange dateFromString:[timeArrayChange objectAtIndex:currentIndexChange]]];
    NSLog(@"Name array change @ index  = %@",[nameArrayChange objectAtIndex:currentIndexChange]);
    [_countdownName setStringValue:[nameArrayChange objectAtIndex:currentIndexChange]];
   // [self printArray];   TESTING ONLY
    
    
}
-(void)viewDidDisappear{
    
    [nameArrayChange replaceObjectAtIndex:currentIndexChange withObject:[_countdownName stringValue]];
    [timeArrayChange replaceObjectAtIndex:currentIndexChange withObject:[dateFormatterChange stringFromDate:[_datePicker dateValue]]];
    [[NSUbiquitousKeyValueStore defaultStore]setArray:nameArrayChange forKey:@"nameArray"];
    [[NSUbiquitousKeyValueStore defaultStore]setArray:timeArrayChange forKey:@"timeArray"];
    [[NSUbiquitousKeyValueStore defaultStore]synchronize];
    
    ViewController *home = [[ViewController alloc]init];
    [home changeStore];
    [home setOldDate:[dateFormatterChange stringFromDate:[_datePicker dateValue]]];
    [changeDefaults setBool:YES forKey:@"changed"];
    [self rescheduleNotification];
    [home findIndex];
    [home countToLabel];
}
-(void)printArray{
    for (int i = 0; i < nameArrayChange.count; i++) {
        NSLog(@"At index %i timeArray = %@",i,timeArrayChange[i]);
    }
}


- (IBAction)doneChanging:(id)sender {
    
}

- (IBAction)todayButton:(id)sender {
    
    [_datePicker setDateValue:[NSDate date]];
}
-(void)rescheduleNotification{
    NSArray *notificationArray = [[NSUserNotificationCenter defaultUserNotificationCenter]scheduledNotifications];
    NSMutableArray *nameArray = [[NSUbiquitousKeyValueStore defaultStore]arrayForKey:@"nameArray"];
    NSMutableArray *dateArray = [[NSUbiquitousKeyValueStore defaultStore]arrayForKey:@"timeArray"];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
    [dateFormat setDateFormat:@"MM-dd-yyyy hh:mm:ss a"];
    
    for (int i = 0; i < notificationArray.count; i++) {
        NSUserNotification *note = [notificationArray objectAtIndex:i];
        [[NSUserNotificationCenter defaultUserNotificationCenter]removeScheduledNotification:note];
    }
    for (int d = 0; d < nameArray.count; d++){
        NSUserNotification *localNotification = [[NSUserNotification alloc]init];
        localNotification.deliveryDate = [dateFormat dateFromString:[dateArray objectAtIndex:d]];
        if([localNotification.deliveryDate compare:[NSDate date]]==NSOrderedAscending){
            NSLog(@"Older do not fire");
        }
        else{
            localNotification.informativeText = [NSString stringWithFormat:@"The Timer %@ Has No Time Left!",[nameArray objectAtIndex:d]];
            localNotification.title = @"uTime";
            localNotification.soundName = NSUserNotificationDefaultSoundName;
            [[NSUserNotificationCenter defaultUserNotificationCenter]scheduleNotification:localNotification];
        }
        
    }
}
@end
