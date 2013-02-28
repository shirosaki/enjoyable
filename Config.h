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

@property (copy) NSString *name;
@property (readonly) NSMutableDictionary *entries;

- (Target *)objectForKeyedSubscript:(JSAction *)action;
- (void)setObject:(Target *)target forKeyedSubscript:(JSAction *)action;

@end
