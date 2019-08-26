//
//  WSSNetworkProtocol.h
//  WSSNetworking
//
//  Created by smile on 2019/8/22.
//


@protocol WSSNetworkProtocol <NSObject>
@optional
/**
 request parameters
 @param parameters parameters description
 @return return value description
 */
- (id)requestParameters:(id)parameters;
/**
 result http success response
 
 @param result result description
 @return return value description
 */
- (id)resultSuccessResponseWithResult:(id)result;
/**
 result http failure response
 
 @param result result description
 @return return value description
 */
- (id)resultFailureResponseWithResult:(id)result;
@end
