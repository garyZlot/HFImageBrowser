//
//  HFImageBrowser.m
//  dailylife
//
//  Created by liuguangde on 15/10/23.
//
//

#import "HFImageBrowser.h"

@interface HFImageBrowser ()
{
    CGRect oldframe;
    UIView *containerView;
    UIActionSheet *actionSheet;
    
    CGFloat originWidth;
    CGPoint originCenter;
    
    CGFloat scaleToZoomIn;
}

@end


@implementation HFImageBrowser

+ (id)sharedInstance
{
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (void)setBrowseImageView:(UIImageView *)imageView
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showImage:)];
    [imageView setUserInteractionEnabled:YES];
    [imageView addGestureRecognizer:tap];
}

- (void)showImage:(UITapGestureRecognizer *)tapRecognizer
{
    scaleToZoomIn = 1.5;
    UIImageView *imageView = (UIImageView *)tapRecognizer.view;
    
    float screenWidth = [UIScreen mainScreen].bounds.size.width;
    float screenHeight = [UIScreen mainScreen].bounds.size.height;
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    backgroundView.backgroundColor = [UIColor blackColor];
    backgroundView.alpha = 0;
    [window addSubview:backgroundView];
    containerView = backgroundView;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideImage)];
    [containerView addGestureRecognizer:tap];
    
    UIImage *image = imageView.image;
    oldframe = [imageView convertRect:imageView.bounds toView:window];
    
    UIImageView *newImageView = [[UIImageView alloc] initWithFrame:oldframe];
    newImageView.image = image;
    newImageView.tag = 110;
    [containerView addSubview:newImageView];
    
    [newImageView setUserInteractionEnabled:YES];
    [newImageView setMultipleTouchEnabled:YES];
    [self addGestureRecognizerToView:newImageView];

    [UIView animateWithDuration:0.3 animations:^{
        float scale = screenWidth/image.size.width; //保持图片正常比例
        float imgViewHeight = image.size.height * scale;
        newImageView.frame = CGRectMake(0, (screenHeight - imgViewHeight)/2, screenWidth, imgViewHeight);
        containerView.alpha = 1;
    } completion:^(BOOL finished) {
        originWidth = newImageView.frame.size.width;
        originCenter = newImageView.center;
    }];
}

- (void)addGestureRecognizerToView:(UIView *)view
{
    // 点击手势/双击放大
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideImage)];
    singleTap.numberOfTapsRequired = 1;
    [view addGestureRecognizer:singleTap];
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doDoubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    [view addGestureRecognizer:doubleTap];
    
    [singleTap requireGestureRecognizerToFail:doubleTap];
    
    // 旋转手势
    UIRotationGestureRecognizer *rotationGestureRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotateView:)];
    [view addGestureRecognizer:rotationGestureRecognizer];
    
    // 缩放手势
    UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchView:)];
    [view addGestureRecognizer:pinchGestureRecognizer];
    
    // 移动手势
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panView:)];
    [view addGestureRecognizer:panGestureRecognizer];
    
    // 长按手势
    UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressView:)];
    [view addGestureRecognizer:longPressGestureRecognizer];
}

// 处理双击手势
- (void)doDoubleTap:(UITapGestureRecognizer *)tapGestureRecognizer
{
    if (tapGestureRecognizer.state == UIGestureRecognizerStateRecognized) {
        UIView *view = tapGestureRecognizer.view;
        if (view.frame.size.width > originWidth) {
            [self restoreView:view];
        } else {
            CGPoint tapPoint = [tapGestureRecognizer locationInView:view.superview];
            CGPoint centerPoint = view.center;
            CGFloat newCenterX = tapPoint.x - scaleToZoomIn * (tapPoint.x - centerPoint.x);
            CGFloat newCenterY = tapPoint.y - scaleToZoomIn * (tapPoint.y - centerPoint.y);
            [UIView animateWithDuration:0.2 animations:^{
                view.transform = CGAffineTransformMakeScale(scaleToZoomIn, scaleToZoomIn);
                view.center = CGPointMake(newCenterX, newCenterY);
            }];
        }
    }
}

// 处理旋转手势
- (void)rotateView:(UIRotationGestureRecognizer *)rotationGestureRecognizer
{
    UIView *view = rotationGestureRecognizer.view;
    if (rotationGestureRecognizer.state == UIGestureRecognizerStateBegan || rotationGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        view.transform = CGAffineTransformRotate(view.transform, rotationGestureRecognizer.rotation);
        [rotationGestureRecognizer setRotation:0];
    }
}

// 处理缩放手势
- (void)pinchView:(UIPinchGestureRecognizer *)pinchGestureRecognizer
{
    UIView *view = pinchGestureRecognizer.view;
    if (pinchGestureRecognizer.state == UIGestureRecognizerStateBegan || pinchGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        view.transform = CGAffineTransformScale(view.transform, pinchGestureRecognizer.scale, pinchGestureRecognizer.scale);
        pinchGestureRecognizer.scale = 1;
    }
    
    if (pinchGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        if (view.frame.size.width <= originWidth) {
            [UIView animateWithDuration:0.2 animations:^{
                [view setCenter:originCenter];
                view.transform = CGAffineTransformMakeScale(1.0, 1.0);
            }];
        }
        
    }
}

// 处理拖拉手势
- (void)panView:(UIPanGestureRecognizer *)panGestureRecognizer
{
    UIView *view = panGestureRecognizer.view;
    if (view.frame.size.width == originWidth) return;
    if (panGestureRecognizer.state == UIGestureRecognizerStateBegan || panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [panGestureRecognizer translationInView:view.superview];
        [view setCenter:(CGPoint){view.center.x + translation.x, view.center.y + translation.y}];
        [panGestureRecognizer setTranslation:CGPointZero inView:view.superview];
    }
}

// 处理长按手势
- (void)longPressView:(UILongPressGestureRecognizer *)longPressGestureRecognizer
{
    if (!actionSheet) {
        actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self
                                         cancelButtonTitle:@"取消" destructiveButtonTitle:nil
                                         otherButtonTitles:@"保存图片", nil];
        
    }
    if (!actionSheet.visible) [actionSheet showInView:containerView];
}

- (void)restoreView:(UIView *)view
{
    [UIView animateWithDuration:0.2 animations:^{
        [view setCenter:originCenter];
        view.transform = CGAffineTransformMakeScale(1.0, 1.0);
    }];
}

- (void)hideImage
{
    UIImageView *imageView = (UIImageView *)[containerView viewWithTag:110];
    [UIView animateWithDuration:0.3 animations:^{
        imageView.frame = oldframe;
        containerView.alpha = 0;
    } completion:^(BOOL finished) {
        [containerView removeFromSuperview];
    }];
}


#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex;
{
    switch (buttonIndex) {
       case 0: //保存
        {
            UIImageView *imgView = (UIImageView *)[containerView viewWithTag:110];
            UIImageWriteToSavedPhotosAlbum(imgView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
            break;
        }
       case 1: //取消
            break;
       default:
            break;
    }
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *) contextInfo
{
    if (error == nil) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"已存入手机相册"
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"确定", nil];
        [alert show];
        
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"保存失败"
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"确定", nil];
        [alert show];
    }
}

@end
