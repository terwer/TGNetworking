//
//  TGHttpRequestOperationManager.m
//  TGNetworking
//
//  Created by Terwer Green on 15/8/31.
//  Copyright (c) 2015年 Terwer Green. All rights reserved.
//


#import "TGHttpRequestOperationManager.h"
#import "PublicAccessToken.h"

/**
 *  APP key
 *
 *  @return APP key
 */
#define APP_KEY @"APP_KEY"
/**
 *  APP secret
 *
 *  @return APP secret
 */
#define APP_SECRET @"APP_SECRET"

/**
 * HTTP HEADER字段 Authorization应填充字符串BASIC
 *  @return BASIC
 */
#define BASIC @"Basic "

@interface TGHttpRequestOperationManager () <ASIHTTPRequestDelegate,ASIProgressDelegate>

@property (readwrite, nonatomic, strong) NSURL *requestURL;
@property (readonly,nonatomic,copy) NSString* uuidString;

@end

@implementation TGHttpRequestOperationManager

#pragma mark 初始化
+(instancetype)manager{
    return [[self alloc]initWithBaseURL:nil];
}

-(instancetype)init{
    return [self initWithBaseURL:nil];
}

-(instancetype)initWithBaseURL:(NSURL *)url{
    if (self = [super init]) {
        
        if ([[url path] length] > 0 && ![[url absoluteString] hasSuffix:@"/"]) {
            url = [url URLByAppendingPathComponent:@""];
        }
        
        _requestURL = url;
        //开启队列
        [self go];
    }
    return self;
}

-(NSString *)uuidString{
    CFUUIDRef cfuuid = CFUUIDCreate(kCFAllocatorDefault);
    NSString *uuid = (NSString*)CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault,cfuuid));
    return uuid;
}

#pragma mark 检测网络
-(BOOL) isConnectionAvailable:(NSString *)hostName{
    BOOL isExistenceNetwork = YES;
    Reachability *reach = [Reachability reachabilityWithHostName:hostName];
    switch ([reach currentReachabilityStatus]) {
        case NotReachable:
            isExistenceNetwork = NO;
            NSLog(@"notReachable");
            break;
        case ReachableViaWiFi:
            isExistenceNetwork = YES;
            NSLog(@"WIFI");
            break;
        case ReachableViaWWAN:
            isExistenceNetwork = YES;
            NSLog(@"3G");
            break;
    }
    
    if (!isExistenceNetwork) {
        return NO;
    }
    
    return isExistenceNetwork;
}

#pragma mark - 初始化请求

- (TGHttpRequestOperation *)HTTPRequestOperationWithHTTPMethod:(HttpMethod)method
                                                     URLString:(NSString *)URLString
                                                    parameters:(NSDictionary *)parameters
                                                       success:(void (^)(TGHttpRequestOperation *operation, NSData *responseData))success
                                                       failure:(void (^)(TGHttpRequestOperation *operation, NSError *))failure
{
    _requestURL = [NSURL URLWithString:URLString];
    TGHttpRequestOperation *operation = [[TGHttpRequestOperation alloc] initWithURL:_requestURL];
    
    //设置GET参数
    if (method == HttpMethodGet) {
        NSArray *keys = [parameters allKeys];
        for (int i=0; i<keys.count; i++) {
            NSString *key = keys[i];
            NSString *value = parameters[key];
            if (i==0) {
                operation.url =[NSURL URLWithString:[URLString stringByAppendingFormat:@"?%@=%@",key,value]];
            }else{
                operation.url = [NSURL URLWithString:[[operation.url absoluteString] stringByAppendingFormat:@"&%@=%@",key,value]];
            }
        }
    }
    
    [operation setRequestMethod: method == HttpMethodGet?@"GET":@"POST"];
    operation.defaultResponseEncoding = NSUTF8StringEncoding;
    [operation addRequestHeader:@"Content-Type" value:@"application/x-www-form-urlencoded"];
    
    if (method == HttpMethodPost) {
        for (NSString *key in parameters) {
            NSString *value = parameters[key];
            [operation addPostValue:value forKey:key];
        }
    }
    
    //设置返回
    [operation setCompletionBlockWithSuccess:success failure:failure];
    
    return operation;
}

#pragma mark 发送请求
- (TGHttpRequestOperation *)sendAsyncRequest:(HttpMethod)method
                                   URLString:(NSString *)URLString
                                  parameters:(NSDictionary *)parameters
                                     success:(void (^)(TGHttpRequestOperation *operation, NSData *responseData))success
                                     failure:(void (^)(TGHttpRequestOperation *operation, NSError *error))failure
{
    TGHttpRequestOperation *operation = [self HTTPRequestOperationWithHTTPMethod:method URLString:URLString parameters:parameters success:success failure:failure];
    
    //设置请求代理
    [operation setDelegate:self];
    
    //添加请求到队列
    [self addOperation:operation];
    return operation;
}

