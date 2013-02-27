//
//  Target.h
//  Enjoy
//
//  Created by Sam McCall on 5/05/09.
//  Copyright 2009 University of Otago. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface Target : NSObject

@property (assign) float magnitude;
@property (assign) BOOL running;
@property (readonly) BOOL isContinuous;

- (void)trigger;
- (void)untrigger;
- (BOOL)update:(JoystickController *)jc;
- (NSString*) stringify;
+ (Target *)unstringify:(NSString*)str withConfigList:(NSArray*)configs;

@end
