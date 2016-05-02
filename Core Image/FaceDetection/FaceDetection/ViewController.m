//
//  ViewController.m
//  FaceDetection
//
//  Created by 徐章 on 16/5/1.
//  Copyright © 2016年 徐章. All rights reserved.
//

#import "ViewController.h"
#import <ImageIO/ImageIO.h>

@interface ViewController ()
@property (nonatomic, strong) UIImageView *imageView;
@property (strong, nonatomic) CIContext *context;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 20, 300, 200)];
    self.imageView.image = [UIImage imageNamed:@"1"];
    self.imageView.backgroundColor = [UIColor blackColor];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:self.imageView];
    
    UIButton *faceDetectionBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, 300, 100, 40)];
    [faceDetectionBtn addTarget:self action:@selector(faceDetectionBtn_Pressed) forControlEvents:UIControlEventTouchUpInside];
    [faceDetectionBtn setTitle:@"人脸检测" forState:UIControlStateNormal];
    faceDetectionBtn.backgroundColor = [UIColor redColor];
    [self.view addSubview:faceDetectionBtn];
    
    UIButton *mosaicBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, 400, 100, 40)];
    [mosaicBtn setTitle:@"马赛克" forState:UIControlStateNormal];
    [mosaicBtn addTarget:self action:@selector(mosaicBtn_Pressed) forControlEvents:UIControlEventTouchUpInside];
    mosaicBtn.backgroundColor = [UIColor redColor];
    [self.view addSubview:mosaicBtn];

    
    // Do any additional setup after loading the view, typically from a nib.
}

- (CIContext *)context{
    
    if (!_context) {
        _context = [CIContext contextWithOptions:nil];
    }
    return _context;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIButton_Actions
- (void)faceDetectionBtn_Pressed{
    
    CIImage *inputImage = [[CIImage alloc] initWithImage:self.imageView.image];
    CIDetector *detecor = [CIDetector detectorOfType:CIDetectorTypeFace
                                             context:self.context
                                             options:@{
                                                       CIDetectorAccuracy:CIDetectorAccuracyHigh
                                                       }];
    
    NSArray *array = [detecor featuresInImage:inputImage];
    
    CGSize inputImageSize = inputImage.extent.size;
    CGAffineTransform transform = CGAffineTransformIdentity;
    transform = CGAffineTransformScale(transform, 1, -1);
    transform = CGAffineTransformTranslate(transform, 0, -inputImageSize.height);
    
    for (CIFaceFeature *facefeature in array) {
        
        CGFloat scale = MIN(self.imageView.bounds.size.width / inputImageSize.width,
                            self.imageView.bounds.size.height / inputImageSize.height);
        CGFloat offsetX = (self.imageView.bounds.size.width - inputImageSize.width * scale) / 2;
        CGFloat offsetY = (self.imageView.bounds.size.height - inputImageSize.height * scale) / 2;
        
        CGRect faceViewBounds = CGRectApplyAffineTransform(facefeature.bounds, transform);
        
        CGAffineTransform scaleTransform = CGAffineTransformMakeScale(0.5, 0.5);
        faceViewBounds = CGRectApplyAffineTransform(faceViewBounds, scaleTransform);
        
        faceViewBounds.origin.x += offsetX;
        faceViewBounds.origin.y += offsetY;
        
        UIView *view = [[UIView alloc] initWithFrame:faceViewBounds];
        view.layer.borderWidth = 2.0f;
        view.layer.borderColor = [UIColor redColor].CGColor;
        [self.imageView addSubview:view];
        
    }
    
}

- (void)mosaicBtn_Pressed{

    CIFilter *pixellateFilter = [CIFilter filterWithName:@"CIPixellate"];
    CIImage *inputImage = [[CIImage alloc] initWithImage:self.imageView.image];
    [pixellateFilter setValue:inputImage forKey:kCIInputImageKey];
    
    CIDetector *detecor = [CIDetector detectorOfType:CIDetectorTypeFace
                                             context:self.context
                                             options:@{
                                                       CIDetectorAccuracy:CIDetectorAccuracyHigh
                                                       }];
    NSArray *array = [detecor featuresInImage:inputImage];
    CGSize inputImageSize = inputImage.extent.size;
    CGFloat scale = MIN(self.imageView.bounds.size.width / inputImageSize.width,
                        self.imageView.bounds.size.height / inputImageSize.height);
    
    CIImage *maskImage;
    for (CIFaceFeature *facefeature in array) {
        
        CGFloat centerX = facefeature.bounds.origin.x + facefeature.bounds.size.width / 2;
        CGFloat centerY = facefeature.bounds.origin.y + facefeature.bounds.size.height / 2;
        CGFloat radius = MIN(facefeature.bounds.size.width, facefeature.bounds.size.height)*scale;
        
        CIFilter *radialGradientFilter = [CIFilter filterWithName:@"CIRadialGradient"
                                        withInputParameters:@{
                                                              @"inputRadius0" : @(radius),
                                                              @"inputRadius1" : @(radius + 1),
                                                              @"inputColor0" : [CIColor colorWithRed:0 green:1 blue:0 alpha:1],
                                                              @"inputColor1" : [CIColor colorWithRed:0 green:0 blue:0 alpha:0],
                                                              kCIInputCenterKey : [CIVector vectorWithX:centerX Y:centerY]
                                                              }];
        CIImage *radialGradientOutputImage = [radialGradientFilter.outputImage imageByCroppingToRect:inputImage.extent];
        if (!maskImage)
            maskImage = radialGradientOutputImage;
        else
        {
            maskImage = [CIFilter filterWithName:@"CISourceOverCompositing"
                             withInputParameters:@{
                                                   kCIInputImageKey : radialGradientOutputImage,
                                                   kCIInputBackgroundImageKey : maskImage
                                                    }].outputImage;
        }
    }

    CIFilter *blendFilter = [CIFilter filterWithName:@"CIBlendWithMask"];
    [blendFilter setValue:pixellateFilter.outputImage forKey:kCIInputImageKey];
    [blendFilter setValue:inputImage forKey:kCIInputBackgroundImageKey];
    [blendFilter setValue:maskImage forKey:kCIInputMaskImageKey];
    
    CIImage *outputImage = blendFilter.outputImage;
    CGImageRef cgImage = [self.context createCGImage:outputImage fromRect:inputImage.extent];
    self.imageView.image = [UIImage imageWithCGImage:cgImage];
    
    
}

@end
