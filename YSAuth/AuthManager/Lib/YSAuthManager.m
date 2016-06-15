//
//  YSAuthManager.m
//  YSAuth
//
//  Created by jiangys on 16/6/13.
//  Copyright © 2016年 jiangys. All rights reserved.
//

#import "YSAuthManager.h"
#import "YSWeChatManager.h"
#import "YSTencentManager.h"
#import "YSWeiboManager.h"

#define CheckAuthType(auth, type) ((auth & (type)) == (type))

static YSAuthType sAuthType;

@implementation YSAuthManager

+ (void)registerApp:(YSAuthType)authType
        withOptions:(NSDictionary *)launchOptions
{
    sAuthType = authType;
    if (CheckAuthType(sAuthType, YSAuthTencent)) {
    }
    if (CheckAuthType(sAuthType, YSAuthWeibo)) {
        [YSWeiboManager registerApp];
    }
    if (CheckAuthType(sAuthType, YSAuthWechat)) {
        [YSWechatManager registerApp];
    }
}

+ (BOOL)handleOpenURL:(NSURL *)url
           annotation:(id)annotation
{
    if (CheckAuthType(sAuthType, YSAuthTencent)) {
        if ([YSTencentManager handleOpenURL:url]) {
            return YES;
        }
    }
    if (CheckAuthType(sAuthType, YSAuthWeibo)) {
        if ([YSWeiboManager handleOpenURL:url]) {
            return YES;
        }
    }
    if (CheckAuthType(sAuthType, YSAuthWechat)) {
        if ([YSWechatManager handleOpenURL:url]) {
            return YES;
        }
    }
    return FALSE;
}

+ (BOOL)isAppInstalled:(YSAuthType)authType
{
    BOOL ret = NO;
    switch (authType) {
        case YSAuthTencent: {
            ret = [YSTencentManager isAppInstalled];
            break;
        }
        case YSAuthWeibo: {
            ret = [YSWeiboManager isAppInstalled];
            break;
        }
        case YSAuthWechat: {
            ret = [YSWechatManager isAppInstalled];
            break;
        }
        default:break;
    }
    return ret;
}

+ (void)sendAuthType:(YSAuthType)authType
           withBlock:(YSAuthBlock)result
        withUserInfo:(YSUserInfoBlock)block
{
    switch (authType) {
        case YSAuthTencent: {
            [YSTencentManager sendAuthWithBlock:result withUserInfo:block];
            break;
        }
        case YSAuthWeibo: {
            //[YSWeiboManager sendAuthWithBlock:result withUserInfo:block];
            break;
        }
        case YSAuthWechat: {
            [YSWechatManager sendAuthWithBlock:result withUserInfo:block];
            break;
        }
        default:break;
    }
}

+ (BOOL)isUserInfo:(YSAuthType)authType
{
    BOOL ret = FALSE;
    switch (authType) {
        case YSAuthTencent: {
            //ret = [YSTencentManager isUserInfo];
            break;
        }
        case YSAuthWeibo: {
            //ret = [YSWeiboManager isUserInfo];
            break;
        }
        case YSAuthWechat: {
            ret = [YSWechatManager isUserInfo];
            break;
        }
        default:break;
    }
    return ret;
}

+ (NSString *)getUserName:(YSAuthType)authType
{
    NSString *ret = nil;
    switch (authType) {
        case YSAuthTencent: {
            //ret = [YSTencentManager getUserName];
            break;
        }
        case YSAuthWeibo: {
            //ret = [YSWeiboManager getUserName];
            break;
        }
        case YSAuthWechat: {
            ret = [YSWechatManager getUserName];
            break;
        }
        default:break;
    }
    return ret;
}

+ (NSString *)getUserAvatar:(YSAuthType)authType
{
    NSString *ret = nil;
    switch (authType) {
        case YSAuthTencent: {
            //ret = [YSTencentManager getUserAvatar];
            break;
        }
        case YSAuthWeibo: {
            //ret = [YSWeiboManager getUserAvatar];
            break;
        }
        case YSAuthWechat: {
            ret = [YSWechatManager getUserAvatar];
            break;
        }
        default:break;
    }
    return ret;
}

/**
 *  分享
 *
 *  @param YSShareType 分享类型，YSShareType枚举
 *  @param title       分享标题
 *  @param description 分享内容
 *  @param image       链接显示图片
 *  @param url         点击跳转链接
 *  @param result      分享结果，成功返回nil，失败返回error内容
 */
+ (void)shareWithType:(YSShareType)shareType
                title:(NSString *)title
          description:(NSString *)description
                thumb:(UIImage *)image
                  url:(NSString *)url
               result:(YSShareBlock)result
{
    switch (shareType) {
        case YSShareTypeWechatFirend: {
            [YSWechatManager shareFirend:title description:description thumb:image url:url result:result];
            break;
        }
        case YSShareTypeWechatFirends: {
            [YSWechatManager shareFirends:title description:description thumb:image url:url result:result];
            break;
        }
        default:break;
    }
}

@end
