//
//  TargetConfig.h
//  Enjoy
//
//  Created by Sam McCall on 6/05/09.
//  Copyright 2009 University of Otago. All rights reserved.
//

#import "Target.h"

@class NJMapping;

@interface TargetConfig : Target

@property (nonatomic, weak) NJMapping *mapping;

@end
