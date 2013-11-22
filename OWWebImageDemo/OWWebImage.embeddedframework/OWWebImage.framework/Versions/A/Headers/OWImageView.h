//
//  OWImageView.h
//  OWWebImage
//
//  Created by  grenlight on 11-9-3.
//  Copyright (c) 2011年 OOWWWW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "OWImageManager.h"

@interface OWTiledLayer:CATiledLayer
@end

@interface OWImageView : UIView<OWImageManagerDelegate>
{
    @private
    OWTiledLayer                 *contentLayer;
    NSString                     *imageURLString;
    __unsafe_unretained OWImageManager *imageManager;
    
    UITapGestureRecognizer       *singleTap;
    
    //是否可以全屏浏览
    BOOL                         _canFullScreen;
    UIImageView                  *fullScreenImageView;
    
    @public
    UIImage                      *contentImage;
}

@property(retain) UIImage        *maskImage;
@property(retain) UIImage        *placeholder;
//缩放以撑满显示区
@property(assign) BOOL           scaleToFill;
//圆角大小
@property(assign) float          cornerRadius;
@property(nonatomic, retain) UIColor *borderColor;
@property(nonatomic, assign) float    borderWidth;

- (void)setImageManager:(OWImageManager *)manager;

- (void)setImageWithURLString:(NSString *)url;

- (void)setImageWithURLString:(NSString *)url placeholderImage:(UIImage *)placeholder;

- (void)clearContents;

- (void)renderByImage:(UIImage *)image;

//图片全屏
- (void)setCanFullScreen:(BOOL)bl;
- (void)addTapGesture;
- (void)releaseSource;
@end