- (TGHttpRequestOperation *)sendAsyncRequestWithHeader:(NSDictionary *)headers
                                             HttpMehod:(HttpMethod)method
                                             URLString:(NSString *)URLString
                                            parameters:(NSDictionary *)parameters
                                               success:(void (^)(TGHttpRequestOperation *operation, NSData *responseData))success
                                               failure:(void (^)(TGHttpRequestOperation *operation, NSError *error))failure
{
    TGHttpRequestOperation *operation = [self HTTPRequestOperationWithHTTPMethod:method URLString:URLString parameters:parameters success:success failure:failure];
    
    //设置header
    for (NSString *key in headers) {
        NSString *value = headers[key];
        [operation addRequestHeader:key value:value];
    }
    
    //设置请求代理
    [operation setDelegate:self];
    
    //添加请求到队列
    [self addOperation:operation];
    return operation;
}

- (TGHttpRequestOperation *)sendSyncRequest:(HttpMethod)method
                                  URLString:(NSString *)URLString
                                 parameters:(NSDictionary *)parameters
                                    success:(void (^)(TGHttpRequestOperation *operation, NSData *responseData))success
                                    failure:(void (^)(TGHttpRequestOperation *operation, NSError *error))failure
{
    TGHttpRequestOperation *operation = [self HTTPRequestOperationWithHTTPMethod:method URLString:URLString parameters:parameters success:success failure:failure];
    
    //设置请求代理
    [operation setDelegate:self];
    
    //同步请求直接返回
    [operation startSynchronous];
    
    //结果处理
    int statusCode = [operation responseStatusCode];
    if (200 == statusCode) {
        success(operation,[operation responseData]);
    }else{
        NSError *failedError = [NSError errorWithDomain:operation.hostName code:[operation responseStatusCode] userInfo:@{@"message":[operation responseStatusMessage]}];
        failure(operation,failedError);
    }
    
    return operation;
}

- (TGHttpRequestOperation *)sendSyncRequestWithHeader:(NSDictionary *)headers
                                            HttpMehod:(HttpMethod)method
                                            URLString:(NSString *)URLString
                                           parameters:(NSDictionary *)parameters
                                              success:(void (^)(TGHttpRequestOperation *operation, NSData *responseData))success
                                              failure:(void (^)(TGHttpRequestOperation *operation, NSError *error))failure
{
    TGHttpRequestOperation *operation = [self HTTPRequestOperationWithHTTPMethod:method URLString:URLString parameters:parameters success:success failure:failure];
    
    //设置header
    for (NSString *key in headers) {
        NSString *value = headers[key];
        [operation addRequestHeader:key value:value];
    }
    
    //设置请求代理
    [operation setDelegate:self];
    
    //同步请求直接返回
    [operation startSynchronous];
    
    //结果处理
    int statusCode = [operation responseStatusCode];
    if (200 == statusCode) {
        success(operation,[operation responseData]);
    }else{
        NSError *failedError = [NSError errorWithDomain:operation.hostName code:[operation responseStatusCode] userInfo:@{@"message":[operation responseStatusMessage]}];
        failure(operation,failedError);
    }
    
    return operation;
}


#pragma mark 封装授权请求
- (TGHttpRequestOperation *)sendAsyncRequestWithAuthorizationType:(AuthorizationType)type
                                                       HttpMethod:(HttpMethod)method
                                                        URLString:(NSString *)URLString
                                                       parameters:(NSDictionary *)parameters
                                                          success:(void (^)(TGHttpRequestOperation *operation, NSData *responseData))success
                                                          failure:(void (^)(TGHttpRequestOperation *operation, NSError *error))failure
{
    TGHttpRequestOperation *opreation;
    //根据授权方式选择不同的请求
    switch (type) {
        case AuthorizationTypePublic:
        {
            opreation = [self sendPublicRequest:method URLString:URLString parameters:parameters success:success failure:failure];
            break;
        }
        case AuthorizationTypePrivate:
        {
            opreation = [self sendPrivateRequest:method URLString:URLString parameters:parameters success:success failure:failure];
            
            break;
        }
        default:
        {
            opreation = [self sendAnonymousRequest:method URLString:URLString parameters:parameters success:success failure:failure];
            
            break;
        }
    }
    
    return opreation;
}

//公共令牌请求
-(TGHttpRequestOperation *)sendPublicRequest: (HttpMethod)method
                                   URLString:(NSString *)URLString
                                  parameters:(NSDictionary *)parameters
                                     success:(void (^)(TGHttpRequestOperation *operation, NSData *responseData))success
                                     failure:(void (^)(TGHttpRequestOperation *operation, NSError *error))failure{
    
    
    //设置header
    NSString *bearer = [self getBearer:AuthorizationTypePublic];
    NSDictionary *headers = @{@"Authorization":bearer,@"Content-Type":@"application/x-www-form-urlencoded"};
    
    //发送请求
    TGHttpRequestOperation *operation = [self sendAsyncRequestWithHeader:headers HttpMehod:method URLString:URLString parameters:parameters success:success failure:failure];
    
    return operation;
}

