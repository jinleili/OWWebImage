//
//  ApplicationCollectionCell.m
//  LongYuanDigest
//
//  Created by 龙源 on 13-10-18.
//  Copyright (c) 2013年 longyuan. All rights reserved.
//

#import "OWCollectionViewCell.h"
#import <OWWebImage/OWImageManager.h>
#import <OWWebImage/OWImageView.h>

@implementation OWCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    webImageView = [[OWImageView alloc] initWithFrame:self.bounds];
    [webImageView setCornerRadius:12];
    [webImageView setBorderColor:[UIColor grayColor]];
    [webImageView setBorderWidth:1];
    webImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.contentView addSubview:webImageView];
}

- (void)setImageURL:(NSString *)url;
{
    [webImageView setImageManager:self.imageManager];
    [webImageView setImageWithURLString:url];
}

@end
