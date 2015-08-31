//
//  TGHttpRequestOperationManager.h
//  TGNetworking
//
//  Created by Terwer Green on 15/8/31.
//  Copyright (c) 2015年 Terwer Green. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Reachability.h"
#import "TGHttpRequestOperation.h"
#import "ASINetworkQueue.h"

@interface TGHttpRequestOperationManager : ASINetworkQueue

/**
 *  令牌授权方式
 */
typedef NS_ENUM(NSInteger, AuthorizationType){
    /**
     *  公共令牌
     */
    AuthorizationTypePublic,
    /**
     *  私有令牌
     */
    AuthorizationTypePrivate,
    /**
     *  匿名
     */
    AuthorizationTypeAnonymous
};

///--------------
/// @name 检测网络
///--------------
/**
 *  检测网络
 *
 *  @return 网络状态
 */
-(BOOL) isConnectionAvailable:(NSString *)hostName;

///--------------------
/// @name 创建HTTPClient
///--------------------
/**
 *  初始化YFHttpRequestManager
 *
 *  @return YFHttpRequestManager
 */
+(instancetype)manager;

/**
 *  用制定的url初始化YFHttpRequestManager
 *
 *  @param url url
 *
 *  @return YFHttpRequestManager
 */
-(instancetype)initWithBaseURL:(NSURL *)url;

///-------------------
/// @name 初始化HTTP请求
///-------------------
/**
 *  根据请求类型发送HTTP请求
 *
 *  @param method     请求类型（GET、POST）
 *  @param URLString  请求URL
 *  @param parameters 参数
 *  @param success    操作成功时执行的block
 *  @param failure    操作失败时执行的block
 *
 *  @return YFHttpRequest
 */

- (TGHttpRequestOperation *)HTTPRequestOperationWithHTTPMethod:(HttpMethod)method
                                                     URLString:(NSString *)URLString
                                                    parameters:(NSDictionary *)parameters
                                                       success:(void (^)(TGHttpRequestOperation *operation, NSData *responseData))success
                                                       failure:(void (^)(TGHttpRequestOperation *operation, NSError *))failure;


///------------------
/// @name 发送HTTP请求
///------------------

/**
 *  根据请求类型发送异步HTTP请求
 *
 *  @param method     请求类型（GET、POST）
 *  @param URLString  请求URL
 *  @param parameters 参数
 *  @param success    操作成功时执行的block
 *  @param failure    操作失败时执行的block
 *
 *  @return YFHttpRequestOperation
 */
- (TGHttpRequestOperation *)sendAsyncRequest:(HttpMethod)method
                                   URLString:(NSString *)URLString
                                  parameters:(NSDictionary *)parameters
                                     success:(void (^)(TGHttpRequestOperation *operation, NSData *responseData))success
                                     failure:(void (^)(TGHttpRequestOperation *operation, NSError *error))failure;

/**
 *  发送带header异步HTTP请求
 *
 *  @param headers    HTTP头
 *  @param method     请求类型（GET、POST）
 *  @param URLString  请求URL
 *  @param parameters 参数
 *  @param success    操作成功时执行的block
 *  @param failure    操作失败时执行的block
 *
 *  @return YFHttpRequestOperation
 */
- (TGHttpRequestOperation *)sendAsyncRequestWithHeader:(NSDictionary *)headers
                                             HttpMehod:(HttpMethod)method
                                             URLString:(NSString *)URLString
                                            parameters:(NSDictionary *)parameters
                                               success:(void (^)(TGHttpRequestOperation *operation, NSData *responseData))success
                                               failure:(void (^)(TGHttpRequestOperation *operation, NSError *error))failure;

/**
 *  根据请求类型发送同步HTTP请求
 *
 *  @param method     请求类型（GET、POST）
 *  @param URLString  请求URL
 *  @param parameters 参数
 *  @param success    操作成功时执行的block
 *  @param failure    操作失败时执行的block
 *
 *  @return YFHttpRequestOperation
 */
- (TGHttpRequestOperation *)sendSyncRequest:(HttpMethod)method
                                  URLString:(NSString *)URLString
                                 parameters:(NSDictionary *)parameters
                                    success:(void (^)(TGHttpRequestOperation *operation, NSData *responseData))success
                                    failure:(void (^)(TGHttpRequestOperation *operation, NSError *error))failure;

/**
 *  发送带header同步HTTP请求
 *
 *  @param headers    HTTP头
 *  @param method     请求类型（GET、POST）
 *  @param URLString  请求URL
 *  @param parameters 参数
 *  @param success    操作成功时执行的block
 *  @param failure    操作失败时执行的block
 *
 *  @return YFHttpRequestOperation
 */
- (TGHttpRequestOperation *)sendSyncRequestWithHeader:(NSDictionary *)headers
                                            HttpMehod:(HttpMethod)method
                                            URLString:(NSString *)URLString
                                           parameters:(NSDictionary *)parameters
                                              success:(void (^)(TGHttpRequestOperation *operation, NSData *responseData))success
                                              failure:(void (^)(TGHttpRequestOperation *operation, NSError *error))failure;

/**
 *  根据授权类型发送异步HTTP请求
 *
 *  @param type       授权类型（公共、私有、匿名）
 *  @param method     请求类型（GET、POST）
 *  @param URLString  请求URL
 *  @param parameters 参数
 *  @param success    操作成功时执行的block
 *  @param failure    操作失败时执行的block
 *
 *  @return YFHttpRequestOperation
 */
- (TGHttpRequestOperation *)sendAsyncRequestWithAuthorizationType:(AuthorizationType)type
                                                       HttpMethod:(HttpMethod)method
                                                        URLString:(NSString *)URLString
                                                       parameters:(NSDictionary *)parameters
                                                          success:(void (^)(TGHttpRequestOperation *operation, NSData *responseData))success
                                                          failure:(void (^)(TGHttpRequestOperation *operation, NSError *error))failure;
@end

