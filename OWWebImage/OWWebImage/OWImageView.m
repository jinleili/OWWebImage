//
//  OWImageView.m
//  OWWebImage
//
//  Created by  grenlight on 11-9-3.
//  Copyright (c) 2011年 OOWWWW. All rights reserved.
//

#import "OWImageView.h"
#import "OWImageManager.h"
#import <QuartzCore/QuartzCore.h>

@implementation OWTiledLayer
+ (CFTimeInterval)fadeDuration
{
    return 0.25;
}
@end


@implementation OWImageView
@synthesize maskImage, placeholder, scaleToFill, cornerRadius;
@synthesize borderColor, borderWidth;

+ (Class)layerClass
{
    return [OWTiledLayer class];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    self.backgroundColor = [UIColor clearColor];
    contentLayer = (id)[self layer];
    contentLayer.doubleSided = NO;
    contentLayer.backgroundColor = [UIColor clearColor].CGColor;
    
    UIScreen *mainScreen = [UIScreen mainScreen];
    CGFloat scale = mainScreen.scale;
    
    //此处之所以不使用视图自已的size 是因为有可能初始时的大小为 0
    CGSize tileSize = CGSizeMake(mainScreen.bounds.size.width*scale, mainScreen.applicationFrame.size.height * scale);
    contentLayer.tileSize = tileSize;
    scaleToFill = YES;
    cornerRadius = 0;
    
    _canFullScreen = NO;
    
}

- (void)dealloc
{
    if (singleTap) {
        [self removeGestureRecognizer:singleTap];
    }
}

- (void)releaseSource
{
    
}

- (void)setCanFullScreen:(BOOL)bl
{
    _canFullScreen = bl;
    if (_canFullScreen) {
        singleTap = [[UITapGestureRecognizer alloc]initWithTarget:self  action:@selector(onTap:)];
        singleTap.numberOfTapsRequired = 1;
        [self addTapGesture];
    }
}

- (void)onTap:(UIGestureRecognizer *)gesture
{
    if(!_canFullScreen) return;
    
    fullScreenImageView = [[UIImageView alloc] initWithFrame:self.bounds];
    fullScreenImageView.image = contentImage;
    fullScreenImageView.contentMode = UIViewContentModeScaleAspectFit;
//    fullScreenImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:fullScreenImageView];
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                         fullScreenImageView,@"image",self,@"pageView", nil];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"PageImageToFullScreen"
                                                       object:nil userInfo:dic];
    
    [self removeGestureRecognizer:singleTap];
}

- (void)addTapGesture
{
    if (fullScreenImageView){
        [fullScreenImageView removeFromSuperview];
        fullScreenImageView = nil;
    }
    [self addGestureRecognizer:singleTap];
}

- (void)setImageManager:(OWImageManager *)manager
{
    imageManager = manager;
}

- (void)setImageWithURLString:(NSString *)url
{
    [self setImageWithURLString:url placeholderImage:nil];
}

- (void)setImageWithURLString:(NSString *)url placeholderImage:(UIImage *)aplaceholder
{
    if ([url isEqualToString:imageURLString]) {
        [contentLayer setNeedsDisplay];
        return;
    }
    [self renderByImage:aplaceholder];
    
    imageURLString = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    if (imageURLString && imageURLString.length > 15) {
        [imageManager getImageByURLString:imageURLString delegate:self];
    }
}

- (void)renderByImage:(UIImage *)image
{
    contentImage = image;
    contentLayer.contents = nil;
    [contentLayer setNeedsDisplay];
}

//这个空消息需要保留，用于解决有时图片绘制不能及时更新的问题
-(void)drawRect:(CGRect)rect
{
    
}

