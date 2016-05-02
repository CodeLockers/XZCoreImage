//
//  FilterCell.m
//  SampleFilter
//
//  Created by 徐章 on 16/4/20.
//  Copyright © 2016年 徐章. All rights reserved.
//

#import "FilterCell.h"

@interface FilterCell()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLab;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (strong, nonatomic) CIContext *context;
@end

@implementation FilterCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (CIContext *)context{
    
    if (!_context) {
        _context = [CIContext contextWithOptions:nil];
    }
    return _context;
}

- (void)setUpCellWithFilterName:(NSString *)filterName image:(UIImage *)image{

    self.indicator.hidden= NO;
    [self.indicator startAnimating];
    
    self.imageView.image = nil;
    
    CIImage *tmpImage = [[CIImage alloc] initWithImage:image];
    
    CIFilter *filter = [CIFilter filterWithName:filterName];
    self.nameLab.text = filterName;
    
    if ([filter.inputKeys containsObject:kCIInputImageKey]) {
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [filter setValue:tmpImage forKey:kCIInputImageKey];
            
            CIImage *tmpImage1 = filter.outputImage;
            
            CGImageRef imageRef = [self.context createCGImage:tmpImage1 fromRect:tmpImage1.extent];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.imageView.image = [UIImage imageWithCGImage:imageRef];
                self.indicator.hidden= YES;
                [self.indicator stopAnimating];
            });
            
            
        });
        
        

        
    }else{
    
        self.imageView.backgroundColor = [UIColor blackColor];
    }
}

@end
