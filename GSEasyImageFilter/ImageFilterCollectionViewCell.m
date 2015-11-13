//
//  ImageFilterCollectionViewCell.m
//  MyTest Hello
//
//  Created by liuguangsheng on 15/11/11.
//
//

#import "ImageFilterCollectionViewCell.h"

@implementation ImageFilterCollectionViewCell


-(id)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        
        _filterNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 130, 90, 20)];
        [_filterNameLabel setFont:[UIFont systemFontOfSize:15.0]];
        [_filterNameLabel setTextColor:[UIColor blackColor]];
        _filterNameLabel.textAlignment = NSTextAlignmentCenter;
        [self  addSubview:_filterNameLabel];
      
        _cellImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 90, 130)];
        _cellImageView.backgroundColor = [UIColor lightGrayColor];
        [self addSubview:_cellImageView];
        
    }
    return self;
}

@end
