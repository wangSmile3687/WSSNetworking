//
//  WSSNetworkReachabilityManager.m
//  WSSNetworking
//
//  Created by smile on 2019/8/23.
//

#import "WSSNetworkReachabilityManager.h"

#if __has_include(<AFNetworking/AFNetworking.h>)
#import <AFNetworking/AFNetworking.h>
#else
#import "AFNetworking.h"
#endif

NSString *const WSSNetworkStatusChangeNotification = @"WSSNetworkStatusChange";
static NSString *const WSSNetworkOfflineModel = @"WSSOfflineModel";

@interface WSSNetworkReachabilityManager ()
@property (nonatomic, assign) BOOL firstNetworkStatusChange;
@end

@implementation WSSNetworkReachabilityManager
+ (WSSNetworkReachabilityManager *)sharedManager {
    static WSSNetworkReachabilityManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[WSSNetworkReachabilityManager alloc] init];
        manager.firstNetworkStatusChange = YES;
    });
    return manager;
}
- (void)startMonitoring {
    __weak typeof(self) weakSelf = self;
    AFNetworkReachabilityManager *manger = [AFNetworkReachabilityManager sharedManager];
    [manger setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        switch (status) {
            case AFNetworkReachabilityStatusNotReachable:
                strongSelf.networkStatus = WSSNetworkStatusNoNetwork;
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
                strongSelf.networkStatus = WSSNetworkStatusWiFi;
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
                strongSelf.networkStatus = WSSNetworkStatusWan;
                break;
            default:
                strongSelf.networkStatus = WSSNetworkStatusUnKnown;
                break;
        }
        if ([strongSelf getNetworkOfflineModel]) {
            strongSelf.networkStatus = WSSNetworkStatusNoNetwork;
        }
        if (strongSelf.firstNetworkStatusChange) {
            if (strongSelf.firstNetworkStatusChangeBlock) {
                strongSelf.firstNetworkStatusChangeBlock();
            }
            strongSelf.firstNetworkStatusChangeBlock = nil;
            strongSelf.firstNetworkStatusChange = NO;
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:WSSNetworkStatusChangeNotification object:nil];
    }];
    [manger startMonitoring];
}
- (void)stopMonitoring {
    self.firstNetworkStatusChange = YES;
    [[AFNetworkReachabilityManager sharedManager] stopMonitoring];
}
- (void)setNetworkOfflineModel:(BOOL)offline {
    [[NSUserDefaults standardUserDefaults] setBool:offline forKey:WSSNetworkOfflineModel];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (BOOL)getNetworkOfflineModel {
    return [[NSUserDefaults standardUserDefaults] boolForKey:WSSNetworkOfflineModel];
}
- (void)dealloc {
    [self stopMonitoring];
}
@end
