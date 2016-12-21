//
//  OneWayHTTPS.m
//  HTTPs
//
//  Created by xino on 2016/12/21.
//  Copyright © 2016年 HFS. All rights reserved.
//

#import "OneWayHTTPS.h"
#import <AFNetworking.h>


#define APIBaseURL @"https://..."

@implementation OneWayHTTPS

+ (AFHTTPSessionManager *)sessionManager {
    static dispatch_once_t onceToken;
    static AFHTTPSessionManager *_manager = nil;
    dispatch_once(&onceToken, ^{
        _manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:APIBaseURL]];
        
        /// 注意将你的证书加入项目，并把下面名称改为自己证书的名称
        NSString *cerPath = [[NSBundle mainBundle] pathForResource:@"" ofType:@"cer"];
        NSData *caCertData = [NSData dataWithContentsOfFile:cerPath];
    
        AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate withPinnedCertificates:[NSSet setWithObject:caCertData]];
        
        /// 是否允许使用自签名证书
        securityPolicy.allowInvalidCertificates = YES;
        /// 是否需要验证域名
        securityPolicy.validatesDomainName = NO;
        
        _manager.securityPolicy = securityPolicy;
        
        /// 关闭缓存避免干扰测试
        _manager.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
        
        /// 客户端请求验证 重写 setSessionDidReceiveAuthenticationChallengeBlock 方法
        [_manager setSessionDidReceiveAuthenticationChallengeBlock:^NSURLSessionAuthChallengeDisposition(NSURLSession * _Nonnull session, NSURLAuthenticationChallenge * _Nonnull challenge, NSURLCredential *__autoreleasing *_credential) {
            
            /// 获取服务器的trust object
            SecTrustRef serverTrust = [[challenge protectionSpace] serverTrust];
            SecCertificateRef caRef = SecCertificateCreateWithData(NULL, (__bridge CFDataRef)caCertData);
            NSCAssert(caRef != nil, @"caRef is nil");
            
            NSArray *caArray = @[(__bridge id)(caRef)];
            NSCAssert(caArray != nil, @"caArray is nil");
            
            /// 将读取到的证书设置为serverTrust的根证书
            OSStatus status = SecTrustSetAnchorCertificates(serverTrust, (__bridge CFArrayRef)caArray);
            SecTrustSetAnchorCertificatesOnly(serverTrust,NO);
            NSCAssert(errSecSuccess == status, @"SecTrustSetAnchorCertificates failed");
            
            /// 选择质询认证的处理方式
            NSURLSessionAuthChallengeDisposition disposition = NSURLSessionAuthChallengePerformDefaultHandling;
            __autoreleasing NSURLCredential *credential = nil;
            
            /// NSURLAuthenticationMethodServerTrust质询认证方式
            if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
                
                /// 基于客户端的安全策略来决定是否信任该服务器，不信任则不响应质询。
                if ([_manager.securityPolicy evaluateServerTrust:challenge.protectionSpace.serverTrust forDomain:challenge.protectionSpace.host]) {
                    
                    /// 创建质询证书
                    credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
                    /// 确认质询方式
                    if (credential) {
                        disposition = NSURLSessionAuthChallengeUseCredential;
                    } else {
                        disposition = NSURLSessionAuthChallengePerformDefaultHandling;
                    }
                } else {
                    /// 取消挑战
                    disposition = NSURLSessionAuthChallengeCancelAuthenticationChallenge;
                }
                
            } else {
                disposition = NSURLSessionAuthChallengePerformDefaultHandling;
            }
            
            return disposition;
        }];
        
    });
    return _manager;
}

+ (void)POST:(NSString *)URLString
  parameters:(id)parameters
     success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
     failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {

    [[[self class] sessionManager] POST:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (success) {
            success(task, responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure(task, error);
        }
    }];
}

+ (void)GET:(NSString *)URLString
 parameters:(id)parameters
    success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
    failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {

    [[[self class] sessionManager] GET:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (success) {
            success(task, responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure(task, error);
        }
    }];
}

@end
