//
//  NJOutputMouseButton.h
//  Enjoy
//
//  Created by Yifeng Huang on 7/27/12.
//

#import "NJOutput.h"

@interface NJOutputMouseButton : NJOutput

@property (nonatomic, assign) CGMouseButton button;
    // Indexed as left, right, center.

@property (nonatomic, assign) int humanIndexedButton;
    // Indexed as left, center, right.

@end
