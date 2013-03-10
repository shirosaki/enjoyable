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
@property (nonatomic, readonly) NSUInteger count;

+ (id)mappingWithContentsOfURL:(NSURL *)url
                      mappings:(NSArray *)mappings
                         error:(NSError **)error;

- (id)initWithName:(NSString *)name;
- (id)initWithSerialization:(NSDictionary *)serialization
                   mappings:(NSArray *)mappings;

- (NJOutput *)objectForKeyedSubscript:(NJInput *)input;
- (void)setObject:(NJOutput *)output forKeyedSubscript:(NJInput *)input;
- (NSDictionary *)serialize;
- (BOOL)writeToURL:(NSURL *)url error:(NSError **)error;
- (BOOL)hasConflictWith:(NJMapping *)other;
- (void)mergeEntriesFrom:(NJMapping *)other;

@end
