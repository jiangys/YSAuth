//
//  YSWeChatManager.m
//  YSAuth
//
//  Created by jiangys on 16/6/13.
//  Copyright © 2016年 jiangys. All rights reserved.
//

#import "YSWechatManager.h"
#import "WXApiObject.h"
#import "WXApi.h"
#import "YSNetwork.h"

@interface YSWechatManager() <WXApiDelegate>

@property (nonatomic, assign) BOOL isOK;
@property (nonatomic, copy) NSString *nickName;
@property (nonatomic, copy) NSString *iconUrl;

@property (nonatomic, copy) YSAuthBlock respBlock;
@property (nonatomic, copy) YSUserInfoBlock userInfoBlock;
@property (nonatomic, copy) YSShareBlock shareBlock;

@end

@implementation YSWechatManager

+ (instancetype)manager
{
    static id manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[YSWechatManager alloc] init];
    });
    return manager;
}

+ (BOOL)isAppInstalled
{
    return [WXApi isWXAppInstalled];
}

+ (void)registerApp
{
    if ([WXApi registerApp:WXAppKey withDescription:@"demo 2.0"]) {
        NSLog(@"WXApi registerApp OK");
    }
}

+ (void)sendAuthWithBlock:(YSAuthBlock)result
             withUserInfo:(YSUserInfoBlock)block
{
    YSWechatManager *manager = [YSWechatManager manager];
    manager.respBlock = result; // 给当前的respBlock赋值
    manager.userInfoBlock = block; // 给当前的userInfoBlock赋值
    
    SendAuthReq *req = [[SendAuthReq alloc] init];
    req.scope = @"snsapi_userinfo";
    req.state = @"413e6ad8cae81487d315780b0a6717c0";

    [WXApi sendReq:req];
    //[WXApi sendAuthReq:req viewController:viewController delegate:manager];
}

+ (BOOL)handleOpenURL:(NSURL *)url
{
    return [WXApi handleOpenURL:url delegate:[YSWechatManager manager]];
}

+ (BOOL)isUserInfo
{
    YSWechatManager *manager = [YSWechatManager manager];
    return manager.isOK;
}

+ (NSString *)getUserName
{
    YSWechatManager *manager = [YSWechatManager manager];
    return manager.nickName;
}

+ (NSString *)getUserAvatar
{
    YSWechatManager *manager = [YSWechatManager manager];
    return manager.iconUrl;
}

#pragma mark - WXApiDelegate

- (void)onReq:(BaseReq *)req
{
    NSLog(@"onReq");
}

- (void)onResp:(BaseResp *)resp
{
    if([resp isKindOfClass:[SendAuthResp class]]) {
        if (resp.errCode == WXSuccess) {
            // temp.state 慎重的话校验state
            [self getOpenIDNetwork:((SendAuthResp *)resp).code];
        } else {
            if (resp.errCode == WXErrCodeAuthDeny) {
                if (self.respBlock) {
                    self.respBlock(NO, @"用户拒绝微信授权", @"0");
                }
            } else if (resp.errCode == WXErrCodeUserCancel) {
                if (self.respBlock) {
                    self.respBlock(NO, @"用户取消微信授权", @"0");
                }
            } else {
                if (self.respBlock) {
                    self.respBlock(NO, @"微信授权失败", @"0");
                }
            }
        }
    } else if ([resp isKindOfClass:[SendMessageToWXResp class]]) {
        if (resp.errCode == WXSuccess) {
            if (self.shareBlock) {
                self.shareBlock(nil);
            }
        } else {
            NSError *error = [NSError errorWithDomain:@"微信分享失败" code:resp.errCode userInfo:nil];
            if (resp.errCode == WXErrCodeUserCancel) {
                error = [NSError errorWithDomain:@"用户取消微信分享" code:resp.errCode userInfo:nil];
            }
            if (self.shareBlock) {
                self.shareBlock(error);
            }
        }
    }
}

