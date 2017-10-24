//
//  CookieController.m
//  ScreenCap
//
//  Created by Patrick Aubin on 10/3/17.
//  Copyright © 2017 Patrick Aubin. All rights reserved.
//

#import "CookieController.h"

@implementation CookieController

+ (void)saveCookies {
    NSData *cookiesData = [NSKeyedArchiver archivedDataWithRootObject: [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject: cookiesData forKey: @"sessionCookies"];
    [defaults synchronize];
}

+ (void)loadCookies {
    NSArray *cookies = [NSKeyedUnarchiver unarchiveObjectWithData: [[NSUserDefaults standardUserDefaults] objectForKey: @"sessionCookies"]];
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    
    for (NSHTTPCookie *cookie in cookies){
        [cookieStorage setCookie: cookie];
    }
}

+ (void)clearAllCookies {
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *each in cookieStorage.cookies) {
        [cookieStorage deleteCookie:each];
    }
}

+ (BOOL)isLoggedIn {
    NSArray<NSHTTPCookie *> *cookies = NSHTTPCookieStorage.sharedHTTPCookieStorage.cookies;
    cookies = [cookies filteredArrayUsingPredicate: [NSPredicate predicateWithFormat: @"name == %@", @"PHPSESSID"]];
    return cookies.count > 0;
}

@end
