//
//  NSString+FixFilename.h
//  Enjoyable
//
//  Created by Joe Wreschnig on 3/7/13.
//
//

#import <Foundation/Foundation.h>

@interface NSCharacterSet (FixFilename)

+ (NSCharacterSet *)invalidPathComponentCharacterSet;
    // A character set containing the characters that are invalid to
    // use in path components on common filesystems.

@end

@interface NSString (FixFilename)

- (NSString *)stringByFixingPathComponent;
    // Does various operations to make this string suitable for use as
    // a single path component of a normal filename. Removes
    // characters that are invalid. Strips whitespace from the
    // beginning and end. If the first character is a . or a -, a _ is
    // added to the front.

@end
