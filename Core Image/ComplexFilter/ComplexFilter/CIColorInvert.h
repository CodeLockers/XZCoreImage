//
//  CIColorInvert.h
//  ComplexFilter
//
//  Created by 徐章 on 16/5/1.
//  Copyright © 2016年 徐章. All rights reserved.
//

#import <CoreImage/CoreImage.h>

@interface CIColorInvert : CIFilter
@property (nonatomic, strong) CIImage *inputImage;
@end
