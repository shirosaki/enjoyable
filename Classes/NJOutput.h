//
//  NJOutput.h
//  Enjoy
//
//  Created by Sam McCall on 5/05/09.
//  Copyright 2009 University of Otago. All rights reserved.
//

@class NJDeviceController;

@interface NJOutput : NSObject

@property (nonatomic, assign) float magnitude;
@property (nonatomic, assign) BOOL running;
@property (nonatomic, readonly) BOOL isContinuous;

- (void)trigger;
- (void)untrigger;
- (BOOL)update:(NJDeviceController *)jc;

- (NSDictionary *)serialize;
+ (NJOutput *)outputDeserialize:(NSDictionary *)serialization;
+ (NSString *)serializationCode;

- (void)postLoadProcess:(id <NSFastEnumeration>)allMappings;

@end
