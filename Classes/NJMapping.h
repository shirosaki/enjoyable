//
//  NJMapping.h
//  Enjoy
//
//  Created by Sam McCall on 4/05/09.
//  Copyright 2009 University of Otago. All rights reserved.
//

@class NJOutput;
@class NJInput;

@interface NJMapping : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, readonly) NSMutableDictionary *entries;

- (id)initWithName:(NSString *)name;
- (NJOutput *)objectForKeyedSubscript:(NJInput *)input;
- (void)setObject:(NJOutput *)output forKeyedSubscript:(NJInput *)input;
- (NSDictionary *)serialize;
- (BOOL)writeToURL:(NSURL *)url error:(NSError **)error;

+ (id)mappingWithContentsOfURL:(NSURL *)url mappings:(NSArray *)mappings error:(NSError **)error;

@end
