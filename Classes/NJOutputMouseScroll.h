//
//  NJOutputMouseScroll.h
//  Enjoy
//
//  Created by Yifeng Huang on 7/28/12.
//

#import "NJOutput.h"

@interface NJOutputMouseScroll : NJOutput

@property (nonatomic, assign) int direction;
@property (nonatomic, assign) float speed;
@property (nonatomic, assign) BOOL smooth;

@end
