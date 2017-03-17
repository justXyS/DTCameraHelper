//
//  DTTailorViewController.m
//  xllive
//
//  Created by xiaoyuan on 16/5/9.
//  Copyright © 2016年 XunLei. All rights reserved.
//

#import "DTTailorViewController.h"
#import "DTAreabreakOutView.h"

@interface DTTailorViewController ()<UIScrollViewDelegate> {
    DTAreabreakOutView *_bgView;
}

@property (nonatomic, weak) UIImageView *imageView;

@property (nonatomic, assign) CGRect tailArea;

@property (nonatomic, assign) CGSize contentSize;

@property (nonatomic, weak) UIScrollView *scrollView;

@end

@implementation DTTailorViewController

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpViews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - set up ui
- (void)setUpViews {
    self.view.backgroundColor = [UIColor blackColor];
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    self.navigationController.navigationBarHidden = YES;
    CGFloat contentHeight = screenSize.height - 64;

    if (self.navigationController.navigationBarHidden) {
        contentHeight += 64;
    }

    UIView *imageViewContainer = [[UIView alloc] initWithFrame:self.view.bounds];
    imageViewContainer.backgroundColor = [UIColor clearColor];
    [self.view addSubview:imageViewContainer];

    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, screenSize.width, contentHeight)];
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.bounces = YES;
    scrollView.delegate = self;
    [imageViewContainer addSubview:scrollView];
    self.scrollView = scrollView;

    CGFloat width = self.image.size.width > 0 ? self.image.size.width : CGFLOAT_MAX;
    CGFloat height = self.image.size.height;

    CGFloat imageViewHeight = screenSize.width / width * height;


    CGFloat y = 0;

    if (imageViewHeight < contentHeight) {
        y = (contentHeight - imageViewHeight) / 2;
    }

    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, y, screenSize.width, imageViewHeight)];
    imageView.contentMode = UIViewContentModeScaleToFill;
    imageView.image = self.image;

    [scrollView addSubview:imageView];
    scrollView.bounces = YES;
    scrollView.alwaysBounceVertical = YES;
    scrollView.alwaysBounceHorizontal = YES;
    scrollView.maximumZoomScale = 2.0;
    scrollView.minimumZoomScale = 1.0;
    self.imageView = imageView;

    //裁剪区域

    CGFloat tailW = _size.width > screenSize.width ? screenSize.width : _size.width;
    CGFloat tailH = _size.height > contentHeight - 60 ? contentHeight - 60 : _size.height;

    _size = CGSizeMake(tailW, tailH);

    CGRect frame = CGRectMake((screenSize.width - tailW) / 2, (contentHeight - tailH) / 2 - 60, tailW, tailH);
    self.tailArea = frame;

    UIView *bgViewContainer = [[UIView alloc] initWithFrame:self.view.bounds];
    bgViewContainer.backgroundColor = [UIColor clearColor];
    bgViewContainer.userInteractionEnabled = NO;
    _bgView = [[DTAreabreakOutView alloc] initWithFrame:self.view.bounds];
    _bgView.backgroundColor = [UIColor clearColor];
    _bgView.userInteractionEnabled = NO;
    _bgView.fillColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    [bgViewContainer addSubview:_bgView];
    [self.view addSubview:bgViewContainer];

    if (self.circleInSize) {
        UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:frame];
        _bgView.path = [path CGPath];
    } else {
        UIBezierPath *path = [UIBezierPath bezierPathWithRect:frame];
        _bgView.path = [path CGPath];
    }

    [_bgView setNeedsDisplay];

    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, contentHeight - 60, screenSize.width, 60)];
    toolBar.barStyle = UIBarStyleBlack;
    toolBar.barTintColor = [UIColor blackColor];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
    UIBarButtonItem *item1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *item2 = [[UIBarButtonItem alloc] initWithTitle:@"选取" style:UIBarButtonItemStylePlain target:self action:@selector(choose)];
    toolBar.items = @[item, item1, item2];
    [self.view addSubview:toolBar];

    [self refreshScrollContentSize];
}

- (void)refreshScrollContentSize {
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGFloat edgeT = (screenSize.height - _size.height) / 2;
    CGFloat edgeB = (screenSize.height - _size.height) / 2;

    //    CGFloat contentHeight = kScreenHeight;
    CGFloat width = self.image.size.width > 0 ? self.image.size.width : CGFLOAT_MAX;
    CGFloat height = self.image.size.height;
    CGFloat imageViewHeight = screenSize.width / width * height;

    if (imageViewHeight < screenSize.height) {
        edgeT -= (screenSize.height - imageViewHeight) / 2;
        edgeB += (screenSize.height - imageViewHeight) / 2;
    }

    if (self.scrollView.zoomScale == 1) {
        self.scrollView.contentSize = CGSizeMake(screenSize.width, imageViewHeight);
        self.scrollView.contentInset = UIEdgeInsetsMake(edgeT - 60, 0, edgeB + 60, 0);
    } else {
        CGSize s = self.scrollView.contentSize;
        float width = screenSize.height;
        CGSize c = self.imageView.image.size;
        float img_height = c.height * width / c.width;
        self.scrollView.contentSize = CGSizeMake(s.width, s.width / width * (img_height));
        self.scrollView.contentInset = UIEdgeInsetsMake(edgeT - 60, 0, edgeB + 60, 0);
    }
}

#pragma mark - scrollView delegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    [self refreshScrollContentSize];
}

#pragma mark - action
- (void)cancel {
    if (self.onCancel) {
        self.onCancel();
    }
}

- (void)choose {
    if (_bgView) {
        _bgView.hidden = YES;//去除蒙层
    }

    if (self.onChoose) {
        CGFloat scale = [UIScreen mainScreen].scale;
        UIImage *new = [self dt_imageWithView:self.view imageSize:self.view.bounds.size imageScale:scale];
        CGRect area = CGRectMake(self.tailArea.origin.x * scale, self.tailArea.origin.y * scale, self.tailArea.size.width * scale, self.tailArea.size.height * scale);
        CGImageRef cgImage = CGImageCreateWithImageInRect(new.CGImage, area);
        UIImage *newImage = [UIImage imageWithCGImage:cgImage];
        self.onChoose(newImage);
        
        CFRelease(cgImage);
    }
}

- (UIImage *)dt_imageWithView:(UIView *)view imageSize:(CGSize)imageSize imageScale:(CGFloat)imageScale {
    UIGraphicsBeginImageContextWithOptions(imageSize, view.opaque, imageScale);
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0f) {
        [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    } else {
        [view drawViewHierarchyInRect:CGRectMake(0, 0, imageSize.width, imageSize.height) afterScreenUpdates:YES];
    }
    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

@end
