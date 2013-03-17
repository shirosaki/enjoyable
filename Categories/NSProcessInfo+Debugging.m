//
//  NSProcessInfo+Debugging.m
//  Enjoyable
//
//  Created by Joe Wreschnig on 3/17/13.
//
//

#import "NSProcessInfo+Debugging.h"

#include <assert.h>
#include <stdbool.h>
#include <sys/types.h>
#include <unistd.h>
#include <sys/sysctl.h>

@implementation NSProcessInfo (Debugging)

- (BOOL)isBeingDebugged {
#ifdef DEBUG
    int mib[4];
    struct kinfo_proc info;
    size_t size = sizeof(info);
    
    info.kp_proc.p_flag = 0;
    
    mib[0] = CTL_KERN;
    mib[1] = KERN_PROC;
    mib[2] = KERN_PROC_PID;
    mib[3] = self.processIdentifier;
    
    return sysctl(mib, sizeof(mib) / sizeof(*mib), &info, &size, NULL, 0) == 0
        && (info.kp_proc.p_flag & P_TRACED) != 0;
#else
    return NO;
#endif
}

@end
