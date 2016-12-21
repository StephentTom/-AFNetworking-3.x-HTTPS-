//
//  TwoWayHTTPS.h
//  HTTPs
//
//  Created by xino on 2016/12/21.
//  Copyright © 2016年 HFS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TwoWayHTTPS : NSObject

+ (void)POST:(NSString *)URLString
  parameters:(id)parameters
     success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
     failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

+ (void)GET:(NSString *)URLString
 parameters:(id)parameters
    success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
    failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

@end
