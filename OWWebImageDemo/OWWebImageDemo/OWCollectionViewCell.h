//
//  ApplicationCollectionCell.h
//  LongYuanDigest
//
//  Created by grenlight on 13-11-15.
//  Copyright (c) 2013年 OOWWWW. All rights reserved.
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
