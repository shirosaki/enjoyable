//
//  NJHIDManager.h
//  Enjoyable
//
//  Created by Joe Wreschnig on 3/13/13.
//
//

#import <Foundation/Foundation.h>

@protocol NJHIDManagerDelegate;

@interface NJHIDManager : NSObject

@property (nonatomic, copy) NSArray *criteria;
    // Changing the criteria may trigger a stop and restart. If this happens,
    // messages will be sent to the delegate as usual.

@property (nonatomic, assign) BOOL running;
@property (nonatomic, weak) id <NJHIDManagerDelegate> delegate;

- (id)initWithCriteria:(NSArray *)criteria
              delegate:(id <NJHIDManagerDelegate>)delegate;

- (void)start;
- (void)stop;

@end

@protocol NJHIDManagerDelegate

- (void)hidManagerDidStart:(NJHIDManager *)manager;
- (void)hidManagerDidStop:(NJHIDManager *)manager;
    // Stopping the device will not trigger any removal events, so any
    // cleanup in the delegate must be done here.

- (void)hidManager:(NJHIDManager *)manager didError:(NSError *)error;

- (void)hidManager:(NJHIDManager *)manager deviceAdded:(IOHIDDeviceRef)device;
- (void)hidManager:(NJHIDManager *)manager deviceRemoved:(IOHIDDeviceRef)device;

- (void)hidManager:(NJHIDManager *)manager
      valueChanged:(IOHIDValueRef)value
        fromDevice:(IOHIDDeviceRef)device;
@end
