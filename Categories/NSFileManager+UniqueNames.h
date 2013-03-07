//
//  NSFileManager+UniqueNames.h
//  Enjoyable
//
//  Created by Joe Wreschnig on 3/7/13.
//
//

#import <Foundation/Foundation.h>

@interface NSFileManager (UniqueNames)

- (NSURL *)generateUniqueURLWithBase:(NSURL *)canonical;
    // Generate a probably-unique URL by trying sequential indices, e.g.
    //     file://Test.txt
    //     file://Test (1).txt
    //     file://Test (2).txt
    // and so on.
    //
    // The URL is only probably unique. It is subject to the usual
    // race conditions associated with generating a filename before
    // actually opening it. It also does not check remote resources,
    // as it operates synchronously. Finally, it gives up after 10,000
    // indices.

@end
