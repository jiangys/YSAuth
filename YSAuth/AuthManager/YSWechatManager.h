//
//  YSWeChatManager.h
//  YSAuth
//
//  Created by jiangys on 16/6/13.
//  Copyright © 2016年 jiangys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YSAuthManager.h"

#define WXAppKey    @"wxfbfe01336f468525"
#define WXSecret    @"acc28b09efbb768a1b5b7b6514903ef8"

@interface YSWechatManager : NSObject

+ (BOOL)isAppInstalled;

+ (void)registerApp;

+ (BOOL)handleOpenURL:(NSURL *)url;

+ (void)sendAuthWithBlock:(YSAuthBlock)result
             withUserInfo:(YSUserInfoBlock)block;

+ (BOOL)isUserInfo;
+ (NSString *)getUserName;
+ (NSString *)getUserAvatar;

/**
 *  分享到微信好友
 */
+ (void)shareFirend:(NSString *)title
        description:(NSString *)description
              thumb:(UIImage *)image
                url:(NSString *)url
             result:(YSShareBlock)result;

/**
 *  分享到微信朋友圈
 */
+ (void)shareFirends:(NSString *)title
         description:(NSString *)description
               thumb:(UIImage *)image
                 url:(NSString *)url
              result:(YSShareBlock)result;

@end
