//
//  WSSNetworkReachabilityManager.h
//  WSSNetworking
//
//  Created by smile on 2019/8/23.
//

#import <Foundation/Foundation.h>

UIKIT_EXTERN NSString *const WSNetworkStatusChangeNotification;

typedef NS_ENUM(NSInteger, WSSNetworkStatus) {
    WSSNetworkStatusUnKnown = 0,
    WSSNetworkStatusWiFi,
    WSSNetworkStatusWan,
    WSSNetworkStatusNoNetwork,
};
typedef void(^FirstNetworkStatusChangeBlock)(void);

@interface WSSNetworkReachabilityManager : NSObject
@property (nonatomic, assign) WSSNetworkStatus networkStatus;
@property (nonatomic, copy)   FirstNetworkStatusChangeBlock firstNetworkStatusChangeBlock;
+ (WSSNetworkReachabilityManager *)sharedManager;
/**
 开始监听网络状况
 */
- (void)startMonitoring;
/**
 停止监听网络状况
 */
- (void)stopMonitoring;
/**
 设置离线模式 默认no
 @param offline offline-yes  online-no
 */
- (void)setNetworkOfflineModel:(BOOL)offline;
/**
 获取离线模式状态
 
 @return yes-offline   no-online
 */
- (BOOL)getNetworkOfflineModel;
@end

