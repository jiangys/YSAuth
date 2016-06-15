//
//  YSNetWork.h
//  YSAuth
//
//  Created by jiangys on 16/6/13.
//  Copyright © 2016年 jiangys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

typedef void(^YSNetworkBlock)(id data, NSError *error);

@interface YSNetwork : AFHTTPSessionManager

+ (id)sharedInstance;

+ (void)requestWithFullUrl:(NSString *)urlPath withParams:(NSDictionary *)params andBlock:(YSNetworkBlock)block;

@end
