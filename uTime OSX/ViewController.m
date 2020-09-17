//
//  ViewController.m
//  uTime OSX
//
//  Created by Matthew Jagiela on 7/13/16.
//  Copyright © 2016 Matthew Jagiela. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController
int *currentIndex;
NSString *countdownTime;
NSUserDefaults *defaults;
NSMutableArray *nameArray;
NSMutableArray *timeArray;
NSMutableArray *filteredTimers;
BOOL isFiltered;
NSString *oldTimer;
NSInteger days;
NSInteger months;
NSInteger years;
NSInteger hours;
NSInteger minutes;
NSInteger seconds;


-(void)notificationSetUp{
    //NSArray *nameArray = [[NSUbiquitousKeyValueStore defaultStore]arrayForKey:@"nameArray"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"MM-dd-yyy hh:mm:ss a"];
    //NSArray *timeArray = [[NSUbiquitousKeyValueStore defaultStore]arrayForKey:@"timeArray"];
    NSDate *notificationDate;
    NSUserNotification *localNotification = [[NSUserNotification alloc]init];

    for (int i = 0; i < nameArray.count; i++) {
        notificationDate = [dateFormatter dateFromString:timeArray[i]];
        //NSLog(@"called");
        localNotification.deliveryDate = notificationDate;
        localNotification.informativeText = [NSString stringWithFormat:@"The Timer %@ Has No Time Left!",nameArray[i]];
        localNotification.actionButtonTitle = @"Okay";
        localNotification.title = @"uTime";
        localNotification.soundName = NSUserNotificationDefaultSoundName;
        //NSLog(@"Scheduled");
        if([localNotification.deliveryDate compare:[NSDate date]] ==NSOrderedAscending){
            //NSLog(@"Will not fire... Date is less than real date.");
        }
        else{
            [[[NSApplication sharedApplication]dockTile]setBadgeLabel:@"1"];
            [[NSUserNotificationCenter defaultUserNotificationCenter]scheduleNotification:localNotification];
        }
        
    }
    
    [defaults setBool:YES forKey:@"notificationSetup"];
}
-(void)searchArray:(NSString *)searchString{
    for(int i = 0; i < nameArray.count;i++){
        if([timeArray[i] isEqualToString:searchString]){
            //NSLog(@"found the object at index I = %i",i);
            [defaults setInteger:i forKey:@"currentIndex"];
        }
    }
    [self getCountdownDate];
}
-(void)firstTimeSetup{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM-dd-yyyy hh:mm:ss a"];
    countdownTime = [dateFormatter stringFromDate:[NSDate date]];
    //_timeToCountLabel.text = [NSString stringWithFormat:@"Counting Down To: %@", countdownTime];
    timeArray = [[NSMutableArray alloc]init];
    nameArray = [[NSMutableArray alloc]init];
    [timeArray addObject:countdownTime];
    [nameArray addObject:@"New OS X Timer"];
    [[NSUbiquitousKeyValueStore defaultStore]setArray:nameArray forKey:@"nameArray"];
    [[NSUbiquitousKeyValueStore defaultStore]setArray:timeArray forKey:@"timeArray"];
    [[NSUbiquitousKeyValueStore defaultStore]setBool:TRUE forKey:@"firstSetup"];
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    NSAlert *deprecationAlert = [[NSAlert alloc]init];
    [deprecationAlert setInformativeText: @"This version of uTime will no longer sync with iOS. To Continue syncing please download uTime 5 on the Mac App Store (Requiring macOS 10.15 or higher)."];
    [deprecationAlert setAlertStyle:NSWarningAlertStyle];
    [deprecationAlert setMessageText: @"uTime Sync Warning!"];
    [deprecationAlert runModal];

    isFiltered = false;
    self.searchBar.delegate = self;
    filteredTimers = [[NSMutableArray alloc]init];
    [_touchbarDelete setHidden:YES];
    
    /**TABLE SET UP**/
    
    [_tableView setDataSource:self];
    [_tableView setDelegate:self];
    _tableView.rowHeight = 62;
    //------------END TABLE----------------//
    
    
    defaults = [[NSUserDefaults alloc]initWithSuiteName:@"group.com.uapps.utime"];
    // Do any additional setup after loading the view.
    if(![[NSUbiquitousKeyValueStore defaultStore]boolForKey:@"firstSetup"]){
        //[_datePicker setHidden:NO];
        
        //[self cleariCloud];
        [self firstTimeSetup];
    }
    else{
        nameArray = [[[NSUbiquitousKeyValueStore defaultStore]arrayForKey:@"nameArray"]mutableCopy];
        timeArray = [[[NSUbiquitousKeyValueStore defaultStore]arrayForKey:@"timeArray"]mutableCopy];
    }
    if(![defaults boolForKey:@"notificationSetup"]){
        [self notificationSetUp];
    }
    
    
    //VERSION 3.0 iOS: Removed Date Sorting So....
    
    ////NSLog(@"Version %d",NSAppKitVersionNumber);
    /**if(NSAppKitVersionNumber > 10.12){
        //NSLog(@"Unsupported");
        NSAlert *alert = [[NSAlert alloc] init];
        
        [alert setMessageText:@"Your Operating System is Beta and is not supported. iCloud syncing will not work."];
        [alert addButtonWithTitle:@"OK"];
        [alert runModal];

    }
    **/
    //NSLog(@"View Did Load");
    NSUbiquitousKeyValueStore *store = [NSUbiquitousKeyValueStore defaultStore];
    currentIndex = [defaults integerForKey:@"currentIndex"];
    //currentIndex = 0;
    /**if(currentIndex > nameArray.count - 1){
        //NSLog(@"The current index is higher than it should be... Fixing");
        currentIndex = nameArray.count -1;
        //[defaults setInteger:currentIndex forKey:@"currentIndex"];
    }
     **/
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(storeDidChange:)
                                                 name:NSUbiquitousKeyValueStoreDidChangeExternallyNotification
                                               object:store];
    
    //currentIndex = [defaults integerForKey:@"currentIndex"];
   /** NSDateFormatter *dateFormatter2 = [[NSDateFormatter alloc]init];
    [dateFormatter2 setDateFormat:@"MM-dd-yyyy hh:mm:ss a"];
    [_datePicker setDateValue:[dateFormatter2 dateFromString:[timeArray objectAtIndex:currentIndex]]];
    [_namePicker setStringValue:[nameArray objectAtIndex:currentIndex]];
    
    //NSLog(@"%i",currentIndex);
    if(currentIndex == nil){ //for starting the app only!
        currentIndex = 0;
        //NSLog(@"currentIndex == nil");
    }

    [_changeCurrentNameLabel setHidden:YES];
    [_changeCurrentTimeLabel setHidden:YES];
    [_doneChangingButton setHidden:YES];
    [_datePicker setHidden:YES];
    [_namePicker setHidden:YES];
    **/
    [self updateCurrentTimeLabel];
    [self getCountdownDate];
    [self countToLabel];
    [self timers];//should be last on the method calls
    //[self goodbyetoeverybody];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(changeme:)
                                                 name:NSUserDefaultsDidChangeNotification
                                               object:nil];
    /**------------SNOW---------------**/
    /**
    SnowScene *scene = [SnowScene sceneWithSize:_blurEffect.frame.size];
    scene.scaleMode = SKSceneScaleModeAspectFill;
     //Debugging for FPS snowfall...
    [scene setBackgroundColor:[SKColor clearColor]];
    //[_ParticleBackground back]
    [_particleBackground presentScene:scene];
     **/
    
    
    
    
    //_deleteView.se
    //[_deleteView setFrameOrigin:NSMakePoint(NSMidY(_blurEffect.frame),NSMidX(_blurEffect.frame))];
    [_deleteView setHidden:YES];
     
    if([[NSUbiquitousKeyValueStore defaultStore]boolForKey:@"sortDate"]){
        [self sortArray];
    }
    //OBSERVER FOR DATE SORTING
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadTable:)
                                                 name:@"sortDate"
                                               object:nil];
    
}
- (void)reloadTable:(NSNotification *)notif {
    NSLog(@"Reload Table from Notification...");
    if([[NSUbiquitousKeyValueStore defaultStore]boolForKey:@"sortDate"]){
        [self sortArray];
    }
    [self.tableView reloadData];
}
-(void)changeStore{
    
    [self getCountdownDate];
    [self countToLabel];
    [self updateCurrentTimeLabel];
    
}
//Used to check the system theme...
-(void)checkTheme{
    NSWindow *window = [[self view]window];
    
    NSString *osxMode = [[NSUserDefaults standardUserDefaults] stringForKey:@"AppleInterfaceStyle"];
    if(osxMode == nil){ //Light Theme
        //NSLog(@"nil");
        [_blurEffect setMaterial:NSVisualEffectMaterialLight];
        [_blurEffect setAppearance:[NSAppearance appearanceNamed:NSAppearanceNameVibrantLight]]; //Used for buttons
        [_countdownLabel setTextColor:[NSColor blackColor]];
        [_currentTimeLabel setTextColor:[NSColor blackColor]];
        [_countdownToLabel setTextColor:[NSColor blackColor]];
        [_welcomeLabel setTextColor:[NSColor blackColor]];
        //[_tableView setBackgroundColor:[NSColor whiteColor]];
        [_addTimerButton setNeedsDisplay];
        [_blurEffect setNeedsLayout:YES];
        [window setViewsNeedDisplay:YES];
        [_addTimerButton setButtonType:NSMomentaryLightButton];
        
       // [_addTimerButton set
    }
    else{
       // NSLog(@"!nil");
        [_blurEffect setMaterial:NSVisualEffectMaterialUltraDark];
        [_blurEffect setAppearance:[NSAppearance appearanceNamed:NSAppearanceNameVibrantDark]];
        //[_blurEffect setMaterial:NSVisualEffectMaterialUltraDark];
        [_countdownToLabel setTextColor:[NSColor whiteColor]];
        [_countdownLabel setTextColor:[NSColor whiteColor]];
        [_currentTimeLabel setTextColor:[NSColor whiteColor]];
        [_welcomeLabel setTextColor:[NSColor whiteColor]];
        //[_tableView setBackgroundColor:[NSColor blackColor]];
    }

}
- (void)storeDidChange:(NSNotification *)notification{
    NSArray *notificationArray = [[NSUserNotificationCenter defaultUserNotificationCenter]scheduledNotifications];
    nameArray = [[NSUbiquitousKeyValueStore defaultStore]arrayForKey:@"nameArray"];
    timeArray = [[NSUbiquitousKeyValueStore defaultStore]arrayForKey:@"timeArray"];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
    [dateFormat setDateFormat:@"MM-dd-yyyy hh:mm:ss a"];
    
    for (int i = 0; i < notificationArray.count; i++) {
        NSUserNotification *note = [notificationArray objectAtIndex:i];
        [[NSUserNotificationCenter defaultUserNotificationCenter]removeScheduledNotification:note];
    }
    for (int d = 0; d < nameArray.count; d++){
        NSUserNotification *localNotification = [[NSUserNotification alloc]init];
        localNotification.deliveryDate = [dateFormat dateFromString:[timeArray objectAtIndex:d]];
        if([localNotification.deliveryDate compare:[NSDate date]]==NSOrderedAscending){
            //NSLog(@"Older do not fire");
        }
        else{
            localNotification.informativeText = [NSString stringWithFormat:@"The Timer %@ Has No Time Left!",[nameArray objectAtIndex:d]];
            localNotification.title = @"uTime";
            localNotification.soundName = NSUserNotificationDefaultSoundName;
            [[NSUserNotificationCenter defaultUserNotificationCenter]scheduleNotification:localNotification];
        }
        
    }
   //if([notificationFire[d]compare:[NSDate date]] == NSOrderedAscending
    
    
    /**if(!notificationExists){ //false add it to the fire...
        //NSLog(@"The Notification doesn't exist.");
        NSUserNotification *localNotification = [[NSUserNotification alloc]init];
        localNotification.deliveryDate = [dateFormat dateFromString:[dateArray objectAtIndex:currentIndex]];
        localNotification.informativeText = [NSString stringWithFormat:@"The Timer %@ Has No Time Left!",[nameArray objectAtIndex:currentIndex]];
        localNotification.title = @"uTime";
        localNotification.soundName = NSUserNotificationDefaultSoundName;
        //localNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication]applicationIconBadgeNumber]+1;
        [[NSUserNotificationCenter defaultUserNotificationCenter]scheduleNotification:localNotification];
    }
    
    //NSLog(@"The new notification count is %i",notificationArray.count);
     **/
    if([[NSUbiquitousKeyValueStore defaultStore]boolForKey:@"sortDate"]){
        [self sortArray];
    }
    
    NSLog(@"didChange");
   // [self rescheduleNotification];
    [self getCountdownDate];
    [_tableView reloadData];
}
-(void)changeme:(NSNotification *)notification{
   NSLog(@"changeme");
    [self getCountdownDate];
    [self countToLabel];
    [self countToLabel];
    nameArray = [[[NSUbiquitousKeyValueStore defaultStore]arrayForKey:@"nameArray"]mutableCopy];
    timeArray = [[[NSUbiquitousKeyValueStore defaultStore]arrayForKey:@"timeArray"]mutableCopy];
    currentIndex = [defaults integerForKey:@"currentIndex"];

    [self.tableView reloadData];
    //[self sortArray];
    if([[NSUbiquitousKeyValueStore defaultStore]boolForKey:@"sortDate"]){
        [self sortArray];
    }

}
-(void)getCountdownDate{
    NSMutableArray *array = [[NSUbiquitousKeyValueStore defaultStore]arrayForKey:@"timeArray"];
    NSUserDefaults *myDefaults = [[NSUserDefaults alloc]initWithSuiteName:@"group.com.uapps.utime"];
    //NSLog(@"CURRENT INDEX MAIN = %i",currentIndex);
    //int *testingArray = [myDefaults integerForKey:@"currentIndex"];
    if(array.count <= currentIndex){
        //NSLog(@"array management called");
        currentIndex = array.count - 1;
        [myDefaults setInteger:currentIndex forKey:@"currentIndex"];
        currentIndex = [myDefaults integerForKey:@"currentIndex"];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        [myDefaults synchronize];
        
    }
    [self countToLabel];
    //////NSLog(@"Current index %i, array count = %i, and the stored default is %i",currentIndex,array.count,[myDefaults integerForKey:@"currentIndex"]);
    countdownTime = [array objectAtIndex:currentIndex];
}
-(void)timers{ //handle the timer for the current time and the countdown time
    NSTimer *currentTime = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateCurrentTimeLabel) userInfo:nil repeats:YES]; //keeps track of the local time every second
    
    NSTimer *countdownTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countDown) userInfo:nil repeats:YES];
    
    NSTimer *countDownLabel = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countToLabel) userInfo:nil repeats:YES];
    NSTimer *themeCheck = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(checkTheme) userInfo:nil repeats:YES];
    NSTimer *subCheck = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(subRecursion) userInfo:nil repeats:YES];
}
-(void)updateCurrentTimeLabel{
    NSDateFormatter *dateFormatter1 = [[NSDateFormatter alloc]init];
    [dateFormatter1 setDateFormat:@"EEEE, MMMM dd yyyy hh:mm:ss a"];
    [_currentTimeLabel setStringValue:[NSString stringWithFormat:@"It Is Currently: %@",[dateFormatter1 stringFromDate:[NSDate date]]]];
}
-(void)viewDidAppear{ //Use this to configure if the view is going to be dark or light...
    
    //NSLog(@"Appear...");
    NSArray *nameArray = [[NSUbiquitousKeyValueStore defaultStore]arrayForKey:@"nameArray"];
    if([defaults integerForKey:@"currentIndex"] > nameArray.count - 1){
        [defaults setInteger:nameArray.count - 1 forKey:@"currentIndex"];
    }
    [self checkTheme];
}
- (void)countToLabel{
    ////NSLog(@"countToLabel");
    ////NSLog(@"currentindex = %i",currentIndex);
    
    //NSLog(@"COUNT TO LABEL INDEX = %i",currentIndex);
    
   // //NSLog(@"Current Object in Name Array %@",[nameArray objectAtIndex:currentIndex]);
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM-dd-yyyy hh:mm:ss a"];
    NSDateFormatter *dateFormatter2 = [[NSDateFormatter alloc]init];
    [dateFormatter2 setDateFormat:@"EEEE, MMMM dd yyyy hh:mm:ss a"];
    
   // [_countdownToLabel setHidden:YES];
    
    
    
    NSString *countDownString = [NSString stringWithFormat:@"Counting Down To:\n %@ (%@)",[nameArray objectAtIndex:currentIndex],[dateFormatter2 stringFromDate:[dateFormatter dateFromString:[timeArray objectAtIndex:currentIndex]]]];
    NSString *touchBarString = [NSString stringWithFormat:@"%@ (%@)",[nameArray objectAtIndex:currentIndex],[dateFormatter2 stringFromDate:[dateFormatter dateFromString:[timeArray objectAtIndex:currentIndex]]]];
    [_touchLabel setStringValue:touchBarString];
    ////NSLog(@"Count Down String = %@",countDownString);
    //[[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
    [_countdownToLabel setStringValue:countDownString];
    //countdownTime = [timeToCount objectAtIndex:currentIndex];
    //[_countdownToLabel displayIfNeeded];
    //[_countdownToLabel displayIfNeeded];
    
    ////NSLog(@"Count to label \n Current Name: %@ \n Current Time: %@",[nameArray objectAtIndex:currentIndex],[timeToCount objectAtIndex:currentIndex]);
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
    
    
}

