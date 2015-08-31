//
//  TGHttpRequestOperation.m
//  TGNetworking
//
//  Created by Terwer Green on 15/8/31.
//  Copyright (c) 2015年 Terwer Green. All rights reserved.
//

#import "TGHttpRequestOperation.h"

@implementation TGHttpRequestOperation

#pragma mark 初始化
-(instancetype)initWithURL:(NSURL *)newURL{
    if (self = [super initWithURL:newURL]) {
        //初始化
         _hostName = HOST_NAME;
        super.defaultResponseEncoding = NSUTF8StringEncoding;
    }
    return self;
}

+(instancetype)operationWithURL:(NSURL *)newURL{
    return [[self alloc]initWithURL:newURL];
}

#pragma mark 设置回调
-(void)setCompletionBlockWithSuccess:(void (^)(TGHttpRequestOperation *, NSData *))success
                             failure:(void (^)(TGHttpRequestOperation *, NSError *))failure
{
    __weak TGHttpRequestOperation *operation = self ;
    __weak NSString *host = _hostName;
    
    [self setCompletionBlock:^{
        success(operation,[operation responseData]);
    }];
    
    [self setFailedBlock:^{
        NSError *failedError = [NSError errorWithDomain:host code:[operation responseStatusCode] userInfo:@{@"message":[operation responseStatusMessage]}];
        failure(operation,failedError);
    }];
}

@end
