//
//  JSAction.h
//  Enjoy
//
//  Created by Sam McCall on 4/05/09.
//  Copyright 2009 University of Otago. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <IOKit/hid/IOHIDBase.h>

@interface JSAction : NSObject {
	id base;
	NSString *name;
}

@property (assign) void* cookie;
@property (assign) int index;
@property (copy) NSArray *subActions;
@property (strong) id base;
@property (copy) NSString *name;
@property (readonly) BOOL active;

- (void)notifyEvent:(IOHIDValueRef)value;
- (NSString *)stringify;
- (id)findSubActionForValue:(IOHIDValueRef)value;

@end