//私有令牌请求
-(TGHttpRequestOperation *)sendPrivateRequest: (HttpMethod)method
                                    URLString:(NSString *)URLString
                                   parameters:(NSDictionary *)parameters
                                      success:(void (^)(TGHttpRequestOperation *operation, NSData *responseData))success
                                      failure:(void (^)(TGHttpRequestOperation *operation, NSError *error))failure
{
    return nil;
}

//匿名访问请求
-(TGHttpRequestOperation *)sendAnonymousRequest: (HttpMethod)method
                                      URLString:(NSString *)URLString
                                     parameters:(NSDictionary *)parameters
                                        success:(void (^)(TGHttpRequestOperation *operation, NSData *responseData))success
                                        failure:(void (^)(TGHttpRequestOperation *operation, NSError *error))failure
{
    return [self sendAsyncRequest:method URLString:URLString parameters:parameters success:success failure:failure];
}

#pragma mark 获取bearer
//获取bearer
-(NSString *)getBearer:(AuthorizationType)tokenType{
    NSString *bearer;
    
    NSString *now = [NSDateFormatter localizedStringFromDate:[NSDate date]
                                                   dateStyle:NSDateFormatterLongStyle
                                                   timeStyle:NSDateFormatterLongStyle];
    NSLog(@"当前请求时间%@",now);
    
    if (tokenType == AuthorizationTypePublic) {
        //从NSUserDefaults读取上次请求时间，如果没有，说明是第一次请求，此时请求获取公共令牌token
        NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
        NSDate *publicExpiresInDate = [def objectForKey:@"public_expires_in_date"];
        NSString *tokenType = [def objectForKey:@"token_type"];
        NSString *accessToken = [def objectForKey:@"access_token"];
        NSString *refreshToken = [def objectForKey:@"refresh_token"];
        if (!refreshToken) {
            refreshToken = @"";
        }
        //存在并且没有过期
        if (publicExpiresInDate && accessToken &&tokenType && refreshToken && ([publicExpiresInDate compare:[NSDate date]] == NSOrderedDescending||[publicExpiresInDate compare:[NSDate date]] == NSOrderedSame)) {
            bearer = [NSString stringWithFormat:@"%@ %@",[tokenType capitalizedString],accessToken];
            NSLog(@"Token在有效期内，从NSUserDefaults读取");
        }else{//不存在或者已经失效,请求新的access Token，并且更新过期时间
            PublicAccessToken *publicAccessToken;
            //已过期，重新获取
            if ([publicExpiresInDate compare:[NSDate date]] == NSOrderedAscending) {
                publicAccessToken = [self refreshPublicAccessToken:refreshToken];
                NSLog(@"Token已经失效，重新请求获取");
            }else{//第一次获取
                publicAccessToken = [self requestNewPublicAccessToken];
                NSLog(@"Token尚未获取，第一次请求获取");
            }
            bearer = [NSString stringWithFormat:@"%@ %@",[publicAccessToken.tokenType capitalizedString],publicAccessToken.accessToken];
        }
    }else{
        bearer = nil;
    }
    NSLog(@"bearer:%@",bearer);
    return bearer;
}