- (IBAction)addTimer:(id)sender {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM-dd-yyyy hh:mm:ss a"];
    NSString *countdownTime = [dateFormatter stringFromDate:[NSDate date]];
    [nameArray addObject:@"New macOS Timer"];
    [timeArray addObject:countdownTime];
    [[NSUbiquitousKeyValueStore defaultStore]setArray:nameArray forKey:@"nameArray"];
    [[NSUbiquitousKeyValueStore defaultStore]setArray:timeArray forKey:@"timeArray"];
   /** if([[NSUbiquitousKeyValueStore defaultStore]boolForKey:@"sortDate"]){
        [self sortArray];
        [self searchArray:countdownTime];
    }
    else [defaults setInteger:nameArray.count - 1 forKey:@"currentIndex"];
    **/
    [defaults setInteger:nameArray.count  -1 forKey:@"currentIndex"];
    currentIndex = nameArray.count - 1;
    //NSLog(@"The current index in the default store is");
    
    
    [[NSUbiquitousKeyValueStore defaultStore]synchronize];
    [_tableView reloadData];
    //[self performSegueWithIdentifier:@"memes" sender:self];
    [self countToLabel];
    [self getCountdownDate];
    [self countDown];
    [self saveCurrentIndex];
    [self setOldDate:countdownTime];
    //[self performSelector:@selector(segueTell) withObject:nil afterDelay:1];
    [self performSegueWithIdentifier:@"memes" sender:self];
    
}
-(void)segueTell{
    [self performSegueWithIdentifier:@"memes" sender:self];
}

