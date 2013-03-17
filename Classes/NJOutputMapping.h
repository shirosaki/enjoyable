//
//  NJOutputMapping.h
//  Enjoy
//
//  Created by Sam McCall on 6/05/09.
//  Copyright 2009 University of Otago. All rights reserved.
//

#import "NJOutput.h"

@class NJMapping;

@interface NJOutputMapping : NJOutput

@property (nonatomic, weak) NJMapping *mapping;
@property (nonatomic, copy) NSString *mappingName;

@end
