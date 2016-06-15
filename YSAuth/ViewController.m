//
//  ViewController.m
//  YSAuth
//
//  Created by jiangys on 16/6/13.
//  Copyright © 2016年 jiangys. All rights reserved.
//

#import "ViewController.h"
#import "YSAuthManager.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UIButton *wechatButton = [UIButton buttonWithType:UIButtonTypeCustom];
    wechatButton.frame = CGRectMake(50, 50, 100, 30);
    [wechatButton setTitle:@"微信登录" forState:UIControlStateNormal];
    [wechatButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [wechatButton addTarget:self action:@selector(tencentBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:wechatButton];
    
    UIButton *wechatShareButton = [UIButton buttonWithType:UIButtonTypeCustom];
    wechatShareButton.frame = CGRectMake(50, 100, 100, 30);
    [wechatShareButton setTitle:@"微信分享" forState:UIControlStateNormal];
    [wechatShareButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [wechatShareButton addTarget:self action:@selector(wechatShare) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:wechatShareButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)wechatLogin {
    if ([YSAuthManager isAppInstalled:YSAuthWechat]) {
        __weak typeof(self) weakself = self;
        [YSAuthManager sendAuthType:YSAuthWechat withBlock:^(BOOL isOK, NSString *openID, NSString *unionID) {
            [weakself login:isOK withInfo:openID withType:@"weixin" unionID:unionID];
        } withUserInfo:^(NSString *userName, NSString *userAvatar) {
            [weakself showUserInfo:userName withAvatar:userAvatar];
        }];
    }
    else {
        [self setupAlertController];
    }
}

- (void)wechatShare
{
    [YSAuthManager shareWithType:YSShareTypeWechatFirend
                           title:@"好东西测试分享"
                     description:@""
                           thumb:nil
                             url:@"好东西测试分享好东西测试分享好东西测试分享"
                          result:^(NSError *error) {
                              
                              
                          }];
}

- (void)tencentBtnClick
{
    // 如果不判断安装，没安装会自动弹出SDK自带的Webview进行授权
    if ([YSAuthManager isAppInstalled:YSAuthTencent]) {
        
    __weak typeof(self) weakself = self;
    [YSAuthManager sendAuthType:YSAuthTencent
                      withBlock:^(BOOL isOK, NSString *openID, NSString *unionID) {
                          [weakself login:isOK withInfo:openID withType:@"qq" unionID:unionID];
                      }
                   withUserInfo:^(NSString *userName, NSString *userAvatar) {
                       [weakself showUserInfo:userName withAvatar:userAvatar];
                   }];
        } else {
            // 嵌入式输入账号密码模式
        }
}

#pragma mark - 设置弹出提示语
- (void)setupAlertController {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"请先安装微信客户端" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *actionConfirm = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:actionConfirm];
    [self presentViewController:alert animated:YES completion:nil];
}


#pragma mark -
//- (void)showUserInfo:(NSString *)userName withAvatarImg:(UIView *)userAvatar
//{
//    _nameLbl.text = userName;
//    [self.view addSubview:userAvatar];
//    //[_avatarImg setImage:userAvatar];
//}


- (void)showUserInfo:(NSString *)userName withAvatar:(NSString *)userAvatar
{
    NSLog(@"userName------%@---userAvatar--%@",userName,userAvatar);
    //[_avatarImg setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:userAvatar]]]];
}

- (void)login:(BOOL)isOK withInfo:(NSString *)openID withType:(NSString *)type unionID:(NSString *)unionID
{
    if (isOK) {
        NSLog(@"-openID-----%@---type--%@---unionID--%@",openID,type,unionID);
        // 可以登录了，结合后端给的链接，走后面的流程
    } else {
        // 错误提示
    }
}

- (void)login:(NSString *)openID withType:(NSString *)type unionID:(NSString *)unionID
{

}
@end
