//
//  MiniBrowserWindowController.h
//  MiniBrowser
//
//  Created by Horky Chen on 4/1/13.
//  Copyright (c) 2013 Horky Chen. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

@interface MiniBrowserWindowController : NSWindowController<NSToolbarDelegate, NSTextFieldDelegate>
{
    IBOutlet NSToolbar *toolbar;
    WebView *webView;
}

@property (nonatomic,readonly) WebView * webView;
@property (nonatomic) NSInteger currentUserAgent;

-(void)updateTitleAndURL:(NSString *)title withURL:(NSString *)url;
-(void)handleStartingWithConfirmedURL:(NSString *)url;
-(void)finishedFrameLoading;

-(void)updateProgress:(int)completedCount withTotalCount:(int)totalCount withErrorCount:(int)errorCount;
-(void)handleErrorInformation:(NSError *)error;

-(void)showWebInspectorWithParameter:(BOOL)console;

-(void)forceReload;
@end
