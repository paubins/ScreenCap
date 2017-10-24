//
//  CookieController.h
//  ScreenCap
//
//  Created by Patrick Aubin on 10/3/17.
//  Copyright © 2017 Patrick Aubin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CookieController : NSObject

+ (void)saveCookies;
+ (void)loadCookies;
+ (void)clearAllCookies;
+ (BOOL)isLoggedIn;

@end
