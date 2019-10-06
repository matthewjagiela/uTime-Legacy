//
//  TimerTableViewController.m
//  uTime
//
//  Created by Matthew Jagiela on 7/14/16.
//  Copyright © 2016 Matthew Jagiela. All rights reserved.
//

#import "TimerTableViewController.h"
#import "ViewController.h"

@interface TimerTableViewController ()

@end

@implementation TimerTableViewController
NSMutableArray *nameTableArray;
NSMutableArray *timeTableArray;
NSUserDefaults *tabledefaults;
NSString *timeString;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    [_tableView setDataSource:self];
    
    _tableView.translatesAutoresizingMaskIntoConstraints = TRUE;
    _tableView.rowHeight = 50;
    [_tableView setDelegate:self];
    nameTableArray = [[[NSUbiquitousKeyValueStore defaultStore]arrayForKey:@"nameArray"]mutableCopy];
    timeTableArray = [[[NSUbiquitousKeyValueStore defaultStore]arrayForKey:@"timeArray"]mutableCopy];
    tabledefaults = [[NSUserDefaults alloc]initWithSuiteName:@"group.com.uapps.utime"];
    NSUbiquitousKeyValueStore *store = [NSUbiquitousKeyValueStore defaultStore];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(storeDidChange:)
                                                 name:NSUbiquitousKeyValueStoreDidChangeExternallyNotification
                                               object:store];
    NSLog(@"time table array count %i",timeTableArray.count);
    [self currentLabels:0];
    [_tableView setAllowsMultipleSelection:YES];
    //[self formatting];
}
-(void)formatting{
    for (int i = 0; i < timeTableArray.count; i++) {
        NSDateFormatter *dateFormatter1 = [[NSDateFormatter alloc]init];
        NSDateFormatter *dateFormatter2 = [[NSDateFormatter alloc]init];
        [dateFormatter2 setDateFormat:@"MM-dd-yyyy hh:mm:ss a"];
        [dateFormatter1 setDateFormat:@"EEEE, MMM dd yyyy hh:mm:ss a"];
        NSString *dateText = [dateFormatter2 stringFromDate:[dateFormatter1 dateFromString:[timeTableArray objectAtIndex:i]]];
        NSLog(@"Date text = %@" ,dateText);
        NSLog([dateFormatter2 stringFromDate:[dateFormatter1 dateFromString:[timeTableArray objectAtIndex:i]]]);
    }
}
-(void)storeDidChange:(NSNotification *)notification{
    //NSLog(@"change");
    //--------------------BUG REPORT-------------------//
    nameTableArray = [[[NSUbiquitousKeyValueStore defaultStore]arrayForKey:@"nameArray"]mutableCopy];
    timeTableArray = [[[NSUbiquitousKeyValueStore defaultStore]arrayForKey:@"timeArray"]mutableCopy];
    [_tableView reloadData];
    /** So these work when coming from an iPhone on any OS, Mac on os 10.11 or below but will not work when coming from another Mac running 10.12
     **/
    
    //------END REPORT------------//
    
    
    NSArray *notificationArray = [[NSUserNotificationCenter defaultUserNotificationCenter]scheduledNotifications];
    NSUserNotification *notificationCancel;
    for (int i = 0; i < notificationArray.count; i++) {
        NSLog(@"clearing notifications...");
        notificationCancel = notificationArray[i];
        [[NSUserNotificationCenter defaultUserNotificationCenter]removeScheduledNotification:notificationCancel];
    }
   // NSMutableArray *dateArray = [[NSUbiquitousKeyValueStore defaultStore]arrayForKey:@"timeArray"];
    //NSMutableArray *nameArray = [[NSUbiquitousKeyValueStore defaultStore]arrayForKey:@"nameArray"];
    
    
    
    //----------Manage iCloud Notifications--------------//
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    NSMutableArray *notificationFire = [[NSMutableArray alloc]init];
    NSDate *fireDate;
    NSUserNotification *localNotification = [[NSUserNotification alloc]init];
    [dateFormatter setDateFormat:@"MM-dd-yyyy hh:mm:ss a"];
    for (int i = 0; i < timeTableArray.count; i++) {
        fireDate = [dateFormatter dateFromString:timeTableArray[i]];
        [notificationFire addObject:fireDate];
    }
    for (int d = 0; d < timeTableArray.count; d++) {
        if([notificationFire[d]compare:[NSDate date]] == NSOrderedAscending){
            NSLog(@"Older than the date now... Will not fire...");
        }
        else{
            
            localNotification.deliveryDate = notificationFire[d];
            localNotification.informativeText = [NSString stringWithFormat:@"The Timer %@ Has No Time Left!",nameTableArray[d]];
            localNotification.actionButtonTitle = @"Okay";
            localNotification.title = @"uTime";
            localNotification.soundName = NSUserNotificationDefaultSoundName;
            //[[[NSApplication sharedApplication]dockTile]setBadgeLabel:@"1"];
            //localNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication]applicationIconBadgeNumber] + 1;
            [[NSUserNotificationCenter defaultUserNotificationCenter]scheduleNotification:localNotification];
            
        }
    }

}
-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    if(nameTableArray.count == 1){
        [_deleteTimer setHidden:YES];
    }
    [self.tableView reloadData];
    return nameTableArray.count;
}
-(NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    //NSLog(@"changing the values");
    //Load Table
    NSTableCellView *cellView = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
    if([tableColumn.identifier isEqualToString:@"nameColumn"]){
        cellView.textField.stringValue = [nameTableArray objectAtIndex:row];
    }
    else{
        NSDateFormatter *dateFormatter1 = [[NSDateFormatter alloc]init];
        NSDateFormatter *dateFormatter2 = [[NSDateFormatter alloc]init];
        [dateFormatter2 setDateFormat:@"MM-dd-yyyy hh:mm:ss a"];
        [dateFormatter1 setDateFormat:@"EEEE, MMM dd yyyy hh:mm:ss a"];
        NSString *dateText = [dateFormatter1 stringFromDate:[dateFormatter2 dateFromString:[timeTableArray objectAtIndex:row]]];
        cellView.textField.stringValue = dateText;
    }
    return cellView;
}
-(void)tableViewSelectionDidChange:(NSNotification *)notification{
    NSLog(@"Change");
    [tabledefaults setInteger:[notification.object selectedRow] forKey:@"currentIndex"];
    NSLog(@"%i",[tabledefaults integerForKey:@"currentIndex"]);
    [self currentLabels:[notification.object selectedRow]];
    [tabledefaults synchronize];
}

