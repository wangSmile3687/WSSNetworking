//
//  WSSNetworkReachabilityManager.m
//  WSSNetworking
//
//  Created by smile on 2019/8/23.
//

#import "WSSNetworkReachabilityManager.h"
#import <netinet/in.h>
#import <netinet6/in6.h>
#import <arpa/inet.h>
#import <ifaddrs.h>
#import <netdb.h>

NSString *kWSSNetworkReachabilityChangedNotification = @"kWSSNetworkReachabilityChangedNotification";
NSString *kWSSNetworkingReachabilityNotificationStatusItem = @"kWSSNetworkingReachabilityNotificationStatusItem";
typedef void (^WSSNetworkReachabilityStatusBlock)(WSSNetworkReachabilityStatus status);

static WSSNetworkReachabilityStatus WSSNetworkReachabilityStatusForFlags(SCNetworkReachabilityFlags flags) {
    BOOL isReachable = ((flags & kSCNetworkReachabilityFlagsReachable) != 0);
    BOOL needsConnection = ((flags & kSCNetworkReachabilityFlagsConnectionRequired) != 0);
    BOOL canConnectionAutomatically = (((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) || ((flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0));
    BOOL canConnectWithoutUserInteraction = (canConnectionAutomatically && (flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0);
    BOOL isNetworkReachable = (isReachable && (!needsConnection || canConnectWithoutUserInteraction));
    WSSNetworkReachabilityStatus status = WSSNetworkReachabilityStatusNotReachable;
    if (isNetworkReachable == NO) {
        status = WSSNetworkReachabilityStatusNotReachable;
    }
#if TARGET_OS_IPHONE
    else if ((flags & kSCNetworkReachabilityFlagsIsWWAN) != 0) {
        status = WSSNetworkReachabilityStatusReachableViaWWAN;
    }
#endif
    else {
        status = WSSNetworkReachabilityStatusReachableViaWiFi;
    }
    return status;
}
static void WSSNetworkReachabilityCallback(SCNetworkReachabilityRef __unused target, SCNetworkReachabilityFlags flags, void *info) {
    WSSNetworkReachabilityStatus status = WSSNetworkReachabilityStatusForFlags(flags);
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    NSDictionary *userInfo = @{ kWSSNetworkingReachabilityNotificationStatusItem: @(status) };
    [notificationCenter postNotificationName:kWSSNetworkReachabilityChangedNotification object:nil userInfo:userInfo];
}
@interface WSSNetworkReachabilityManager ()
@property (nonatomic, assign) SCNetworkReachabilityRef networkReachabilityRef;
@end

@implementation WSSNetworkReachabilityManager
+ (instancetype)reachability {
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    return [self reachabilityWithAddress: (const struct sockaddr *) &zeroAddress];
}
+ (instancetype)reachabilityWithHostName:(NSString *)hostName {
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(NULL, [hostName UTF8String]);
    WSSNetworkReachabilityManager *networkReachabilityManager = [[self alloc] initWithReachability:reachability];
    CFRelease(reachability);
    return networkReachabilityManager;
}
+ (instancetype)reachabilityWithAddress:(const void *)hostAddress {
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr *)hostAddress);
    WSSNetworkReachabilityManager *networkReachabilityManager = [[self alloc] initWithReachability:reachability];
    CFRelease(reachability);
    return networkReachabilityManager;
}
- (instancetype)initWithReachability:(SCNetworkReachabilityRef)reachability {
    if (self = [super init]) {
        self.networkReachabilityRef = CFRetain(reachability);
    }
    return self;
}
- (void)dealloc {
    [self stopMonitoring];
    if (self.networkReachabilityRef != NULL) {
        CFRelease(_networkReachabilityRef);
    }
}
- (BOOL)startMonitoring {
    BOOL returnValue = NO;
    [self stopMonitoring];
    if (!self.networkReachabilityRef) {
        return returnValue;
    }
    SCNetworkReachabilityContext context = {0, (__bridge void *)(self), NULL, NULL, NULL};
    if (SCNetworkReachabilitySetCallback(self.networkReachabilityRef, WSSNetworkReachabilityCallback, &context)) {
        if (SCNetworkReachabilityScheduleWithRunLoop(self.networkReachabilityRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode)) {
            returnValue = YES;
        }
    }
    return returnValue;
}
- (void)stopMonitoring {
    if (!_networkReachabilityRef) {
        return;
    }
    SCNetworkReachabilityUnscheduleFromRunLoop(_networkReachabilityRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
}
- (WSSNetworkReachabilityStatus)currentReachabilityStatus {
    NSAssert(_networkReachabilityRef != NULL, @"currentNetworkStatus called with NULL SCNetworkReachabilityRef");
    WSSNetworkReachabilityStatus returnValue = WSSNetworkReachabilityStatusNotReachable;
    SCNetworkReachabilityFlags flags;
    if (SCNetworkReachabilityGetFlags(self.networkReachabilityRef, &flags)) {
        returnValue = WSSNetworkReachabilityStatusForFlags(flags);
    }
    return returnValue;
}
- (BOOL)connectionRequired {
    NSAssert(_networkReachabilityRef != NULL, @"connectionRequired called with NULL reachabilityRef");
    SCNetworkReachabilityFlags flags;
    if (SCNetworkReachabilityGetFlags(_networkReachabilityRef, &flags)) {
        return (flags & kSCNetworkReachabilityFlagsConnectionRequired);
    }
    return NO;
}
@end
