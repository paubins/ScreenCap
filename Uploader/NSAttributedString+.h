//
//  NSAttributedString+.h
//  ScreenCap
//
//  Created by Patrick Aubin on 10/4/17.
//  Copyright © 2017 Patrick Aubin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

@interface NSAttributedString (Hyperlink)
+(NSMutableAttributedString *)hyperlinkFromString:(NSString*)inString withURL:(NSURL*)aURL;
@end
