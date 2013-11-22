//
//  OWImageManager.h
//  OWWebImage
//
//  Created by  oowwww on 11-9-3.
//  Copyright (c) 2011年 OOWWWW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define MAX_CACHE_COUNT 600

@class UIImage;
@class  OWCoreDataDelegate;
@protocol OWImageManagerDelegate;

@interface OWImageManager : NSObject
{
    //在下载队列中的的URL
    NSMutableSet       *downloadingURLs;
    
    NSOperationQueue   *downloadingQueue;

    OWCoreDataDelegate *owdd;
    
}

//是否为永久存储
@property(nonatomic,assign) BOOL imageSavedForever;
//设置图片要保存的合适尺寸
@property(nonatomic,assign) CGSize imageSize;

//异步获取网络图片
- (void)getImageByURLString:(NSString *)url
                  delegate:(id<OWImageManagerDelegate>)_delegate;

//同步获取网络图片
- (UIImage *)getImageByURL:(NSString *)url;


//删除单张图片资源
- (void)deleteImageByURL:(NSString *)url;

- (void)deleteWebImages;

/*
 取消下载队列
 */
- (void)cancleWebImageQueue;

- (void)suspendWebImageQueue:(BOOL)bl;

@end



@protocol OWImageManagerDelegate <NSObject>

@required

- (NSString *)imageURL;

- (void)imageManager:(OWImageManager *)imageManager
didFinishWithImageData:(UIImage *)image
              forURL:(NSString *)url;

- (void)imageManager:(OWImageManager *)imageManager
    didFailWithError:(NSError *)error
              forURL:(NSURL *)url;

@end