- (IBAction)doneChanging:(id)sender {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM-dd-yyyy hh:mm:ss a"];
    //[timeArray replaceObjectAtIndex:currentIndex withObject:[dateFormatter stringFromDate:[_datePicker dateValue]]];
    [[NSUbiquitousKeyValueStore defaultStore]setArray:nameArray forKey:@"nameArray"];
    [[NSUbiquitousKeyValueStore defaultStore]setArray:timeArray forKey:@"timeArray"];
    [_changeCurrentNameLabel setHidden:YES];
    [_changeCurrentTimeLabel setHidden:YES];
    [_doneChangingButton setHidden:YES];
    [_datePicker setHidden:YES];
    [_namePicker setHidden:YES];
    [self rescheduleNotification];
    [self updateCurrentTimeLabel];
    [self getCountdownDate];
}
-(void)rescheduleNotification{
    NSArray *notificationArray = [[NSUserNotificationCenter defaultUserNotificationCenter]scheduledNotifications];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
    [dateFormat setDateFormat:@"MM-dd-yyyy hh:mm:ss a"];
    
    for (int i = 0; i < notificationArray.count; i++) {
        NSUserNotification *note = [notificationArray objectAtIndex:i];
        [[NSUserNotificationCenter defaultUserNotificationCenter]removeScheduledNotification:note];
    }
    for (int d = 0; d < nameArray.count; d++){
        NSUserNotification *localNotification = [[NSUserNotification alloc]init];
        localNotification.deliveryDate = [dateFormat dateFromString:[timeArray objectAtIndex:d]];
        if([localNotification.deliveryDate compare:[NSDate date]]==NSOrderedAscending){
            //NSLog(@"Older do not fire");
        }
        else{
            localNotification.informativeText = [NSString stringWithFormat:@"The Timer %@ Has No Time Left!",[nameArray objectAtIndex:d]];
            localNotification.title = @"uTime";
            localNotification.soundName = NSUserNotificationDefaultSoundName;
            [[NSUserNotificationCenter defaultUserNotificationCenter]scheduleNotification:localNotification];
        }
        
    }
}
-(NSString *)countDown{
    [_deleteView setHidden:YES];
    [_touchbarDelete setHidden:YES];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"MM-dd-yyyy hh:mm:ss a"];
    NSDate *testDate = [dateFormatter dateFromString:countdownTime];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit;
    NSDateComponents *dateComponents = [calendar components:unitFlags fromDate:[NSDate date]     toDate:testDate options:0]; //to date is always for the future date
    
    days     = [dateComponents day];
    months   = [dateComponents month];
    years    = [dateComponents year];
    hours    = [dateComponents hour];
    minutes  = [dateComponents minute];
    seconds  = [dateComponents second];
    NSString *countdownText;
    NSString *returnText;
    //countdownText= [NSString stringWithFormat:@"%d Years %d Months %d Days %d Hours %d Minutes %d Seconds", years, months, days, hours, minutes, seconds];
    if(years > 1){ //Years included
        countdownText = [NSString stringWithFormat:@"Time Left:\n %d %@ %d %@ %d %@ %d %@ %d %@ %d %@",years,[self yearsText:years],months,[self monthsText:months],days,[self daysText:days],hours,[self hoursText:hours],minutes,[self minutesText:minutes],seconds,[self secondsText:seconds]];
        //return
        returnText = [NSString stringWithFormat:@"Time Left: %d %@ %d %@ %d %@ %d %@ %d %@ %d %@",years,[self yearsText:years],months,[self monthsText:months],days,[self daysText:days],hours,[self hoursText:hours],minutes,[self minutesText:minutes],seconds,[self secondsText:seconds]];
    }
    if(years == 0){ //Months
        countdownText = [NSString stringWithFormat:@"Time Left:\n %d %@ %d %@ %d %@ %d %@ %d %@",months,[self monthsText:months],days,[self daysText:days],hours,[self hoursText:hours],minutes,[self minutesText:minutes],seconds,[self secondsText:seconds]];
        returnText = [NSString stringWithFormat:@"Time Left: %d %@ %d %@ %d %@ %d %@ %d %@",months,[self monthsText:months],days,[self daysText:days],hours,[self hoursText:hours],minutes,[self minutesText:minutes],seconds,[self secondsText:seconds]];
    }
    if(years == 0 && months == 0){ //Days
        countdownText = [NSString stringWithFormat:@"Time Left:\n %d %@ %d %@ %d %@ %d %@",days,[self daysText:days],hours,[self hoursText:hours],minutes,[self minutesText:minutes],seconds,[self secondsText:seconds]];
        returnText =[NSString stringWithFormat:@"Time Left: %d %@ %d %@ %d %@ %d %@",days,[self daysText:days],hours,[self hoursText:hours],minutes,[self minutesText:minutes],seconds,[self secondsText:seconds]];
        
    }
    if(years == 0 && months == 0 && days == 0){ //Hours
        
        countdownText = [NSString stringWithFormat:@"Time Left:\n %d %@ %d %@ %d %@",hours,[self hoursText:hours],minutes,[self minutesText:minutes],seconds,[self secondsText:seconds]];
        returnText = [NSString stringWithFormat:@"Time Left: %d %@ %d %@ %d %@",hours,[self hoursText:hours],minutes,[self minutesText:minutes],seconds,[self secondsText:seconds]];
    }
    if(years == 0 && months == 0 && days == 0 && hours == 0){ // Minutes
        countdownText = [NSString stringWithFormat:@"Time Left:\n %d %@ %d %@",minutes,[self minutesText:minutes],seconds,[self secondsText:seconds]];
        returnText = [NSString stringWithFormat:@"Time Left: %d %@ %d %@",minutes,[self minutesText:minutes],seconds,[self secondsText:seconds]];
    }
    if(years == 0 && months == 0 && days == 0 && hours == 0 && minutes == 0){
        countdownText = [NSString stringWithFormat:@"Time Left:\n %d %@",seconds,[self secondsText:seconds]];
        returnText = [NSString stringWithFormat:@"Time Left: %d %@",seconds,[self secondsText:seconds]];
    }
    if (years == 0 && months == 0 && days == 0 && minutes == 0 && seconds == 0){
        countdownText = @"Time's up";
        returnText = @"";
    }
    //[[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
    ////NSLog(@"CountDown Called");
    ////NSLog(@"Countdown text = %@",countdownText);
    [_countdownLabel setStringValue:countdownText];
    return returnText;
}
- (NSString *)yearsText:(NSInteger)years{
    if(years == 1 || years == -1)return @"Year";
    else return @"Years";
}
-(NSString *)monthsText:(NSInteger *)months{
    if(months == 1 || months == -1) return @"Month";
    else return @"Months";
}
-(NSString *)daysText:(NSInteger *)days{
    if(days == 1 || days == -1)return @"Day";
    else return @"Days";
}
-(NSString *)hoursText:(NSInteger *)hours{
    if(hours == 1 || hours == -1)return @"Hour";
    else return @"Hours";
}
-(NSString *)minutesText:(NSInteger *)minutes{
    if(minutes == 1 || minutes == -1)return@"Minute";
    else return @"Minutes";
}
-(NSString *)secondsText:(NSInteger *)seconds{
    if(seconds == 1 || seconds == -1)return @"Second";
    else return @"Seconds";
}
- (IBAction)changeTimer:(id)sender {
    [_namePicker setHidden:NO];
    [_datePicker setHidden:NO];
    [_changeCurrentTimeLabel setHidden:NO];
    [_changeCurrentNameLabel setHidden:NO];
    [_doneChangingButton setHidden:NO];
}
- (IBAction)resizeTestAction:(id)sender {
    
    
    NSWindow *window = [[self view]window];
    NSRect frame = [window frame];
    frame.size.width -=200;
    [window setFrame:frame display:YES animate:YES];
    
}

