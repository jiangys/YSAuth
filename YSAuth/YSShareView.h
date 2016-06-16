//
//  YSShareView.h
//  YSAuth
//
//  Created by jiangys on 16/6/16.
//  Copyright © 2016年 jiangys. All rights reserved.
//

#import <UIKit/UIKit.h>
// 一页中最多2行
#define ShareMaxRows 2
// 一行中最多4列
#define ShareMaxCols 4
// 每一页的表情个数
#define SharePageSize (ShareMaxRows * ShareMaxCols)

@protocol YSShareViewDelegate <NSObject>

@optional
- (void)shareViewDidSelectTag:(NSInteger)selectTag;

@end

@interface YSShareView : UIView
/** 这一页显示的表情（里面都是HWShare模型） */
@property (nonatomic, strong) NSArray *shareItemArray;

@property (nonatomic, strong) id<YSShareViewDelegate> delegate;

- (void)showShareView;
- (void)hideShareView;

@end
