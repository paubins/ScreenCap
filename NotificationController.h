//
//  NotificationController.h
//  ScreenCap
//
//  Created by Patrick Aubin on 10/4/17.
//  Copyright © 2017 Patrick Aubin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

@class AppDelegate;

@interface NotificationController : NSObject

+ (void)notificationMessage:(NSString *)message informative:(NSString *)informativeText isSuccess:(BOOL)success;

@end
