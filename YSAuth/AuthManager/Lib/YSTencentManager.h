//
//  YSTencentManager.h
//  YSAuth
//
//  Created by jiangys on 16/6/13.
//  Copyright © 2016年 jiangys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YSAuthManager.h"

#define QQAppID @"1104592420"

@interface YSTencentManager : NSObject

+ (BOOL)isAppInstalled;

+ (BOOL)handleOpenURL:(NSURL *)url;

+ (void)sendAuthWithBlock:(YSAuthBlock)result
             withUserInfo:(YSUserInfoBlock)block;

+ (BOOL)isUserInfo;
+ (NSString *)getUserName;
+ (NSString *)getUserAvatar;

@end
