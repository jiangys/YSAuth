//
//  YSTencentManager.m
//  YSAuth
//
//  Created by jiangys on 16/6/13.
//  Copyright © 2016年 jiangys. All rights reserved.
//

#import "YSTencentManager.h"
#import <TencentOpenAPI/TencentApiInterface.h>
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/QQApiInterfaceObject.h>
#import <TencentOpenAPI/QQApiInterface.h>

@interface YSTencentManager() <TencentSessionDelegate>

@property (nonatomic, assign) BOOL isOK;
@property (nonatomic, copy) NSString *nickName;
@property (nonatomic, copy) NSString *iconUrl;

@property (nonatomic, copy) YSAuthBlock respBlcok;
@property (nonatomic, copy) YSUserInfoBlock userInfoBlcok;

@property (strong, nonatomic) TencentOAuth *tencentOAuth;

@end

@implementation YSTencentManager

+ (instancetype)manager
{
    static id manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[YSTencentManager alloc] init];
    });
    return manager;
}

+ (BOOL)isAppInstalled
{
    if (([TencentOAuth iphoneQQInstalled] && [TencentOAuth iphoneQQSupportSSOLogin])
        || ([TencentOAuth iphoneQZoneInstalled] && [TencentOAuth iphoneQZoneSupportSSOLogin])) {
        return TRUE;
    }
    return FALSE;
}

+ (void)sendAuthWithBlock:(YSAuthBlock)result
             withUserInfo:(YSUserInfoBlock)block
{
    YSTencentManager *manager = [YSTencentManager manager];
    manager.respBlcok = result;
    manager.userInfoBlcok = block;
    
    // permissions 设置应用需要用户授权的API列表
    NSArray *permissions = [NSArray arrayWithObjects:kOPEN_PERMISSION_GET_SIMPLE_USER_INFO,
                            kOPEN_PERMISSION_ADD_SHARE,nil];
    [manager.tencentOAuth authorize:permissions];
}

+ (BOOL)handleOpenURL:(NSURL *)url
{
    return [TencentOAuth HandleOpenURL:url];
}

+ (BOOL)isUserInfo
{
    YSTencentManager *manager = [YSTencentManager manager];
    return manager.isOK;
}

+ (NSString *)getUserName
{
    YSTencentManager *manager = [YSTencentManager manager];
    return manager.nickName;
}

+ (NSString *)getUserAvatar
{
    YSTencentManager *manager = [YSTencentManager manager];
    return manager.iconUrl;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.tencentOAuth = [[TencentOAuth alloc] initWithAppId:QQAppID andDelegate:self];
    }
    return self;
}

#pragma mark - TencentLoginDelegate
- (void)tencentDidLogin
{
    if (_tencentOAuth.accessToken && 0 != [_tencentOAuth.accessToken length]) {
        if (self.respBlcok) {
            self.respBlcok(YES, [_tencentOAuth openId], @"0");
        }
        [_tencentOAuth getUserInfo];
    } else {
        if (self.respBlcok) {
            self.respBlcok(NO, @"QQ登录失败", @"0");
        }
    }
}

- (void)tencentDidNotLogin:(BOOL)cancelled
{
    if (cancelled) {
        if (self.respBlcok) {
            self.respBlcok(NO, @"用户取消QQ登录", @"0");
        }
    } else {
        if (self.respBlcok) {
            self.respBlcok(NO, @"QQ登录失败", @"0");
        }
    }
}

- (void)tencentDidNotNetWork
{
    if (self.respBlcok) {
        self.respBlcok(NO, @"无网络连接，请设置网络", @"0");
    }
}

- (void)getUserInfoResponse:(APIResponse *)response
{
    if (response.retCode == URLREQUEST_SUCCEED) {
        self.isOK = TRUE;
        self.nickName = [response.jsonResponse objectForKey:@"nickname"];
        self.iconUrl = [response.jsonResponse objectForKey:@"figureurl_qq_2"];
        if (self.userInfoBlcok) {
            self.userInfoBlcok(self.nickName, self.iconUrl);
        }
    }
}

+ (void)shareQQChat:(NSString *)title
        description:(NSString *)description
              thumb:(UIImage *)image
                url:(NSString *)url
             result:(YSShareBlock)result
{
    //    if (![TencentOAuth iphoneQQInstalled])
    //    {
    //        [ProgressHUD showError:@"没有安装QQ,无法分享"];
    //        return ;
    //    }
    ;
    NSData *data = UIImagePNGRepresentation(image);
    QQApiURLObject *urlObj = [[QQApiURLObject alloc] initWithURL:[NSURL URLWithString:url]
                                                           title:title
                                                     description:description
                                                previewImageData:data
                                               targetContentType:QQApiURLTargetTypeNews];
    
    SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:urlObj];
    [QQApiInterface sendReq:req];
}


+ (void)shareQQZone:(NSString *)title
        description:(NSString *)description
              thumb:(UIImage *)image
                url:(NSString *)url
             result:(YSShareBlock)result
{
    NSData *data = UIImagePNGRepresentation(image);
    QQApiURLObject *urlObj = [[QQApiURLObject alloc] initWithURL:[NSURL URLWithString:url]
                                                           title:title
                                                     description:description
                                                previewImageData:data
                                               targetContentType:QQApiURLTargetTypeNews];
    SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:urlObj];
    [QQApiInterface SendReqToQZone:req];
}
@end

