#import <Foundation/Foundation.h>
#import <IOKit/hid/IOHIDLib.h>

@protocol NJHIDManagerDelegate;

@interface NJHIDManager : NSObject
    // Light OO wrapper around IOKit callbacks.

- (id)initWithCriteria:(NSArray *)criteria
              delegate:(id <NJHIDManagerDelegate>)delegate;

@property (nonatomic, weak) id <NJHIDManagerDelegate> delegate;

@property (nonatomic, copy) NSArray *criteria;
    // Changing the criteria may trigger a stop and restart. If this
    // happens, messages will be sent to the delegate as usual.

@property (nonatomic, assign) BOOL running;
    // Assigning YES is like sending start; NO like stop.

- (void)start;
- (void)stop;

@end

@protocol NJHIDManagerDelegate

- (void)HIDManagerDidStart:(NJHIDManager *)manager;
- (void)HIDManagerDidStop:(NJHIDManager *)manager;
    // Stopping the device will not trigger any removal messages, so any
    // cleanup in the delegate must be done here.

- (void)HIDManager:(NJHIDManager *)manager deviceAdded:(IOHIDDeviceRef)device;
- (void)HIDManager:(NJHIDManager *)manager deviceRemoved:(IOHIDDeviceRef)device;

- (void)HIDManager:(NJHIDManager *)manager valueChanged:(IOHIDValueRef)value;

- (void)HIDManager:(NJHIDManager *)manager didError:(NSError *)error;

@end
