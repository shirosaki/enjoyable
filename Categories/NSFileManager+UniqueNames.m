//
//  NSFileManager+UniqueNames.m
//  Enjoyable
//
//  Created by Joe Wreschnig on 3/7/13.
//
//

#import "NSFileManager+UniqueNames.h"

@implementation NSFileManager (UniqueNames)

- (NSURL *)generateUniqueURLWithBase:(NSURL *)canonical {
    // Punt for cases that are just too hard.
    if (!canonical.isFileURL)
        return canonical;

    NSString *trying = canonical.path;
    NSString *dirname = [trying stringByDeletingLastPathComponent];
    NSString *basename = [trying.lastPathComponent stringByDeletingPathExtension];
    NSString *extension = trying.pathExtension;
    int index = 1;
    while ([self fileExistsAtPath:trying] && index < 10000) {
        NSString *indexName = [NSString stringWithFormat:@"%@ (%d)", basename, index++];
        indexName = [indexName stringByAppendingPathExtension:extension];
        trying = [dirname stringByAppendingPathComponent:indexName];
    }
    return [NSURL fileURLWithPath:trying];
}

@end
