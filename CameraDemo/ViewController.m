//
//  ViewController.m
//  CameraDemo
//
//  Created by xiaoyuan on 2017/3/17.
//  Copyright © 2017年 xiaoyuan. All rights reserved.
//

#import "ViewController.h"
#import "DTCameraHelper.h"

@interface ViewController ()<DTCameraHelperDelegate>

@property (nonatomic, strong) DTCameraHelper *cameraHelper;
@property (weak, nonatomic) IBOutlet UIImageView *pickImageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    UIAlertController *alertViewController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    __weak typeof(self) weakSelf = self;
    UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:@"相机" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        typeof(weakSelf) self = weakSelf;
        [self createCameraHelperWithType:YES];
    }];
    
    UIAlertAction *photoLibAction = [UIAlertAction actionWithTitle:@"相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        typeof(weakSelf) self = weakSelf;
        [self createCameraHelperWithType:NO];
    }];
    
    [alertViewController addAction:cameraAction];
    [alertViewController addAction:photoLibAction];
    [self.navigationController presentViewController:alertViewController animated:YES completion:nil];
}

- (void)createCameraHelperWithType:(BOOL)isCamera {
    DTCameraHelper *cameraHelper = [[DTCameraHelper alloc] init];
    cameraHelper.delegate = self;
    cameraHelper.proxyVc = self;
    cameraHelper.systemType = NO;
    if (isCamera) {
        [cameraHelper showImagePickerForCamera];
    } else {
        [cameraHelper showImagePickerForPhotoPicker];
    }
    self.cameraHelper = cameraHelper;
}

#pragma mark - DTCameraHelper Delegate
- (void)cameraHelper:(DTCameraHelper *)cameraHelper imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithEditImage:(UIImage *)image {
    self.pickImageView.image = image;
}

@end
