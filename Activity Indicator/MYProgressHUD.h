//
//  MYProgressHUD.h
//  RIPperDVD
//
//  Created by admin on 17/2/6.
//  Copyright © 2017年 admin. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>
#import "MyActivityIndicator.h"
#import "MYProgressIndicator.h"
#define pMaxWidth1 250
#define pMaxHeight1 200
/*#define popupWidth  120
 #define popupHeight 120
 
 #define popupAlpha 0.9
 
 #define xOffset 0
 #define yOffset 0
 
 #define indicatorSize 40*/

@class MYProgressIndicator;
@class MyActivityIndicator;
@interface MYProgressHUD : NSView
+ (void)setBackgroundAlpha:(CGFloat)bgAlph disableActions:(BOOL)disActions;

+ (void)showStatus:(NSString*)status FromView:(NSView*)view;
+ (void)showProgress:(CGFloat)progress withStatus:(NSString*)status FromView:(NSView*)view;

+ (void)dismiss;

//+ (void)popActivity;
@property (nonatomic) BOOL keepActivityCount;

@property (nonatomic, readonly) BOOL animatingDismiss;
@property (nonatomic, readonly) BOOL animatingShow;
@property (nonatomic, readonly) BOOL displaying;
@property (nonatomic, readonly) NSUInteger activityCount;
//General Popup Values
@property (nonatomic) CGVector pOffset;
@property (nonatomic) CGFloat pAlpha;

//Padding
@property (nonatomic) CGFloat pPadding;

@property (nonatomic) CGSize indicatorSize;
@property (nonatomic) CGVector indicatorOffset;
@property (nonatomic) CGSize labelSize;
@property (nonatomic) CGVector labelOffset;

@property CGFloat backgroundAlpha;
@property BOOL actionsEnabled;
@end
