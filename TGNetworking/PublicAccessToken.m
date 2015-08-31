//
//  PublicAccessToken.m
//  TGNetworking
//
//  Created by Terwer Green on 15/8/31.
//  Copyright (c) 2015年 Terwer Green. All rights reserved.
//

#import "PublicAccessToken.h"

@implementation PublicAccessToken

-(instancetype)initWithDict:(NSDictionary *)dict{
    if (self = [super init]) {
        _tokenType = dict[@"token_type"];
        _accessToken = dict[@"access_token"];
        _expiresIn = [dict[@"expires_in"] integerValue];
        _refreshToken = dict[@"refresh_token"];
        _scope = [dict[@"scope"] componentsSeparatedByString:@","];
    }
    return self;
}

+(instancetype)tokenWithDict:(NSDictionary *)dict{
    return [[self alloc]initWithDict:dict];
}
@end
