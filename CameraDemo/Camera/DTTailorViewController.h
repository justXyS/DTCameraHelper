//
//  DTTailorViewController.h
//  xllive
//
//  Created by xiaoyuan on 16/5/9.
//  Copyright © 2016年 XunLei. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * 裁剪照片控制器
 */
@interface DTTailorViewController : UIViewController

/**
 * 裁剪照片区域
 */
@property (nonatomic, assign) CGSize size;

@property (nonatomic, assign) BOOL circleInSize;

@property (nonatomic, copy) UIImage *image;

@property (nonatomic, copy) dispatch_block_t onCancel;

@property (nonatomic, copy) void (^ onChoose)(UIImage *image);

@end