- (IBAction)deleteTimer:(id)sender {
    int index = [tabledefaults integerForKey:@"currentIndex"];
    [nameTableArray removeObjectAtIndex:index];
    [timeTableArray removeObjectAtIndex:index];
    //-----------------------------------BUG REPORT ------------------------------------
    [[NSUbiquitousKeyValueStore defaultStore]setArray:nameTableArray forKey:@"nameArray"]; //Does not set on macOS 10.12 but will work on 10.11 also does not save locally os 10.12 (works on iOS 10)
    [[NSUbiquitousKeyValueStore defaultStore]setArray:timeTableArray forKey:@"timeArray"]; //Does not set on macOS 10.12 but will work on 10.11 Also does not save locally os 10.12 (works on iOS 10)
    
    /** However this works perfectly fine when using OS X 10.11 and below and if an iPhone changes the data these will be kept up to date but macOS 10.12 will not save changes to iCloud.
     **/
    
    //---------------------------------END BUG REPORT------------------------------------
    nameTableArray = [[[NSUbiquitousKeyValueStore defaultStore]arrayForKey:@"nameArray"]mutableCopy];
    NSLog(@"nameTableCount = %i",nameTableArray.count);
    if(nameTableArray.count == 1){
        [tabledefaults setInteger:0 forKey:@"currentIndex"];
    }
    else{
        [tabledefaults setInteger:nameTableArray.count - 1 forKey:@"currentIndex"];
    }
    //----------Notifications----------------------//
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    NSMutableArray *notificationFire = [[NSMutableArray alloc]init];
    NSDate *fireDate;
    NSUserNotification *localNotification = [[NSUserNotification alloc]init];
    [dateFormatter setDateFormat:@"MM-dd-yyyy hh:mm:ss a"];
    for (int i = 0; i < timeTableArray.count; i++) {
        fireDate = [dateFormatter dateFromString:timeTableArray[i]];
        [notificationFire addObject:fireDate];
    }
    for (int d = 0; d < timeTableArray.count; d++) {
        if([notificationFire[d]compare:[NSDate date]] == NSOrderedAscending){
            NSLog(@"Older than the date now... Will not fire...");
        }
        else{
            
            localNotification.deliveryDate = notificationFire[d];
            localNotification.informativeText = [NSString stringWithFormat:@"The Timer %@ Has No Time Left!",nameTableArray[d]];
            localNotification.actionButtonTitle = @"Okay";
            localNotification.title = @"uTime";
            localNotification.soundName = NSUserNotificationDefaultSoundName;
            //[[[NSApplication sharedApplication]dockTile]setBadgeLabel:@"1"];
            //localNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication]applicationIconBadgeNumber] + 1;
            [[NSUserNotificationCenter defaultUserNotificationCenter]scheduleNotification:localNotification];
            
        }
    }
    
    [tabledefaults synchronize];
    [_tableView reloadData];
}
-(void)currentLabels:(NSInteger *)row{
    NSDateFormatter *dateFormatter1 = [[NSDateFormatter alloc]init];
    NSDateFormatter *dateFormatter2 = [[NSDateFormatter alloc]init];
    [dateFormatter2 setDateFormat:@"MM-dd-yyyy hh:mm:ss a"];
    [dateFormatter1 setDateFormat:@"EEEE, MMM dd yyyy hh:mm:ss a"];
    
    [_currentSelection setStringValue:[NSString stringWithFormat:@"Selected: %@ (%@)",[nameTableArray objectAtIndex:row],[dateFormatter1 stringFromDate:[dateFormatter2 dateFromString:[timeTableArray objectAtIndex:row]]]]];

}


- (void)keyDown:(NSEvent *)theEvent
{
    
    unichar key = [[theEvent charactersIgnoringModifiers] characterAtIndex:0];
    if(key == NSDeleteCharacter)
    {
        
        NSLog(@"Delete Button Hit");
        
        int numRows = [_tableView numberOfRows] - 1;  // I don't remember if I need to take away 1 or not.
        int i = 0;
        NSMutableArray *removal = [NSMutableArray alloc];
        while(i < numRows)
        {
            if ([_tableView isRowSelected: i]){
                NSLog(@"add onject NOW");
                //[removal addObject:timeTableArray[i]];
                NSLog(@"Added object to removal");
            }
             i+=1;
        }
        NSLog(@"Time table before removal %i",[timeTableArray count]);
        //[timeTableArray removeObjectsInArray:removal];
        NSLog(@"Time Table After Removal %i",[timeTableArray count]);
        
        //[_tableView reloadData];
        return;
        
        }

    

    
    
    
    
    [super keyDown:theEvent];
    
}
- (IBAction)closeTable:(id)sender {
    [self dismissController:self];
}
@end
