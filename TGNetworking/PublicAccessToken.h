//
//  PublicAccessToken.h
//  TGNetworking
//
//  Created by Terwer Green on 15/8/31.
//  Copyright (c) 2015年 Terwer Green. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PublicAccessToken : NSObject

/**
 *  类型
 */
@property (nonatomic,copy,readonly) NSString *tokenType;
/**
 *  token
 */
@property (nonatomic,copy,readonly) NSString *accessToken;
/**
 *  过期时间
 */
@property (nonatomic,assign,readonly) NSInteger expiresIn;
/**
 *  刷新token
 */
@property (nonatomic,copy,readonly) NSString *refreshToken;
/**
 *  业务范围
 */
@property (nonatomic,strong,readonly) NSArray *scope;

-(instancetype)initWithDict:(NSDictionary *)dict;
+(instancetype)tokenWithDict:(NSDictionary *)dict;

@end
