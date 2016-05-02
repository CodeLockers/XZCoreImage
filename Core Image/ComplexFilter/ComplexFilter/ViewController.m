//
//  ViewController.m
//  ComplexFilter
//
//  Created by 徐章 on 16/5/1.
//  Copyright © 2016年 徐章. All rights reserved.
//

#import "ViewController.h"
#import "CIColorInvert.h"
#import "CubeMap.h"

@interface ViewController ()
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UISlider *slider;
@property (strong, nonatomic) CIContext *context;
@property (nonatomic, strong) CIFilter *filter;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"image"]];
    self.imageView.frame = CGRectMake(10, 20, 187, 229);
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:self.imageView];
    
    self.slider = [[UISlider alloc] initWithFrame:CGRectMake(20, 300, 280, 40)];
    [self.slider addTarget:self action:@selector(sliderValue_Changed:) forControlEvents:UIControlEventValueChanged];
    self.slider.maximumValue = M_PI;
    self.slider.minimumValue = -M_PI;
    [self.view addSubview:self.slider];
    
    CIImage *tmpImage = [[CIImage alloc] initWithImage:self.imageView.image];
    
    self.filter = [CIFilter filterWithName:@"CIHueAdjust"];
    
    [self.filter setValue:tmpImage forKey:kCIInputImageKey];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 400, 100, 40)];
    [button setTitle:@"老电影" forState:UIControlStateNormal];
    button.backgroundColor = [UIColor redColor];
    [button addTarget:self action:@selector(oldFilmBtn_Pressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    UIButton *button1 = [[UIButton alloc] initWithFrame:CGRectMake(0, 450, 100, 40)];
    [button1 setTitle:@"反色" forState:UIControlStateNormal];
    button1.backgroundColor = [UIColor redColor];
    [button1 addTarget:self action:@selector(invertBtn_Pressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button1];
    
    UIButton *button2 = [[UIButton alloc] initWithFrame:CGRectMake(0, 500, 100, 40)];
    [button2 setTitle:@"背景替换" forState:UIControlStateNormal];
    button2.backgroundColor = [UIColor redColor];
    [button2 addTarget:self action:@selector(beckgroundChange_Pressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button2];
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (CIContext *)context{
    
    if (!_context) {
        _context = [CIContext contextWithOptions:nil];
    }
    return _context;
}

#pragma mark - Button_Action
- (void)sliderValue_Changed:(UISlider *)slider{

    [self.filter setValue:@(slider.value) forKey:kCIInputAngleKey];
    
    CIImage *outputImage = self.filter.outputImage;
    
    CGImageRef cgImage = [self.context createCGImage:outputImage fromRect:outputImage.extent];
    self.imageView.image = [UIImage imageWithCGImage:cgImage];
}

- (void)oldFilmBtn_Pressed{
    
    CIImage *inputImage = [[CIImage alloc] initWithImage:self.imageView.image];
    // 1.创建CISepiaTone滤镜
    CIFilter *sepiaFilter = [CIFilter filterWithName:@"CISepiaTone"];
    [sepiaFilter setValue:inputImage forKey:kCIInputImageKey];
    [sepiaFilter setValue:@(1.0) forKey:kCIInputIntensityKey];
    
    // 2.创建白班图滤镜
    CIFilter *randomGenerator = [CIFilter filterWithName:@"CIRandomGenerator"];
    CIImage *ciimage1 = [randomGenerator.outputImage imageByCroppingToRect:inputImage.extent];
    
    CIFilter *whiteSpecksFilter = [CIFilter filterWithName:@"CIColorMatrix"];
    [whiteSpecksFilter setValue:ciimage1 forKey:kCIInputImageKey];
    [whiteSpecksFilter setValue:[CIVector vectorWithX:0 Y:1 Z:0 W:0] forKey:@"inputRVector"];
    [whiteSpecksFilter setValue:[CIVector vectorWithX:0 Y:1 Z:0 W:0] forKey:@"inputGVector"];
    [whiteSpecksFilter setValue:[CIVector vectorWithX:0 Y:1 Z:0 W:0] forKey:@"inputBVector"];
    [whiteSpecksFilter setValue:[CIVector vectorWithX:0 Y:0 Z:0 W:0] forKey:@"inputBiasVector"];
    
    // 3.把CISepiaTone滤镜和白班图滤镜以源覆盖(source over)的方式先组合起来
    CIFilter *sourceOverCompositingFilter = [CIFilter filterWithName:@"CISourceOverCompositing"];
    [sourceOverCompositingFilter setValue:whiteSpecksFilter.outputImage forKey: kCIInputBackgroundImageKey];
    [sourceOverCompositingFilter setValue:sepiaFilter.outputImage forKey: kCIInputImageKey];
    
    // 4.用CIAffineTransform滤镜先对随机噪点图进行处理
    CIFilter *affineTransformFilter = [CIFilter filterWithName:@"CIAffineTransform"];
    [affineTransformFilter setValue:ciimage1 forKey:kCIInputImageKey];
    [affineTransformFilter setValue:[NSValue valueWithCGAffineTransform:CGAffineTransformMakeScale(1.5, 25)] forKey:kCIInputTransformKey];
    
    // 5.创建蓝绿色磨砂图滤镜
    CIFilter *darkScratchesFilter = [CIFilter filterWithName:@"CIColorMatrix"];
    [darkScratchesFilter setValue:affineTransformFilter.outputImage forKey:kCIInputImageKey];
    [darkScratchesFilter setValue:[CIVector vectorWithX:4 Y:0 Z:0 W:0] forKey:@"inputRVector"];
    [darkScratchesFilter setValue:[CIVector vectorWithX:0 Y:0 Z:0 W:0] forKey:@"inputGVector"];
    [darkScratchesFilter setValue:[CIVector vectorWithX:0 Y:0 Z:0 W:0] forKey:@"inputBVector"];
    [darkScratchesFilter setValue:[CIVector vectorWithX:0 Y:0 Z:0 W:0] forKey:@"inputAVector"];
    [darkScratchesFilter setValue:[CIVector vectorWithX:0 Y:1 Z:1 W:1] forKey:@"inputBiasVector"];
    
    // 6.用CIMinimumComponent滤镜把蓝绿色磨砂图滤镜处理成黑色磨砂图滤镜
    CIFilter *minimumComponentFilter = [CIFilter filterWithName:@"CIMinimumComponent"];
    [minimumComponentFilter setValue:darkScratchesFilter.outputImage forKey:kCIInputImageKey];
     // 7.最终组合在一起
    CIFilter *multiplyCompositingFilter = [CIFilter filterWithName:@"CIMultiplyCompositing"];
    [multiplyCompositingFilter setValue:minimumComponentFilter.outputImage forKey:kCIInputBackgroundImageKey];
    [multiplyCompositingFilter setValue:sourceOverCompositingFilter.outputImage forKey:kCIInputImageKey];
    
    
    CIImage *outputImage = multiplyCompositingFilter.outputImage;
    CGImageRef cgimage = [self.context createCGImage:outputImage fromRect:outputImage.extent];
    self.imageView.image = [UIImage imageWithCGImage:cgimage];
}

//反色
- (void)invertBtn_Pressed{

    CIColorInvert *colorInvertFilter = [[CIColorInvert alloc] init];
    CIImage *inputImage = [[CIImage alloc] initWithImage:self.imageView.image];
    colorInvertFilter.inputImage = inputImage;
    CIImage *outputImage = colorInvertFilter.outputImage;
    CGImageRef cgimage = [self.context createCGImage:outputImage fromRect:outputImage.extent];
    self.imageView.image = [UIImage imageWithCGImage:cgimage];
}

//背景替换
- (void)beckgroundChange_Pressed{
    
    self.imageView.image = [UIImage imageNamed:@"images copy"];
    
    struct CubeMap cubeMap = createCubeMap(60,90);
    NSData *data = [NSData dataWithBytesNoCopy:cubeMap.data length:data.length freeWhenDone:YES];
    
    CIFilter *colorCubeFilter =[CIFilter filterWithName:@"CIColorCube"];
    [colorCubeFilter setValue:@(cubeMap.dimension) forKey:@"inputCubeDimension"];
    [colorCubeFilter setValue:data forKey:@"inputCubeData"];
    CIImage *ciimage = [[CIImage alloc] initWithImage:self.imageView.image];
    [colorCubeFilter setValue:ciimage forKey:kCIInputImageKey];
    CIImage *outputImage = colorCubeFilter.outputImage;
    
    CIFilter *sourceOverCompositingFilter = [CIFilter filterWithName:@"CISourceOverCompositing"];
    [sourceOverCompositingFilter setValue:outputImage forKey:kCIInputImageKey];
    CIImage *ciimage2 = [[CIImage alloc] initWithImage:[UIImage imageNamed:@"Wharf_at_Southend_on_Sea_bigthumb copy"]];
    [sourceOverCompositingFilter setValue:ciimage2 forKey:kCIInputBackgroundImageKey];
    
    CIImage *outputImage1 = sourceOverCompositingFilter.outputImage;
    CGImageRef cgImage = [self.context createCGImage:outputImage fromRect:outputImage1.extent];
    self.imageView.image = [UIImage imageWithCGImage:cgImage];
}


@end
