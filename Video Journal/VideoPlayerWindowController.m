//
//  WindowController.m
//  SBPlayerClient
//
//  Created by sycf_ios on 2017/1/12.
//  Copyright © 2017年 sycf_ios. All rights reserved.
//

#import "VideoPlayerWindowController.h"
#import "VideoController.h"
#import "ScreenCap-swift.h"

@interface VideoPlayerWindowController ()<NSWindowDelegate>

@end

@implementation VideoPlayerWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    //设置titlebar
    self.window.titlebarAppearsTransparent = YES;
    self.window.titleVisibility = NSWindowTitleHidden;
    self.window.styleMask = NSWindowStyleMaskFullSizeContentView|NSWindowStyleMaskTitled|NSWindowStyleMaskResizable|NSWindowStyleMaskMiniaturizable|NSWindowStyleMaskClosable;
    self.window.movableByWindowBackground = YES;
    //设置窗口初始化大小
    self.window.delegate = self;
    [self.window setFrame:NSMakeRect(0, 0, 800, 600) display:YES];
    [self.window center];
}
-(void)windowDidEnterFullScreen:(NSNotification *)notification{
//     NSLog(@"windowFrame:%@,%@",NSStringFromRect([NSScreen mainScreen].frame),NSStringFromRect([NSScreen mainScreen].visibleFrame));
}
@end
