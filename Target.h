//
//  Target.h
//  Enjoy
//
//  Created by Sam McCall on 5/05/09.
//  Copyright 2009 University of Otago. All rights reserved.
//

@class NJInputController;

@interface Target : NSObject

@property (nonatomic, assign) float magnitude;
@property (nonatomic, assign) BOOL running;
@property (nonatomic, readonly) BOOL isContinuous;

- (void)trigger;
- (void)untrigger;
- (BOOL)update:(NJInputController *)jc;

- (NSDictionary *)serialize;
+ (Target *)targetDeserialize:(NSDictionary *)serialization
                  withMappings:(NSArray *)mappings;
+ (NSString *)serializationCode;

@end
