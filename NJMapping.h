//
//  NJMapping.h
//  Enjoy
//
//  Created by Sam McCall on 4/05/09.
//  Copyright 2009 University of Otago. All rights reserved.
//

@class Target;
@class NJInput;

@interface NJMapping : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, readonly) NSMutableDictionary *entries;

- (id)initWithName:(NSString *)name;
- (Target *)objectForKeyedSubscript:(NJInput *)input;
- (void)setObject:(Target *)target forKeyedSubscript:(NJInput *)input;
- (NSDictionary *)serialize;

@end
