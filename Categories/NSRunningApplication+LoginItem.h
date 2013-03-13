//
//  NSRunningApplication+LoginItem.h
//  Enjoyable
//
//  Created by Joe Wreschnig on 3/13/13.
//
//

#import <Cocoa/Cocoa.h>

@interface NSRunningApplication (LoginItem)
    // Don't be a jerk. Ask the user before doing this.

- (BOOL)isLoginItem;
- (void)addToLoginItems;
- (void)removeFromLoginItems;
- (BOOL)wasLaunchedAsLoginItemOrResume;

@end
