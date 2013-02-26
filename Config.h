//
//  Config.h
//  Enjoy
//
//  Created by Sam McCall on 4/05/09.
//  Copyright 2009 University of Otago. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Target;
@class JSAction;

@interface Config : NSObject

@property (assign) BOOL protect;
@property (copy) NSString *name;
@property (readonly) NSMutableDictionary *entries;

- (void)setTarget:(Target *)target forAction:(JSAction *)jsa;
- (Target *)getTargetForAction:(JSAction *)sa;

@end