-(void)drawLayer:(CALayer *)layer inContext:(CGContextRef)context
{
    CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
    CGContextFillRect(context, self.bounds);
    
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextTranslateCTM(context, 0, -CGRectGetHeight(self.frame));
        
    //等比缩放裁剪背景图片
    CGContextSaveGState(context);
    UIBezierPath *clipPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                                        cornerRadius:cornerRadius];
    CGContextAddPath(context, [clipPath CGPath]);
    CGContextClip(context);

    if (contentImage && contentImage.CGImage) {
        UIImage *image = [contentImage copy];
        CGRect thumbnailFrame = self.bounds;
       float wScale = CGRectGetWidth(self.bounds)/image.size.width;
        float hScale = CGRectGetHeight(self.bounds) / image.size.height;

        if (_canFullScreen) {
            if (wScale > hScale) {
                thumbnailFrame.size.height = image.size.height*hScale;
                thumbnailFrame.size.width = image.size.width * hScale;
                thumbnailFrame.origin.x = (CGRectGetWidth(self.bounds) - thumbnailFrame.size.width) / 2.0f;
            }
            else{
                thumbnailFrame.size.height = image.size.height*wScale;
                thumbnailFrame.size.width = image.size.width * wScale;
                thumbnailFrame.origin.y = (CGRectGetHeight(self.bounds) - thumbnailFrame.size.height) / 2.0f;
            }
        }
        else if (scaleToFill) {
            if (wScale > hScale) {
                thumbnailFrame.size.height = image.size.height*wScale;
                thumbnailFrame.origin.y = (CGRectGetHeight(self.bounds) - CGRectGetHeight(thumbnailFrame)) / 2.0f;
            }
            else {
                thumbnailFrame.size.width = image.size.width*hScale;
                thumbnailFrame.origin.x = (CGRectGetWidth(self.bounds) - CGRectGetWidth(thumbnailFrame)) / 2.0f;
            }
        }
        else {
            if (wScale > hScale) {
                thumbnailFrame.size.width = image.size.width*hScale;
                thumbnailFrame.origin.x = (CGRectGetWidth(self.bounds) - CGRectGetWidth(thumbnailFrame)) / 2.0f;
            }
            else {
                thumbnailFrame.size.height = image.size.height*wScale;
                thumbnailFrame.origin.y = (CGRectGetHeight(self.bounds) - CGRectGetHeight(thumbnailFrame)) / 2.0f;
            }
           
        }
        CGContextDrawImage(context, thumbnailFrame, image.CGImage);
        image = nil;
       
    }
    else {
        if (placeholder) {
            CGRect imageFrame = self.bounds;
            imageFrame.size.height = placeholder.size.height * (CGRectGetWidth(self.bounds)/placeholder.size.width);
            CGContextDrawImage(context, imageFrame, placeholder.CGImage);
        }
    }
    //图片遮罩
    if (maskImage) {
        CGContextDrawImage(context, self.bounds, maskImage.CGImage);
    }
    CGContextRestoreGState(context);
    
    if (borderColor && borderWidth > 0) {
        CGRect borderRect = self.bounds;
        borderRect.origin.x = borderRect.origin.y = borderWidth/2;
        borderRect.size.width -= borderWidth;
        borderRect.size.height -= borderWidth;
        UIBezierPath *borderPath = [UIBezierPath bezierPathWithRoundedRect:borderRect
                                                            cornerRadius:cornerRadius];
        CGContextSetStrokeColorWithColor(context, borderColor.CGColor);
        CGContextSetLineWidth(context, borderWidth);
        CGContextAddPath(context, [borderPath CGPath]);
        CGContextDrawPath(context, kCGPathStroke);
    }
   
}

- (void)clearContents
{
    contentLayer.contents = nil; 
}

#pragma mark imageManager delegate
- (NSString *)imageURL
{
    return imageURLString;
}

- (void)imageManager:(OWImageManager *)imageManager
didFinishWithImageData:(UIImage *)image
              forURL:(NSString *)url{
    if ([url isEqualToString:imageURLString]) {
        contentImage = image;
        [contentLayer setNeedsDisplay];
    }
}

- (void)imageManager:(OWImageManager *)imageManager didFailWithError:(NSError *)error forURL:(NSURL *)url
{
//    NSLog(@"imageDownloadError:%@ \n url:%@",error.description,url);
}
@end
