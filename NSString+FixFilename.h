//
//  NSString+FixFilename.h
//  Enjoyable
//
//  Created by Joe Wreschnig on 3/7/13.
//
//

#import <Foundation/Foundation.h>

@interface NSString (FixFilename)

- (NSString *)stringByFixingPathComponent;
    // Does various operations to make this string suitable for use as
    // a single path component of a normal filename. Removes / and :
    // characters and prepends a _ to avoid leading .s or an empty
    // name.

@end
