//
//  TargetConfig.h
//  Enjoy
//
//  Created by Sam McCall on 6/05/09.
//  Copyright 2009 University of Otago. All rights reserved.
//

#import "Target.h"

@class Config;

@interface TargetConfig : Target

@property (weak) Config *config;
+ (TargetConfig *)unstringifyImpl:(NSArray *)comps withConfigList:(NSArray *)configs;

@end
