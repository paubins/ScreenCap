//
//  AppDelegate.h
//  SBPlayerClient
//
//  Created by sycf_ios on 2017/1/10.
//  Copyright © 2017年 sycf_ios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "VideoPlayerWindowController.h"
#import "VideoPlayerViewController.h"
#import "SBOpenURLWindowController.h"
#import "SBApplication.h"
#import "CommonHeader.h"

@interface VideoController : NSObject
    
@property (nonatomic,strong) VideoPlayerWindowController *mainWindowController;
    
//根控制器
@property (nonatomic,strong) VideoPlayerViewController *rootVC;
    
//打开Network控制器
@property (nonatomic,strong) SBOpenURLWindowController *openURLWindow;
@property (nonatomic, copy) NSString *pendingURL;
@property (nonatomic,assign) BOOL isReady;

    
@end

