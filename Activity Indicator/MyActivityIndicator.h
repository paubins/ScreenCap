//
//  MyActivityIndicator.h
//  RIPperDVD
//
//  Created by admin on 17/2/6.
//  Copyright © 2017年 admin. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MyActivityIndicator : NSView
@property BOOL isAnimating;

- (void)setColor:(NSColor *)value;
- (void)setBackgroundColor:(NSColor *)value;

- (void)stopAnimation:(id)sender;
- (void)startAnimation:(id)sender;
@end
