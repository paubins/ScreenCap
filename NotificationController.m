//
//  NotificationController.m
//  ScreenCap
//
//  Created by Patrick Aubin on 10/4/17.
//  Copyright © 2017 Patrick Aubin. All rights reserved.
//

#import "NotificationController.h"

@implementation NotificationController

+ (void)notificationMessage:(NSString *)message informative:(NSString *)informativeText isSuccess:(BOOL)success {
    
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    NSUserNotificationCenter *notificationCenter = [NSUserNotificationCenter defaultUserNotificationCenter];
    
    AppDelegate *appDelegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    notificationCenter.delegate = appDelegate;
    notification.title = message;
    notification.informativeText = informativeText;
    
    if (success) {
        notification.contentImage = [[NSImage alloc] initWithContentsOfFile:@"success"];
    } else {
        notification.contentImage = [[NSImage alloc] initWithContentsOfFile:@"failure"];
    }
    
    notification.soundName = NSUserNotificationDefaultSoundName;
    [notificationCenter scheduleNotification:notification];
}

@end
