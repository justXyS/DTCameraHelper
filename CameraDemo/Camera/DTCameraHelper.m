//
//  DTCameraHelper.m
//  xllive
//
//  Created by xiaoyuan on 16/5/5.
//  Copyright © 2016年 XunLei. All rights reserved.
//

#import "DTCameraHelper.h"
#import "DTTailorViewController.h"

#define kScreenWidth [UIScreen mainScreen].bounds.size.width

@interface DTCameraHelper ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, weak) UIImagePickerController *pick;
@property (weak, nonatomic) IBOutlet UIButton *exchangeCameraDeviceButton;

@end

@implementation DTCameraHelper


- (instancetype)init {
    if (self = [super init]) {
        _allowEditingImage = YES;
        _systemType = YES;
        _size = CGSizeMake(kScreenWidth, kScreenWidth);
    }

    return self;
}

#pragma mark - ImagePicker Show

- (void)showImagePickerForCamera {
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        if ([_delegate respondsToSelector:@selector(cameraHelper:presentImagePickController:error:)]) {
            [_delegate cameraHelper:self presentImagePickController:nil error:@"请检查相机隐私设置"];
        }
    } else {
        [self showImagePickerForSourceType:UIImagePickerControllerSourceTypeCamera];
    }
}

- (void)showImagePickerForPhotoPicker {
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        if ([_delegate respondsToSelector:@selector(cameraHelper:presentImagePickController:error:)]) {
            [_delegate cameraHelper:self presentImagePickController:nil error:@"请检查相册隐私设置"];
        }
    } else {
        [self showImagePickerForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }
}

- (void)showImagePickerForSourceType:(UIImagePickerControllerSourceType)sourceType {
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];

    imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
    imagePickerController.sourceType = sourceType;
    imagePickerController.delegate = self;
    imagePickerController.allowsEditing = _systemType;

    if (sourceType == UIImagePickerControllerSourceTypeCamera) {
        if (!_systemType) {
            imagePickerController.showsCameraControls = NO;
            UIView *ov = [[[NSBundle mainBundle] loadNibNamed:@"DTCameraOverlayView" owner:self options:nil] firstObject];
            ov.frame = imagePickerController.cameraOverlayView.frame;
            ov.backgroundColor = [UIColor clearColor];
            imagePickerController.cameraOverlayView = ov;
        }

        if ([self isFrontCameraAvailable]) {
            [imagePickerController setCameraDevice:UIImagePickerControllerCameraDeviceFront];
        } else {
            self.exchangeCameraDeviceButton.hidden = YES;
        }
    }

    if ([_delegate respondsToSelector:@selector(cameraHelper:willPresentImagePickController:)]) {
        [_delegate cameraHelper:self willPresentImagePickController:imagePickerController];
    }

    self.pick = imagePickerController;

    [self.proxyVc presentViewController:imagePickerController animated:YES completion:NULL];
}

- (BOOL)isFrontCameraAvailable {
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront];
}

- (void)dismissPickerController:(UIImagePickerController *)pickerController {
    if ([_delegate respondsToSelector:@selector(cameraHelper:willDismissImagePickController:)]) {
        [_delegate cameraHelper:self willDismissImagePickController:pickerController];
    }

    [pickerController dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Internal Image logics

- (UIImage *)createThumbnailImage:(UIImage *)srcImage {
    CGRect rect = CGRectZero;
    UIImage *thumbImg = nil;

    if ((srcImage.size.width * srcImage.size.height) > (1242 * 1242)) {
        @autoreleasepool {
            if (srcImage.size.width > srcImage.size.height) {
                rect.size.width = 1242.0;
                rect.size.height = srcImage.size.height * (rect.size.width / srcImage.size.width);
            } else {
                rect.size.height = 1242.0;
                rect.size.width = srcImage.size.width * (rect.size.height / srcImage.size.height);
            }

            UIGraphicsBeginImageContext(rect.size);
            [srcImage drawInRect:rect];
            thumbImg = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
    } else {
        thumbImg = srcImage;
    }

    return thumbImg;
}

#pragma mark - Internal Image logics UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *originImage = [info valueForKey:UIImagePickerControllerOriginalImage];

    if (!_systemType && self.allowEditingImage) {
        DTTailorViewController *tailor = [[DTTailorViewController alloc] init];
        tailor.size = self.size;
        tailor.image = originImage;
        tailor.circleInSize = self.circleInSize;
        tailor.onCancel = ^{
            [UIApplication sharedApplication].statusBarHidden = NO;
            [picker popViewControllerAnimated:(picker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary)];
        };
        __weak typeof(self) weakSelf = self;
        tailor.onChoose = ^(UIImage *image) {
            typeof(weakSelf) self = weakSelf;
            if ([_delegate respondsToSelector:@selector(cameraHelper:imagePickerController:didFinishPickingMediaWithEditImage:)]) {
                [_delegate cameraHelper:self imagePickerController:picker didFinishPickingMediaWithEditImage:[self createThumbnailImage:image]];
            }

            if ([_delegate respondsToSelector:@selector(cameraHelper:willDismissImagePickController:)]) {
                [_delegate cameraHelper:self willDismissImagePickController:picker];
            }

            [self.pick dismissViewControllerAnimated:YES completion:^{
                [UIApplication sharedApplication].statusBarHidden = NO;
            }];
        };
        [picker pushViewController:tailor animated:(picker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary)];
    } else {
        if (picker.allowsEditing) {
            originImage = [info valueForKey:UIImagePickerControllerEditedImage];
        }

        if ([_delegate respondsToSelector:@selector(cameraHelper:imagePickerController:didFinishPickingMediaWithEditImage:)]) {
            [_delegate cameraHelper:self imagePickerController:picker didFinishPickingMediaWithEditImage:[self createThumbnailImage:originImage]];
        }

        [self dismissPickerController:picker];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissPickerController:picker];
}

- (IBAction)takePhoto:(id)sender {
    [self.pick takePicture];
}

- (IBAction)cancel:(id)sender {
    [self dismissPickerController:self.pick];
}

- (IBAction)exchangeCameraDevice:(id)sender {
    __weak typeof(self) weakSelf = self;
    [UIView transitionWithView:self.pick.view
                      duration:1.0
                       options:UIViewAnimationOptionAllowAnimatedContent | UIViewAnimationOptionTransitionFlipFromLeft
                    animations:^{
        __weak typeof(weakSelf) self = weakSelf;
        if (self.pick.cameraDevice == UIImagePickerControllerCameraDeviceFront) {
            self.pick.cameraDevice = UIImagePickerControllerCameraDeviceRear;
        } else {
            self.pick.cameraDevice = UIImagePickerControllerCameraDeviceFront;
        }
    }
                    completion:NULL];
}

@end
