//
//  DTCameraHelper.h
//  xllive
//
//  Created by xiaoyuan on 16/5/5.
//  Copyright © 2016年 XunLei. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DTCameraHelperDelegate;
@interface DTCameraHelper : NSObject

@property (nonatomic, weak) id<DTCameraHelperDelegate> delegate;

@property (nonatomic, assign) BOOL systemType;

@property (nonatomic, assign) BOOL allowEditingImage;

/**
 * 裁剪照片区域
 */
@property (nonatomic, assign) CGSize size;

@property (nonatomic, assign) BOOL circleInSize;

@property (nonatomic, weak) UIViewController *proxyVc;

@property (nonatomic, copy) NSString *idetifier;

- (void)showImagePickerForCamera;

- (void)showImagePickerForPhotoPicker;

- (BOOL)isFrontCameraAvailable;

@end

@protocol DTCameraHelperDelegate<NSObject>

@optional
- (void)cameraHelper:(DTCameraHelper *)cameraHelper presentImagePickController:(UIImagePickerController *)imagePicker error:(NSString *)error;

- (void)cameraHelper:(DTCameraHelper *)cameraHelper willPresentImagePickController:(UIImagePickerController *)imagePicker;

- (void)cameraHelper:(DTCameraHelper *)cameraHelper willDismissImagePickController:(UIImagePickerController *)imagePicker;

- (void)cameraHelper:(DTCameraHelper *)cameraHelper imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithEditImage:(UIImage *)image;

@end
