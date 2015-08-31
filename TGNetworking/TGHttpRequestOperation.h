//
//  TGHttpRequestOperation.h
//  TGNetworking
//
//  Created by Terwer Green on 15/8/31.
//  Copyright (c) 2015年 Terwer Green. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"

#define HOST_NAME @"www.demo.com"

///------------------
/// @name HTTP请求方式
///------------------
/**
 *  HTTP请求方式
 */
typedef NS_ENUM(NSInteger, HttpMethod){
    /**
     *  GET
     */
    HttpMethodGet,
    /**
     *  POST
     */
    HttpMethodPost
};

@interface TGHttpRequestOperation : ASIFormDataRequest

/**
 *  请求主机地址（从YFStock.plist读取）
 */
@property (nonatomic,copy,readonly) NSString *hostName;

///------------
/// @name 初始化
///------------
#pragma mark 初始化
-(instancetype)initWithURL:(NSURL *)newURL;
+(instancetype)operationWithURL:(NSURL *)newURL;

///-------------
/// @name 结果处理
///-------------
/**
 *  设置结果回调
 *
 *  @param success 操作成功时执行的block
 *  @param failure 操作失败时执行的block
 */
- (void)setCompletionBlockWithSuccess:(void (^)(TGHttpRequestOperation *operation, NSData *responseData))success
                              failure:(void (^)(TGHttpRequestOperation *operation, NSError *error))failure;

@end
