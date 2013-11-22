//
//  ApplicationCollectionCell.h
//  LongYuanDigest
//
//  Created by 龙源 on 13-10-18.
//  Copyright (c) 2013年 longyuan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OWImageView, OWImageManager;

@interface OWCollectionViewCell : UICollectionViewCell
{
    OWImageView       *webImageView;
    IBOutlet UILabel           *titleLB;
}
@property (nonatomic, weak) OWImageManager *imageManager;

- (void)setImageURL:(NSString *)url;

@end
