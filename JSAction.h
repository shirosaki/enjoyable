//
//  JSAction.h
//  Enjoy
//
//  Created by Sam McCall on 4/05/09.
//  Copyright 2009 University of Otago. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <IOKit/hid/IOHIDBase.h>

@interface JSAction : NSObject

@property (assign) void *cookie;
@property (assign) int index;
@property (copy) NSArray *children;
@property (weak) id base;
@property (copy) NSString *name;
@property (assign) BOOL active;
@property (readonly) float magnitude;

- (void)notifyEvent:(IOHIDValueRef)value;
- (NSString *)stringify;
- (id)findSubActionForValue:(IOHIDValueRef)value;

@end