- (IBAction)getViewSize:(id)sender {
    NSWindow *window  = [[self view]window];
    NSRect frame = [window frame];
    //NSLog(@"The width of the current frame is %f",frame.size.width);
    
}
//-----------TABLE METHODS---------------//
-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return nameArray.count;
}
-(NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    ////NSLog(@"changing the values");
    //Load Table
    NSTableCellView *cellView = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
    if(isFiltered){
        if([tableColumn.identifier isEqualToString:@"nameColumn"]){
            cellView.textField.stringValue = [nameArray objectAtIndex:row];
        }
    }
    else{
        if([tableColumn.identifier isEqualToString:@"nameColumn"]){
            cellView.textField.stringValue = [nameArray objectAtIndex:row];
        }
        else{
            NSDateFormatter *dateFormatter1 = [[NSDateFormatter alloc]init];
            NSDateFormatter *dateFormatter2 = [[NSDateFormatter alloc]init];
            [dateFormatter2 setDateFormat:@"MM-dd-yyyy hh:mm:ss a"];
            [dateFormatter1 setDateFormat:@"EE, MMM dd yyyy hh:mm:ss a"];
            NSString *mainText = [NSString stringWithFormat:@"%@:\n%@ \n%@",[nameArray objectAtIndex:row],[dateFormatter1 stringFromDate:[dateFormatter2 dateFromString:[timeArray objectAtIndex:row]]],[self calculateSubtime:row]];
            
            NSString *dateText = [dateFormatter1 stringFromDate:[dateFormatter2 dateFromString:[timeArray objectAtIndex:row]]];
            cellView.textField.stringValue = mainText;
            
        }
    }
    
    
    
    return cellView;
}
- (void)keyDown:(NSEvent *)theEvent
{
    unichar key = [[theEvent charactersIgnoringModifiers] characterAtIndex:0];
    if(key == NSDeleteCharacter)
    {
        if(nameArray.count == 1){
            NSAlert *alert = [[NSAlert alloc] init];
            [alert setMessageText:@"There is only one timer!"];
            [alert setInformativeText:@"You need to have at least one timer in the list"];
            [alert addButtonWithTitle:@"Ok"];
            [alert runModal];
        }
        else{
            NSMutableArray *deletionArray = [[NSMutableArray alloc]init];
            for (int i = 0; i < nameArray.count; i++) {
                if([_tableView isRowSelected:i]){
                    NSNumber *index = [NSNumber numberWithInteger:i];
                    [deletionArray addObject:index];
                }
            }// end for loop
            deletionArray = [[deletionArray reverseObjectEnumerator]allObjects];//Reverse the array so we can delete easier
            if(deletionArray.count != nameArray.count){ //Go Ahead with deleting the timers.
                for (int d = 0; d < deletionArray.count; d++) {
                    NSNumber *index = [deletionArray objectAtIndex:d];
                    [timeArray removeObjectAtIndex:[index integerValue]];
                    [nameArray removeObjectAtIndex:[index integerValue]];
                }
            }
            else{
                NSAlert *deleteAlert = [[NSAlert alloc]init];
                [deleteAlert setMessageText:@"All Timers Are Selected"];
                [deleteAlert setInformativeText:@"There Must Be At Least One Timer In The List"];
                [deleteAlert addButtonWithTitle:@"Okay"];
                [deleteAlert runModal];
            }
            [[NSUbiquitousKeyValueStore defaultStore]setArray:nameArray forKey:@"nameArray"];
            [[NSUbiquitousKeyValueStore defaultStore]setArray:timeArray forKey:@"timeArray"];

            
            if(currentIndex > nameArray.count - 1){
                currentIndex = nameArray.count -1;
            }
            
            [_tableView reloadData];
            [self getCountdownDate];
            NSTimer *deleteTimer =  [NSTimer timerWithTimeInterval:1 target:self selector:@selector(null) userInfo:nil repeats:NO];
            if([deleteTimer isValid]){
                
                [_deleteView setHidden:NO];
                [_touchbarDelete setHidden:NO];
            }
            else{
                //NSLog(@"invalid timer");
                [_deleteView setHidden:YES];
                [_touchbarDelete setHidden:YES];
            }
            
            NSRect f;
            f.size.width  = 100;
            f.size.height = 100;
            [_deleteView setFrame:f];
            //  _part
            //_blurE
            /**[_deleteView setFrameOrigin:NSMakePoint(
                                                    (NSWidth([_ParticleBackground bounds]) - NSWidth([_deleteView frame])) / 2,
                                                    (NSHeight([_ParticleBackground bounds]) - NSHeight([_deleteView frame])) / 2
                                                    )];
             **/

        }
        [self rescheduleNotification];
        //[_touchLabel setStringValue:@"Timer Deleted"];
        
        return;
        
    }
    [super keyDown:theEvent];
    
}
-(IBAction)deleteTouchBar:(id)sender{

    if(nameArray.count == 1){
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"There Is Only One Timer"];
        [alert setInformativeText:@"There Must Be At Least One Timer In The List"];
        [alert addButtonWithTitle:@"Okay"];
        [alert runModal];
    }
    else{
        NSMutableArray *deletionArray = [[NSMutableArray alloc]init];
        for (int i = 0; i < nameArray.count; i++) {
            if([_tableView isRowSelected:i]){
                NSNumber *index = [NSNumber numberWithInteger:i];
                [deletionArray addObject:index];
            }
        }// end for loop
        deletionArray = [[deletionArray reverseObjectEnumerator]allObjects];//Reverse the array so we can delete easier
        if(deletionArray.count != nameArray.count){ //Go Ahead with deleting the timers.
            for (int d = 0; d < deletionArray.count; d++) {
                NSNumber *index = [deletionArray objectAtIndex:d];
                [timeArray removeObjectAtIndex:[index integerValue]];
                [nameArray removeObjectAtIndex:[index integerValue]];
            }
        }
        else{
            NSAlert *deleteAlert = [[NSAlert alloc]init];
            [deleteAlert setMessageText:@"All Timers Are Selected"];
            [deleteAlert setInformativeText:@"There Must Be At Least One Timer In The List"];
            [deleteAlert addButtonWithTitle:@"Okay"];
            [deleteAlert runModal];
        }
        [[NSUbiquitousKeyValueStore defaultStore]setArray:nameArray forKey:@"nameArray"];
        [[NSUbiquitousKeyValueStore defaultStore]setArray:timeArray forKey:@"timeArray"];
        
        if(currentIndex > nameArray.count - 1){
            currentIndex = nameArray.count -1;
        }
        
        [_tableView reloadData];
        [self getCountdownDate];
    }
    NSTimer *deleteTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(null) userInfo:nil repeats:NO];
    if([deleteTimer isValid]){
        [_deleteView setHidden:NO];
        [_touchbarDelete setHidden:NO];
    }
    else{
        [_deleteView setHidden:YES];
        [_touchbarDelete setHidden:YES];
    }
   // [_deleteView setHidden:NO];
