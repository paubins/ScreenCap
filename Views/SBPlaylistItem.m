//
//  SBPlaylistItem.m
//  SBPlayerClient
//
//  Created by sycf_ios on 2017/2/10.
//  Copyright © 2017年 sycf_ios. All rights reserved.
//

#import "SBPlaylistItem.h"
#import "Masonry.h"
#import <AFNetworking/AFNetworking.h>
#import "CookieController.h"
#import "MYProgressHUD.h"
#import "ScreenCap-Swift.h"
#import "NotificationController.h"
#import "JFImageSavePanel.h"

#define BLACKCOLOR [NSColor blackColor]
@interface SBPlaylistItem (){
    //视频资产
    URLAsset *_asset;
    //底部白线
    NSView *_whiteLine;
}
@property (nonatomic,strong) NSImageView *disableView;
@property (nonatomic, strong) NSMutableURLRequest *request;
@property (nonatomic, strong) NSTimer* timer;

@end
@implementation SBPlaylistItem
-(void)awakeFromNib{
    //添加白线
    [self addWhiteLine];
}
-(void)addWhiteLine{
    _whiteLine = [[NSView alloc]init];
    _whiteLine.wantsLayer = YES;
    _whiteLine.layer.backgroundColor = [NSColor lightGrayColor].CGColor;
    [self addSubview:_whiteLine];
    //添加白线的约束
    [self addWhiteLineConstraint];
}
-(void)addWhiteLineConstraint{
    [_whiteLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.mas_equalTo(self);
        make.height.mas_equalTo(@1);
    }];
    [_whiteLine setNeedsLayout:YES];
}
- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    [_whiteLine layoutSubtreeIfNeeded];
    self.title.usesSingleLineMode = YES;
    self.title.cell.wraps = NO;
    self.title.cell.scrollable = NO;
    self.title.maximumNumberOfLines = 1;
    NSTrackingArea *trackingArea = [[NSTrackingArea alloc]initWithRect:dirtyRect options:NSTrackingMouseEnteredAndExited|NSTrackingActiveAlways owner:self userInfo:nil];
    [self addTrackingArea:trackingArea];
    //设置删除按钮
    self.closeBtn.hidden = YES;
    self.closeBtn.target = self;
    self.closeBtn.action = @selector(removeCurrentItem:);
    [self addHandleItemPathIsAvaliable];
}
-(void)addHandleItemPathIsAvaliable{
    if (!self.isItemAvailable) {
        [self.disableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.mas_equalTo(self);
            make.width.height.mas_equalTo(@24);
        }];
    }else{
        if (_disableView) {
            [_disableView removeFromSuperview];
        }
    }
}
- (IBAction)uploadAndShare:(id)sender {
    
    AppDelegate *appDelegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    appDelegate.isUploading = YES;
    
    [MYProgressHUD showProgress:0 withStatus:@"Uploading..." FromView:self.window.contentView];
    
    [appDelegate uploadWithFileURL:self.url progressHandler:^(double progress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"%@", progress);
        });
    }];
    
    return;
    
    dispatch_queue_t serialQueue = dispatch_queue_create("com.blah.queue", DISPATCH_QUEUE_SERIAL);
    
    void (^multiPartCallBack)(NSURLResponse*, id, NSError*) = ^(NSURLResponse *response,  id responseObject, NSError *error) {
        NSDictionary *responseJSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
        
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        
        NSDictionary *params = @{
                                     @"insertVideo" : @"yes",
                                     @"title" : self.title.stringValue,
                                     @"file_name" : responseJSON[@"file_name"]
                                     };
        
        [manager POST:@"http://vidjo.co/actions/file_uploader.php" parameters:params progress:nil success:^(NSURLSessionTask *task, id responseObject) {
            NSDictionary *responseJSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
            
            NSLog(@"JSON: %@", responseObject);
            
            [self notificationMessage:@"Success" informative:@"File has been uploaded!" isSuccess:YES];
            
            AppDelegate *appDelegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
            NSString *urlString = [NSString stringWithFormat:@"http://vidjo.co/watch_video.php?v=%@", responseJSON[@"videokey"]];
            
            [appDelegate showBrowserWithTitle:@"Video Journal" url:urlString];
            
            appDelegate.isUploading = NO;
            
        } failure:^(NSURLSessionTask *operation, NSError *error) {
            NSLog(@"Error: %@", error);
            [self notificationMessage:@"Failure" informative:error.description isSuccess:NO];
            
            AppDelegate *appDelegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
            appDelegate.isUploading = NO;
        }];
    };
    
    dispatch_sync(serialQueue, ^{
        self.request = [[AFHTTPRequestSerializer serializer]
                        multipartFormRequestWithMethod:@"POST"
                        URLString:@"http://vidjo.co/actions/file_uploader.php"
                        parameters:@{}
                        constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                            
                            BOOL isAppended = [formData appendPartWithFileURL:self.url name:@"Filedata" fileName:[NSString stringWithFormat:@"%@.mp4", self.title] mimeType:@"video/mp4" error:nil];
                            
                            if (isAppended) {
                                NSLog(@"appended successfully!");
                            }
                            
                        } error:nil];
        
        [self.request setTimeoutInterval:120];
        
        AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        
        
        
        NSURLSessionUploadTask *uploadTask = [manager uploadTaskWithStreamedRequest:self.request
                                                                   progress:^(NSProgress *uploadProgress) {
                                                                               NSLog(@"Progress");
                                                                       
                                                                       dispatch_async(dispatch_get_main_queue(), ^{
                                                                           [MYProgressHUD showProgress:((double)uploadProgress.completedUnitCount/uploadProgress.totalUnitCount) withStatus:@"Uploading..." FromView:self.window.contentView];
                                                                       
                                                                        });
                                                                   }
                                                                  completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
                                                                      if (error) {
                                                                          NSLog(@"Error: %@", error);
                                                                          [self notificationMessage:@"Failure" informative:error.description isSuccess:NO];
                                                                      } else {
                                                                          NSLog(@"%@ %@", response, responseObject);
                                                                          multiPartCallBack(response, responseObject, error);
                                                                      }
                                                                      
                                                                       [MYProgressHUD dismiss];
                                                                      
                                                                      AppDelegate *appDelegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
                                                                      appDelegate.isUploading = NO;
                                                                  }];
        
        [uploadTask resume];
    });
    
}

