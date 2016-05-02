//
//  ViewController.m
//  SampleFilter
//
//  Created by 徐章 on 16/4/20.
//  Copyright © 2016年 徐章. All rights reserved.
//

#import "ViewController.h"
#import "FilterCell.h"

@interface ViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>{

    NSArray *_filterArray;
    UIImage *_image;
}
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.collectionView.delegate =self;
    self.collectionView.dataSource = self;
    [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([FilterCell class]) bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:NSStringFromClass([FilterCell class])];
    
    _filterArray = [CIFilter filterNamesInCategory:kCICategoryBuiltIn];
    _image = [UIImage imageNamed:@"image"];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{

    return 0.0f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    
    return 0.0f;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{

    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    
    return CGSizeMake(width/3.0f, (width/3.0f)*(65.0f/53.0f)+20.0f);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return _filterArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    FilterCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([FilterCell class]) forIndexPath:indexPath];
    
    [cell setUpCellWithFilterName:_filterArray[indexPath.row] image:_image];
    
    return cell;
}



@end