//    NSTimer *deleteTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:nil userInfo:nil repeats:NO];
    
    
    NSRect f;
    f.size.width  = 100;
    f.size.height = 100;
    [_deleteView setFrame:f];
    //  _part
    //_blurE
    /**[_deleteView setFrameOrigin:NSMakePoint(
                                            (NSWidth([_ParticleBackground bounds]) - NSWidth([_deleteView frame])) / 2,
                                            (NSHeight([_ParticleBackground bounds]) - NSHeight([_deleteView frame])) / 2
                                            )];
     
     **/


    [self rescheduleNotification];

}
-(void)tableViewSelectionDidChange:(NSNotification *)notification{
    //NSLog(@"Change");
    /**NSUserDefaults *defaults = [[NSUserDefaults alloc]initWithSuiteName:@"group.com.uapps.utime"];
    [defaults setInteger:[notification.object selectedRow] forKey:@"currentIndex"];
    ////NSLog(@"%i",[tabledefaults integerForKey:@"currentIndex"]);
    //[self currentLabels:[notification.object selectedRow]];
     **/
    //NSLog(@"tabelViewSelectionDidChange:");
    currentIndex = [notification.object selectedRow];
    oldTimer = [timeArray objectAtIndex:currentIndex];
    [self countToLabel];
    [self getCountdownDate];
    [self countDown];
    
}
-(void)saveCurrentIndex{
    NSUserDefaults *saveDefaults = [[NSUserDefaults alloc]initWithSuiteName:@"group.com.uapps.utime"];
    //NSLog(@"SAVING %i AS THE CURRENT INDEX",currentIndex);
    [saveDefaults setInteger:currentIndex forKey:@"currentIndex"];
}
-(void)prepareForSegue:(NSStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"memes"]){
        [self saveCurrentIndex];
    }
}
-(void)sortArray{

    //NSLog(@"sort");
    NSDateFormatter *dateFormatter2 = [[NSDateFormatter alloc]init];
    [dateFormatter2 setDateFormat:@"MM-dd-yyyy hh:mm:ss a"];
    NSMutableArray *tempArray = [NSMutableArray array];
    NSMutableArray *allArrays = [NSMutableArray array];
    for (int i = 0; i < nameArray.count; i++) {
        [tempArray addObject:[dateFormatter2 dateFromString:timeArray[i]]];
    }
    for (int idx = 0; idx < nameArray.count; idx++) {
        NSDictionary *dict = @{@"Name":nameArray[idx],@"Date":timeArray[idx],@"ADate":tempArray[idx]};
        [allArrays addObject:dict];
    }
    NSSortDescriptor *sortDesc = [NSSortDescriptor sortDescriptorWithKey:@"ADate" ascending:YES selector:@selector(compare:)];
    [allArrays sortUsingDescriptors:@[sortDesc]];
    timeArray = [[allArrays valueForKey:@"Date"]mutableCopy];
    nameArray = [[allArrays valueForKey:@"Name"]mutableCopy];
    [[NSUbiquitousKeyValueStore defaultStore]setArray:timeArray forKey:@"timeArray"];
    [[NSUbiquitousKeyValueStore defaultStore]setArray:nameArray forKey:@"nameArray"];
    [_tableView reloadData];
    //[self findIndex];
    
    
}
-(void)setOldDate:(NSString *)date{
    oldTimer = date;
    [self findIndex];
}
-(void)findIndex{
    for (int i = 0; i < nameArray.count; i++) {
        if([timeArray[i]isEqualToString:oldTimer]){
            currentIndex = i;
        }
        ////NSLog(@"currentIndex = %i",currentIndex);
    }
    [self countToLabel];
    [self getCountdownDate];
    [self countDown];
    
    
}
-(void)sortArrayName{
    
    NSMutableArray *tempArray = [NSMutableArray array];
    for (int idx = 0; idx < nameArray.count; idx++) {
        NSDictionary *dict = @{@"Name":nameArray[idx],@"Date":timeArray[idx]};
        [tempArray addObject:dict];
    }
    NSSortDescriptor *sortDesctriptor = [NSSortDescriptor sortDescriptorWithKey:@"Name" ascending:YES];
    nameArray = [[tempArray valueForKey:@"Name"]mutableCopy];
    timeArray = [[tempArray valueForKey:@"Date"]mutableCopy];
    
    
    [self.tableView reloadData];
}
-(IBAction)testBar:(id)sender{
    NSMutableArray *initial = [[NSMutableArray alloc]init];
    NSMutableArray *finished = [[NSMutableArray alloc]init];
    for (int i = 0; i < nameArray.count; i++) {
        if([_tableView isRowSelected:i]){
            //NSLog(@"Selected row at index %i",i);
            NSNumber *meme = [NSNumber numberWithInteger:i];
            [initial addObject:meme];
            initial = [[initial reverseObjectEnumerator]allObjects];
        }
        
    }
    for (int d = 0; d < initial.count; d++) {
        NSNumber *kek = [initial objectAtIndex:d];
        //NSLog(@"FINISHED: %i",[kek integerValue]);
    }
}
-(NSString *)calculateSubtime:(NSInteger*)subIndex{//Pass in the current index to find the subtext
    NSString *timeSub;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"MM-dd-yyyy hh:mm:ss a"];
    NSDate *testDate = [dateFormatter dateFromString:[timeArray objectAtIndex:subIndex]];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit;
    NSDateComponents *dateComponents = [calendar components:unitFlags fromDate:[NSDate date]     toDate:testDate options:0]; //to date is always for the future date
    NSInteger daysSub     = [dateComponents day];
    NSInteger monthsSub   = [dateComponents month];
    NSInteger yearsSub    = [dateComponents year];
    NSInteger hoursSub    = [dateComponents hour];
    NSInteger minutesSub  = [dateComponents minute];
    NSInteger secondsSub  = [dateComponents second];
    
    if(yearsSub > 0){ //There is more than a year left
        timeSub = [NSString stringWithFormat:@" %i Year(s)",yearsSub];
    }
    else if(monthsSub > 0){
        timeSub = [NSString stringWithFormat:@"%i Months ",monthsSub];
    }
    else if(daysSub > 0){
        timeSub = [NSString stringWithFormat:@"%i Days",daysSub];
    }
    else if(hoursSub > 0){
        timeSub = [NSString stringWithFormat:@"%i Hours",hoursSub];
    }
    else if(minutesSub > 0){
        timeSub = [NSString stringWithFormat:@"%i Minutes",minutesSub];
    }
    else if (secondsSub > 0){
        timeSub = @"Seconds Remain!";
    }
    else{
        timeSub = @"Time's Up";
    }
    
    

    return timeSub;
}
-(void)subRecursion{ //Called every second... If the number can be divided by 5 then the index will be updated... (Unless it is hours/months/days)
    
    
    for (int i = 0; i < nameArray.count; i++) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        [dateFormatter setDateFormat:@"MM-dd-yyyy hh:mm:ss a"];
        NSDate *testDate = [dateFormatter dateFromString:[timeArray objectAtIndex:i]];
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSUInteger unitFlags = NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit;
        NSDateComponents *dateComponents = [calendar components:unitFlags fromDate:[NSDate date]     toDate:testDate options:0]; //to date is always for the future date
        NSInteger daysSub     = [dateComponents day];
        NSInteger monthsSub   = [dateComponents month];
        NSInteger yearsSub    = [dateComponents year];
        NSInteger hoursSub    = [dateComponents hour];
        NSInteger minutesSub  = [dateComponents minute];
        NSInteger secondsSub  = [dateComponents second];
        if(minutes % 5 == 0){
            [_tableView reloadData];
        }
        if(seconds == 0){
            [_tableView reloadData];
        }
        
    }
}

@end