//请求新的公告令牌token
-(PublicAccessToken *)requestNewPublicAccessToken{
    
    //获取key,secret的base64编码
    NSData *data = [[NSString stringWithFormat:@"%@:%@",APP_KEY,APP_SECRET] dataUsingEncoding:NSUTF8StringEncoding];
    NSString *basicStr = [data base64EncodedStringWithOptions:0];
    NSString *basic = [NSString stringWithFormat:@"%@%@",BASIC,basicStr];
    //NSString *basic = @"Basic MTg2NDE3Y2UteHh4eC14eHh4LXh4eHgteHh4eHgxYjkyMDAzOjYxNGE1OGRhLXh4 eHgteHh4eC14eHh4LXh4eHh4ZmZmYjA1MQ==";
    //修正Base64错误
    NSString *clearedBasic = [basic stringByReplacingOccurrencesOfString:@"YjYt" withString:@"Yjct"];
    
    NSString *path = [[NSBundle mainBundle]pathForResource:@"YFStock.plist" ofType:nil];
    NSDictionary *yfStock = [NSDictionary dictionaryWithContentsOfFile:path];
    
    //设置URL
    NSString *authURL = [NSString stringWithFormat:@"http://%@/oauth2/oauth2/token",yfStock[@"Host name"]];
    
    //设置header
    NSDictionary *headers = @{@"Authorization":clearedBasic,@"Content-Type":@"application/x-www-form-urlencoded"};
    
    //设置参数
    NSDictionary *parameters = @{@"grant_type":@"client_credentials",@"open_id":self.uuidString};
    
    __block PublicAccessToken *accessToken;
    
    //发送请求（获取token需要同步请求，因为需要马上返回，后面请求要用到token）
    [self sendSyncRequestWithHeader:headers HttpMehod:HttpMethodPost URLString:authURL parameters:parameters success:^(TGHttpRequestOperation *operation, NSData *responseData) {
        //将结果转换为token模型
        NSDictionary* dataDict=[NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:nil];
        accessToken = [PublicAccessToken tokenWithDict:dataDict];
        //更新NSUserDefaults里面的token有效期
        NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
        NSDate *expiresInDate = [[NSDate date]dateByAddingTimeInterval:accessToken.expiresIn - 10];
        [def setObject:expiresInDate forKey:@"public_expires_in_date"];
        [def setObject:accessToken.tokenType forKey:@"token_type"];
        [def setObject:accessToken.accessToken forKey:@"access_token"];
        [def setObject:accessToken.refreshToken forKey:@"refresh_token"];
        [def synchronize];
    } failure:^(TGHttpRequestOperation *operation, NSError *error) {
        NSLog(@"token获取失败");
    }];
    
    return accessToken;
}

//刷新公告令牌token
-(PublicAccessToken *)refreshPublicAccessToken:(NSString *)refreshToken{
    
    //获取key,secret的base64编码
    NSData *data = [[NSString stringWithFormat:@"%@:%@",APP_KEY,APP_SECRET] dataUsingEncoding:NSUTF8StringEncoding];
    NSString *basicStr = [data base64EncodedStringWithOptions:0];
    NSString *basic = [NSString stringWithFormat:@"%@%@",BASIC,basicStr];
    //NSString *basic = @"Basic MTg2NDE3Y2UteHh4eC14eHh4LXh4eHgteHh4eHgxYjkyMDAzOjYxNGE1OGRhLXh4 eHgteHh4eC14eHh4LXh4eHh4ZmZmYjA1MQ==";
    //修正Base64错误
    NSString *clearedBasic = [basic stringByReplacingOccurrencesOfString:@"YjYt" withString:@"Yjct"];
    
    //设置URL
    NSString *authURL = [NSString stringWithFormat:@"http://%@/oauth2/oauth2/token",HOST_NAME];
    
    //设置header
    NSDictionary *headers = @{@"Authorization":clearedBasic,@"Content-Type":@"application/x-www-form-urlencoded"};
    
    //设置参数
    NSDictionary *parameters = @{@"grant_type":@"refresh_token",@"refresh_token":refreshToken};
    
    __block PublicAccessToken *accessToken;
    
    //发送请求（获取token需要同步请求，因为需要马上返回，后面请求要用到token）
    [self sendSyncRequestWithHeader:headers HttpMehod:HttpMethodPost URLString:authURL parameters:parameters success:^(TGHttpRequestOperation *operation, NSData *responseData) {
        //将结果转换为token模型
        NSDictionary* dataDict=[NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:nil];
        accessToken = [PublicAccessToken tokenWithDict:dataDict];
        //更新NSUserDefaults里面的token有效期
        NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
        NSDate *expiresInDate = [[NSDate date]dateByAddingTimeInterval:accessToken.expiresIn - 10];
        [def setObject:expiresInDate forKey:@"public_expires_in_date"];
        [def setObject:accessToken.tokenType forKey:@"token_type"];
        [def setObject:accessToken.accessToken forKey:@"access_token"];
        [def setObject:accessToken.refreshToken forKey:@"refresh_token"];
        [def synchronize];
    } failure:^(TGHttpRequestOperation *operation, NSError *error) {
        NSLog(@"token刷新失败,%@",[operation responseString]);
    }];
    
    return accessToken;
}

#pragma mark ASINetworkQueue delegate
-(void)requestStarted:(ASIHTTPRequest *)request{
    //NSLog(@"队列中的一个线程开始请求");
}

-(void)requestFinished:(ASIHTTPRequest *)request{
    //NSLog(@"队列中的一个线程请求完成");
}

-(void)requestFailed:(ASIHTTPRequest *)request{
    //NSLog(@"队列中的一个线程请求失败");
}

//#pragma mark Helpers
//目前只确定GET和POST
//-(HttpMethod)methodWithString:(NSString *)methodString{
//    HttpMethod method;
//    methodString = [methodString uppercaseString];
//    if ([methodString isEqualToString:@"GET"] ) {
//        method =HttpMethodGet;
//    }else{
//        method =HttpMethodPost;
//    }
//    return method;
//}

@end