- (void)getOpenIDNetwork:(NSString *)code
{
    NSDictionary *postDic = @{@"appid" : WXAppKey,
                              @"secret" : WXSecret,
                              @"code" : code,
                              @"grant_type" : @"authorization_code"};
    __weak __typeof(self) weakself = self;
    [YSNetwork requestWithFullUrl:@"https://api.weixin.qq.com/sns/oauth2/access_token?" withParams:postDic andBlock:^(id data, NSError *error) {
        if (error) {
            if (weakself.respBlock) {
                weakself.respBlock(NO, @"微信授权失败，网络错误", @"0");
            }
        } else {
            // 优先解析错误码 {"errcode":40029,"errmsg":"invalid code"}
            if ([data objectForKey:@"errcode"]) {
                // 出现错误
                NSString *errmsg = [data objectForKey:@"errmsg"];
                if (weakself.respBlock) {
                    weakself.respBlock(NO, [NSString stringWithFormat:@"微信授权失败，%@", errmsg], @"0");
                }
            } else {
                //if (weakself.respBlcok) {
                //    weakself.respBlcok(YES, [data objectForKey:@"openid"], @"0");
                //}
                // 假如需要的是unionID
                [weakself getUnionIDWithOpenID:[data objectForKey:@"openid"]
                                         token:[data objectForKey:@"access_token"]];
                // 授权成功，取用户信息
                [self getUserInfo:[data objectForKey:@"openid"] andToken:[data objectForKey:@"access_token"]];
            }
        }
    }];
}

- (void)getUnionIDWithOpenID:(NSString *)openID token:(NSString *)token
{
    NSDictionary *postDic = @{@"access_token" : token,
                              @"openid" : openID};
    
    __weak __typeof(self) weakself = self;
    [YSNetwork requestWithFullUrl:@"https://api.weixin.qq.com/sns/userinfo?" withParams:postDic andBlock:^(id data, NSError *error) {
        if (error) {
            if (weakself.respBlock) {
                weakself.respBlock(NO, @"微信授权失败，网络错误", @"0");
            }
        } else {
            // 优先解析错误码 {"errcode":40029,"errmsg":"invalid code"}
            if ([data objectForKey:@"errcode"]) {
                // 出现错误
                NSString *errmsg = [data objectForKey:@"errmsg"];
                if (weakself.respBlock) {
                    weakself.respBlock(NO, [NSString stringWithFormat:@"微信授权失败，%@", errmsg], @"0");
                }
            } else {
                if (weakself.respBlock) {
                    weakself.respBlock(YES, [data objectForKey:@"openid"], [data objectForKey:@"unionid"]);
                }
            }
        }
    }];
}

- (void)getUserInfo:(NSString *)openid andToken:(NSString *)token
{
    NSDictionary *postDic = @{@"access_token" : token,
                              @"openid" : openid};
    __weak __typeof(self) weakself = self;
    [YSNetwork requestWithFullUrl:@"https://api.weixin.qq.com/sns/userinfo?" withParams:postDic andBlock:^(id data, NSError *error) {
        if (error) {
        } else {
            // 优先解析错误码 {"errcode":40029,"errmsg":"invalid code"}
            if ([data objectForKey:@"errcode"]) {
                // 出现错误
            } else {
                weakself.isOK = TRUE;
                weakself.nickName = [data objectForKey:@"nickname"];
                weakself.iconUrl = [data objectForKey:@"headimgurl"];
                if (weakself.userInfoBlock) {
                    weakself.userInfoBlock(weakself.nickName, weakself.iconUrl);
                }
            }
        }
    }];
}

#pragma mark - 分享

// 分享到朋友会话
+ (void)shareFirend:(NSString *)title
        description:(NSString *)description
              thumb:(UIImage *)image
                url:(NSString *)url
             result:(YSShareBlock)result
{
    [YSWechatManager share:title des:description thumb:image url:url isFriends:NO result:result];
}

// 分享到朋友圈
+ (void)shareFirends:(NSString *)title
         description:(NSString *)description
               thumb:(UIImage *)image
                 url:(NSString *)url
              result:(YSShareBlock)result
{
    [YSWechatManager share:title des:description thumb:image url:url isFriends:YES result:result];
}

+ (void)share:(NSString *)title
          des:(NSString *)description
        thumb:(UIImage *)image
          url:(NSString *)url
    isFriends:(BOOL)isFriends
       result:(YSShareBlock)result
{
    YSWechatManager *manager = [YSWechatManager manager];
    manager.shareBlock = result;
    
    WXMediaMessage *msg = [WXMediaMessage message];
    msg.title = title;
    msg.description = description;
    [msg setThumbImage:image];
    
    WXWebpageObject *webPage = [WXWebpageObject object];
    webPage.webpageUrl = url;
    msg.mediaObject = webPage;
    
    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = msg;
    if (isFriends) {
        req.scene = WXSceneTimeline;// 朋友圈
    } else {
        req.scene = WXSceneSession;// 好友
    }
    [WXApi sendReq:req];
}

@end