- (void)notificationMessage:(NSString *)message informative:(NSString *)informativeText isSuccess:(BOOL)success {
    
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

- (void)continueProgress
{
    static float prog = 0;
    
    prog += 0.334;
    
    if(prog > 1.1) {
        [MYProgressHUD dismiss];
        prog = 0;
        [self.timer invalidate];
        self.timer = nil;
    }
    else {
        [MYProgressHUD showProgress:prog withStatus:@"Loading..." FromView:self.window.contentView];
    }
}


//失效视图
-(NSImageView *)disableView{
    if (!_disableView) {
        _disableView = [[NSImageView alloc]init];
        _disableView.image = [NSImage imageNamed:@"notplay"];
        [self addSubview:_disableView];
    }
    return _disableView;
}
//删除NSTableView当前Item
-(void)removeCurrentItem:(NSButton *)button {
    NSError *error = nil;
    [[NSFileManager defaultManager] removeItemAtPath:self.url.path error:&error];
    
    if ([self.delegate respondsToSelector:@selector(sbPlaylistItemDeleteCurrentItem:)]) {
        [self.delegate sbPlaylistItemDeleteCurrentItem:self];
    }
}
//鼠标进入
-(void)mouseEntered:(NSEvent *)event{
    self.closeBtn.hidden = NO;
}
//鼠标移出
-(void)mouseExited:(NSEvent *)event{
    self.closeBtn.hidden = YES;
}

- (IBAction)showSavePanel:(id)sender
{
    JFImageSavePanel *panel = [JFImageSavePanel savePanel];
    
    [panel runModalForImage:self.url error:NULL];
}

@end
