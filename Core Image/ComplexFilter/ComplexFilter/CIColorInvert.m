//
//  CIColorInvert.m
//  ComplexFilter
//
//  Created by 徐章 on 16/5/1.
//  Copyright © 2016年 徐章. All rights reserved.
//

#import "CIColorInvert.h"

@implementation CIColorInvert

- (CIImage *)outputImage{

    CIImage *ciimge = [self valueForKey:kCIInputImageKey];
    
    if (ciimge) {
        
        CIFilter *filter = [CIFilter filterWithName:@"CIColorMatrix"
                                withInputParameters:@{
                                                      kCIInputImageKey:ciimge,
                                                      @"inputRVector":[CIVector vectorWithX:-1 Y:0 Z:0],
                                                      @"inputGVector":[CIVector vectorWithX:0 Y:-1 Z:0],
                                                      @"inputBVector":[CIVector vectorWithX:0 Y:0 Z:-1],
                                                      @"inputBiasVector":[CIVector vectorWithX:1 Y:1 Z:1],
                                                                              
                                                    }];
        return filter.outputImage;

    }
    return nil;
}

@end
