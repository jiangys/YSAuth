//
//  YSAuthManager.h
//  YSAuth
//
//  Created by jiangys on 16/6/13.
//  Copyright © 2016年 jiangys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// 使用的是与或运算，可判断某个平台是否存在
// 1<<0 左移0位，相当于1.其它的相当于0，1，2，4，8
// 或运算时，如果存在，则返回true
typedef NS_OPTIONS(NSInteger, YSAuthType)
{
    YSAuthNone          = 0,
    YSAuthTencent       = 1 << 0,
    YSAuthWeibo         = 1 << 1,
    YSAuthWechat        = 1 << 2,
    
    YSAuthAll = YSAuthTencent | YSAuthWeibo | YSAuthWechat,
};

/**
 *  分享类型
 */
typedef NS_ENUM(NSInteger,YSShareType) {
    /** 分享到微信好友 */
    YSShareTypeWechatFirend,
    /** 分享到微信朋友圈 */
    YSShareTypeWechatFirends,
    /** 分享到QQ好友 */
    YSShareTypeQQChat,
    /** 分享到QQ空间 */
    YSShareTypeQQZone
};

// 登录回调block，成功返回TRUE和ID，失败返回FALSE和错误信息
typedef void(^YSAuthBlock)(BOOL isOK, NSString *openID, NSString *unionID);
// 获取用户信息回调，成功返回用户名和头像
typedef void(^YSUserInfoBlock)(NSString *userName, NSString *userAvatar);
// 分享
typedef void(^YSShareBlock)(NSError *error);

@interface YSAuthManager : NSObject

// 用户手机是否安装对应第三方
+ (BOOL)isAppInstalled:(YSAuthType)authType;

// 注册第三方
+ (void)registerApp:(YSAuthType)authType
        withOptions:(NSDictionary *)launchOptions;

// 第三方回调响应
+ (BOOL)handleOpenURL:(NSURL *)url
           annotation:(id)annotation;

// 发起对应第三方跳转登录
+ (void)sendAuthType:(YSAuthType)authType
           withBlock:(YSAuthBlock)result// 登录回调block，成功返回TRUE和ID，失败返回FALSE和错误信息
        withUserInfo:(YSUserInfoBlock)block;// 获取用户信息回调，成功返回用户名和头像

+ (BOOL)isUserInfo:(YSAuthType)authType;
+ (NSString *)getUserName:(YSAuthType)authType;
+ (NSString *)getUserAvatar:(YSAuthType)authType;

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
               result:(YSShareBlock)result;

@end
