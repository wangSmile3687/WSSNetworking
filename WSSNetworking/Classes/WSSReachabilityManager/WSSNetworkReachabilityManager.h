//
//  WSSNetworkReachabilityManager.h
//  WSSNetworking
//
//  Created by smile on 2019/8/23.
//

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>

typedef NS_ENUM(NSInteger, WSSNetworkReachabilityStatus) {
    WSSNetworkReachabilityStatusNotReachable     = 0,
    WSSNetworkReachabilityStatusReachableViaWWAN = 1,
    WSSNetworkReachabilityStatusReachableViaWiFi = 2,
};

extern NSString *kWSSNetworkReachabilityChangedNotification;
extern NSString *kWSSNetworkingReachabilityNotificationStatusItem;

@interface WSSNetworkReachabilityManager : NSObject
/*!
 * Checks whether the default route is available. Should be used by applications that do not connect to a particular host.
 */
+ (instancetype)reachability;
/*!
 * Use to check the reachability of a given host name.
 */
+ (instancetype)reachabilityWithHostName:(NSString *)hostName;
/*!
 * Use to check the reachability of a given IP address.
 */
+ (instancetype)reachabilityWithAddress:(const void *)hostAddress;
/// Starts monitoring for changes in network reachability status.
- (BOOL)startMonitoring;
///  Stops monitoring for changes in network reachability status
- (void)stopMonitoring;
/// current reachability status
- (WSSNetworkReachabilityStatus)currentReachabilityStatus;
/*!
 * WWAN may be available, but not active until a connection has been established. WiFi may require a connection for VPN on Demand.
 */
- (BOOL)connectionRequired;
@end

