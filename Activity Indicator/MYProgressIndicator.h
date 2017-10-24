//
//  MYProgressIndicaror.h
//  RIPperDVD
//
//  Created by admin on 17/2/6.
//  Copyright © 2017年 admin. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>
#import "ProgressActivityBezierPath.h"
@interface MYProgressIndicator : NSView
@property (nonatomic,readonly) CGFloat currentProgress;

- (void)setBackgroundColor:(NSColor *)value;
- (void)setRingColor:(NSColor *)value backgroundRingColor:(NSColor*)value2;
- (void)setRingThickness:(CGFloat)thick;
- (void)setRingRadius:(CGFloat)radius;

- (void)showProgress:(float)progress;

-(void)sizeToFit;

-(void)clear;

@property (nonatomic, readonly) CGFloat ringRadius;
@property (nonatomic, readonly) CGFloat ringThickness;

@property (nonatomic, strong) CAShapeLayer *backgroundRingLayer;
@property (nonatomic, strong) CAShapeLayer *ringLayer;
@end
