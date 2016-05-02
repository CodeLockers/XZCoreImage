//
//  ViewController.m
//  RealTimeFilter
//
//  Created by 徐章 on 16/5/2.
//  Copyright © 2016年 徐章. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
@interface ViewController ()<AVCaptureVideoDataOutputSampleBufferDelegate,AVCaptureMetadataOutputObjectsDelegate>
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) CALayer *previewLayer;
@property (nonatomic, strong) CIFilter *filter;
@property (nonatomic, strong) CIContext *context;
@property (nonatomic, strong) AVMetadataObject *faceObject;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.previewLayer = [CALayer layer];
    self.previewLayer.bounds = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
    self.previewLayer.position = CGPointMake([UIScreen mainScreen].bounds.size.width/2.f, [UIScreen mainScreen].bounds.size.height/2.0f);
    self.previewLayer.borderColor = [UIColor redColor].CGColor;
    self.previewLayer.borderWidth = 1.0f;
    self.previewLayer.affineTransform = CGAffineTransformMakeRotation(M_PI/2.0);
    [self.view.layer insertSublayer:self.previewLayer atIndex:0];
    
    [self setUpCaptureSession];
    
    
    UIButton *openBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 300, 100, 40)];
    [openBtn setTitle:@"打开相机" forState:UIControlStateNormal];
    openBtn.backgroundColor = [UIColor redColor];
    [openBtn addTarget:self action:@selector(openBtn_Pressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:openBtn];
    
    
    UIButton *fanseBtn = [[UIButton alloc] initWithFrame:CGRectMake(250, 300, 100, 40)];
    [fanseBtn setTitle:@"反色" forState:UIControlStateNormal];
    fanseBtn.backgroundColor = [UIColor redColor];
    [fanseBtn addTarget:self action:@selector(fanseBtn_Pressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:fanseBtn];
    
    UIButton *danseBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 350, 100, 40)];
    [danseBtn setTitle:@"单色" forState:UIControlStateNormal];
    danseBtn.backgroundColor = [UIColor redColor];
    [danseBtn addTarget:self action:@selector(danseBtn_Pressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:danseBtn];
    
    UIButton *huaijiuBtn = [[UIButton alloc] initWithFrame:CGRectMake(250, 350, 100, 40)];
    [huaijiuBtn setTitle:@"怀旧" forState:UIControlStateNormal];
    huaijiuBtn.backgroundColor = [UIColor redColor];
    [huaijiuBtn addTarget:self action:@selector(huaijiuBtn_Pressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:huaijiuBtn];
    
    UIButton *suiyueBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 400, 100, 40)];
    [suiyueBtn setTitle:@"岁月" forState:UIControlStateNormal];
    suiyueBtn.backgroundColor = [UIColor redColor];
    [suiyueBtn addTarget:self action:@selector(suiyueBtn_Pressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:suiyueBtn];
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (CIContext *)context{
    
    if (!_context) {
        EAGLContext *eaglContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        NSDictionary *option = @{kCIContextWorkingColorSpace:[NSNull null]};
        return [CIContext contextWithEAGLContext:eaglContext options:option];
    }
    return _context;
}

- (void)setUpCaptureSession{
    
    self.captureSession = [[AVCaptureSession alloc] init];
    [self.captureSession beginConfiguration];
    
    self.captureSession.sessionPreset = AVCaptureSessionPresetHigh;
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    AVCaptureDeviceInput *captureDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:nil];
    if ([self.captureSession canAddInput:captureDeviceInput]) {
        [self.captureSession addInput:captureDeviceInput];
    }
    
    AVCaptureVideoDataOutput *captureVideoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
    captureVideoDataOutput.alwaysDiscardsLateVideoFrames = YES;
    if ([self.captureSession canAddOutput:captureVideoDataOutput]) {
        [self.captureSession addOutput:captureVideoDataOutput];
    }
    
    dispatch_queue_t queue = dispatch_queue_create("VideoQueue", DISPATCH_QUEUE_SERIAL);
    [captureVideoDataOutput setSampleBufferDelegate:self queue:queue];
    
    // 为了检测人脸
    AVCaptureMetadataOutput *metadataOutput = [[AVCaptureMetadataOutput alloc] init];
    [metadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    if ([self.captureSession canAddOutput:metadataOutput]) {
        
        [self.captureSession addOutput:metadataOutput];
        metadataOutput.metadataObjectTypes = @[AVMetadataObjectTypeFace];
    }
    
    [self.captureSession commitConfiguration];
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{
    
    /*不使用Core Image的方法
     CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
     CVPixelBufferLockBaseAddress(imageBuffer, 0);
     CGFloat width = CVPixelBufferGetWidthOfPlane(imageBuffer, 0);
     CGFloat height = CVPixelBufferGetHeightOfPlane(imageBuffer, 0);
     CGFloat bytesPerRow = CVPixelBufferGetBytesPerRowOfPlane(imageBuffer, 0);
     
     CGColorSpaceRef grayColorSpace = CGColorSpaceCreateDeviceGray();
     CGContextRef context = CGBitmapContextCreate(CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0), width, height, 8, bytesPerRow, grayColorSpace,kCGImageAlphaNone);
     CGImageRef cgImage = CGBitmapContextCreateImage(context);
     
     CGContextRelease(context);
     CGColorSpaceRelease(grayColorSpace);
     
     dispatch_sync(dispatch_get_main_queue(), ^{
     self.previewLayer.contents = (__bridge id _Nullable)(cgImage);
     CGImageRelease(cgImage);
     });
     */
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CIImage *outputImage = [CIImage imageWithCVPixelBuffer:imageBuffer];
    if (self.filter) {
        
        [self.filter setValue:outputImage forKey:kCIInputImageKey];
        outputImage = self.filter.outputImage;
    }
    
    if (self.faceObject) {
        
        outputImage = [self makeFaceWithCIImage:outputImage faceObject:self.faceObject];
    }
    
    CGImageRef cgImage = [self.context createCGImage:outputImage fromRect:outputImage.extent];
    dispatch_sync(dispatch_get_main_queue(), ^{
        self.previewLayer.contents = (__bridge id _Nullable)(cgImage);
        
        CGImageRelease(cgImage);
    });
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    
    if (metadataObjects.count > 0) {
        
        self.faceObject = metadataObjects.firstObject;
    }
}


#pragma mark - Private_Methods
- (CIImage *)makeFaceWithCIImage:(CIImage *)inputImage faceObject:(AVMetadataObject *)object{
    
    CIFilter *pixellateFilter = [CIFilter filterWithName:@"CIPixellate"];
    [pixellateFilter setValue:inputImage forKey:kCIInputImageKey];
    [pixellateFilter setValue:@(100) forKey:kCIInputScaleKey];
    
    
    CIImage *maskImage;
    CGRect faceBounds = object.bounds;
    
    CGFloat centerX = inputImage.extent.size.width * (faceBounds.origin.x + faceBounds.size.width / 2);
    CGFloat centerY = inputImage.extent.size.height * (1 - faceBounds.origin.y - faceBounds.size.height / 2);
    CGFloat radius = faceBounds.size.width * inputImage.extent.size.width / 2;
    
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
    
    
    CIFilter *blendFilter = [CIFilter filterWithName:@"CIBlendWithMask"];
    [blendFilter setValue:pixellateFilter.outputImage forKey:kCIInputImageKey];
    [blendFilter setValue:inputImage forKey:kCIInputBackgroundImageKey];
    [blendFilter setValue:maskImage forKey:kCIInputMaskImageKey];
    
    CIImage *outputImage = blendFilter.outputImage;
    
    return outputImage;
    
}

#pragma mark - UIButton_Action
- (IBAction)openBtn_Pressed:(UIButton *)sender {
    sender.enabled = NO;
    [self.captureSession startRunning];
    
}
- (IBAction)danseBtn_Pressed:(id)sender {
    self.filter = [CIFilter filterWithName:@"CIPhotoEffectInstant"];
}
- (IBAction)huaijiuBtn_Pressed:(id)sender {
    self.filter = [CIFilter filterWithName:@"CIPhotoEffectMono"];
}
- (IBAction)suiyueBtn_Pressed:(id)sender {
    self.filter = [CIFilter filterWithName:@"CIPhotoEffectTransfer"];
}
- (IBAction)fanseBtn_Pressed:(id)sender {
    self.filter = [CIFilter filterWithName:@"CIColorInvert"];
}
- (IBAction)takePhotoBtn_Pressed:(id)sender {
}

- (IBAction)recordBtn_Pressed:(id)sender {
}

@end