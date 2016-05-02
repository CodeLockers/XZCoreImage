//
//  CubeMap.h
//  ComplexFilter
//
//  Created by 徐章 on 16/5/1.
//  Copyright © 2016年 徐章. All rights reserved.
//

#ifndef CubeMap_h
#define CubeMap_h

#include <stdio.h>
struct CubeMap {
    int length;
    float dimension;
    float *data;
};
void rgbToHSV(float *rgb, float *hsv) ;
struct CubeMap createCubeMap(float minHueAngle, float maxHueAngle);
#endif /* CubeMap_h */
