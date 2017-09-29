//
//  AppDelegate.m
//  SBPlayerClient
//
//  Created by sycf_ios on 2017/1/10.
//  Copyright © 2017年 sycf_ios. All rights reserved.
//

#import "VideoController.h"
#import <CoreServices/CoreServices.h>
#import "FilterVideoType.h"

@implementation VideoController

- (id)init {
    self = [super init];
    if (self) {
        [self initHelper];
    }
    return self;
}
    
- (void)initHelper {
    
    self.rootVC = (VideoPlayerViewController *)self.mainWindowController.contentViewController;
    if (!self.rootVC.isFullScreen) {
        [self.mainWindowController.window setFrame:NSMakeRect(0, 0, 800, 600) display:YES];
    };
    [self.mainWindowController.window center];
    
    if (self.pendingURL) {
        NSArray *usefulUrlArr = [FilterVideoType filterURLs:@[_pendingURL]];
        if (usefulUrlArr.count == 1) {
            for (NSString *tmpUrl in usefulUrlArr) {
                [SBApplication share].isDoubleClickOpen = YES;
                [self.rootVC sbViewGetFileURL:[NSURL fileURLWithPath:tmpUrl]];
                _pendingURL = nil;
                break;
            }
        }
    }
}
    
//添加播放链接到数据库
- (void)addURLToDataBaseWithURL:(NSString *)urlString {
    [SBApplication share].filePaths = @[urlString];
    [self.rootVC playlistDataAddToDatabase];
}

//工具栏点击事件
#pragma mark - 文件

//打开文件
- (IBAction)openFile:(NSMenuItem *)sender {
    [self.rootVC openFile:self];
}
//打开网络链接
- (IBAction)openURL:(id)sender {
    self.openURLWindow = [[SBOpenURLWindowController alloc] initWithWindowNibName:@"SBOpenURLWindowController"];
    
    NSWindow *urlWindow = self.openURLWindow.window;
    [urlWindow center];
    [self.mainWindowController.window addChildWindow:urlWindow ordered:NSWindowAbove];
}
#pragma mark - 控制

//删除所有记录
- (IBAction)deleteAllRecords:(id)sender {
    [self.rootVC clearAll:sender];
}
//播放/暂停
- (IBAction)playOrPause:(id)sender {
    [self.rootVC play:sender];
}
//下一个视频
- (IBAction)nextVideo:(id)sender {
    [self.rootVC next:sender];
}

//皮肤
- (IBAction)setSkin:(id)sender {
    [self.rootVC handleToolBox:sender];
}
//右栏
- (IBAction)showRightView:(id)sender {
    [self.rootVC showOrHidePlaylist:sender];
}
//显示sbplayer
- (IBAction)showSBPlayer:(id)sender {
    [self.mainWindowController.window makeKeyAndOrderFront:self];
}
//跳转到帮助
- (IBAction)sbPlayerHelp:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString: @"https://shibiao.github.io"]];
}
//声音减小
- (IBAction)soundReduction:(id)sender {
    [self.rootVC volumeDown];
}
//声音大
- (IBAction)soundPlus:(id)sender {
    [self.rootVC volumeUp];
}
//后退10秒
- (IBAction)backToTenSeconds:(id)sender {
    [self.rootVC progressWithTime:-10000];
}
//前进10秒
- (IBAction)ForwardTenSeconds:(id)sender {
    [self.rootVC progressWithTime:10000];
}

@end
