//
//  OWImageManager.m
//  OWWebImage
//
//  Created by  oowwww on 12-9-3.
//  Copyright (c) 2012年 OOWWWW. All rights reserved.
//

#import "OWImageManager.h"
#import <ASIHTTPRequest/ASIHTTPRequest.h>
#import "OWCoreDataDelegate.h"
#import "WebImage.h"
#import <objc/message.h>
#import "OWSerialQueue.h"

@implementation OWImageManager

@synthesize imageSavedForever, imageSize;

- (id)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    downloadingQueue = [[NSOperationQueue alloc] init];
    downloadingQueue.maxConcurrentOperationCount = 1;
    [downloadingQueue setSuspended:NO];
    downloadingURLs = [[NSMutableSet alloc] init];
    
    owdd = [OWCoreDataDelegate sharedInstance];
    imageSavedForever = NO;
}

- (void)dealloc
{
    [self cancleWebImageQueue];
}

- (void)getImageByURLString:(NSString *)url  delegate:(id<OWImageManagerDelegate>)_delegate
{
    dispatch_async([OWSerialQueue sharedInstance].queue, ^{
        if(![url isEqualToString:[_delegate imageURL]])
            return;
        NSMutableDictionary *info = [@{@"url":url,@"delegate":_delegate} mutableCopy];
        NSData *imageData = [self getImageFromLocal:url];
        if (imageData) {
            [info setValue:imageData forKey:@"imageData"];
            [self updateImageView:info];
        }
        //本地没有，则加入下载队列
        else {
            [self addDownloadOperation:info];
        }
    });
}

- (void)addDownloadOperation:(NSDictionary *)info
{
    if ([downloadingURLs containsObject:info[@"url"]])
        return ;
    
    [downloadingURLs addObject:info[@"url"]];
    NSInvocationOperation *operation =
    [[NSInvocationOperation alloc] initWithTarget:self
                                         selector:@selector(downloadImageByURL:)
                                           object:info];
    
    [downloadingQueue addOperation:operation];
}

- (NSData *)getImageFromLocal:(NSString *)url
{
    __block NSData  *imageData;
    [owdd.parentMOC performBlockAndWait:^{
//        NSLog(@"localURL:%@",url);
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"imageURL=%@",url];
       NSArray *arr =[owdd getCoreDataList:@"WebImage"
                       byPredicate:predicate
                           context:owdd.parentMOC];
        
        if (arr && arr.count > 0) {
            WebImage *artImage = arr[0];
            artImage.accessTime = [NSDate date];
            imageData = artImage.imageData;
        }
    }];
    
    return imageData;
}

- (UIImage *)getImageByURL:(NSString *)url
{
   __block NSData *imageData = [self getImageFromLocal:url];
    
    if (!imageData) {
        __unsafe_unretained ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
        [request setTimeOutSeconds:20];
        [request setCompletionBlock:^{
            imageData = [[request responseData] copy];
            [self saveImageToDB:imageData imagePath:url];
        }];
        [request setFailedBlock:^{
            
        }];
        [request startSynchronous];
       
    }
    UIImage *image = [UIImage imageWithData:imageData];

    return image;
}

- (void)updateImageView:(NSMutableDictionary *)info
{
    id<OWImageManagerDelegate> delegate = info[@"delegate"];
    if(!delegate || ![info[@"url"] isEqualToString:[delegate imageURL]])
        return;

    NSData *imageData = info[@"imageData"] ;
    if (imageData) {
        UIImage *image = [UIImage imageWithData:imageData];
        [delegate imageManager:self didFinishWithImageData:image forURL:info[@"url"]];

    }
    else {
        [delegate imageManager:self
              didFailWithError:info[@"error"]
                        forURL:info[@"url"]];

    }
}

//从远程下载图片
- (void)downloadImageByURL:(NSMutableDictionary *)info
{
    NSURL *url = [NSURL URLWithString:info[@"url"]];
    __unsafe_unretained ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    __unsafe_unretained OWImageManager *weakSelf = self;
    
    [request setTimeOutSeconds:20];
    [request setCompletionBlock:^{
        NSData *imageData = [request responseData];
        if (!CGSizeEqualToSize(imageSize, CGSizeZero)) {
            UIImage *image = [UIImage imageWithData:imageData];
            image = [weakSelf resizeImage:image toWidth:imageSize.width height:imageSize.height];
            imageData = UIImagePNGRepresentation(image);
        }

        [info setValue:imageData forKey:@"imageData"];
        [weakSelf updateImageView:info];
        
        [weakSelf saveImageToDB:imageData imagePath:info[@"url"]];
    }];
    [request setFailedBlock:^{
        [info setValue:nil forKey:@"imageData"];
        [info setValue:request.error forKey:@"error"];
    }];

    [request startSynchronous];
}

- (void)saveImageToDB:(NSData *)dt imagePath:path
{
    [owdd.parentMOC performBlockAndWait:^{
        WebImage *artImage =
        [NSEntityDescription insertNewObjectForEntityForName:@"WebImage"
                                      inManagedObjectContext:owdd.parentMOC];
        artImage.imageData = dt;
        artImage.imageURL = path;
        artImage.accessTime = [NSDate date];
        artImage.saveForever = [NSNumber numberWithBool:imageSavedForever];

        [owdd.parentMOC save:nil];
        [self deleteWebImages];
    }];
    [downloadingURLs removeObject:path];
}

- (void)cancleWebImageQueue
{
    [downloadingQueue setSuspended:NO];
    [downloadingQueue cancelAllOperations];
    [downloadingQueue setSuspended:YES ];
    
    [owdd.parentMOC performBlockAndWait:^{
        [owdd.parentMOC reset];
    }];
}

- (void)suspendWebImageQueue:(BOOL)bl
{
    [downloadingQueue setSuspended:bl ];
}

- (void)deleteWebImages
{
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"accessTime" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"saveForever=%@",[NSNumber numberWithBool:imageSavedForever]];
    
    [owdd deleteObjects:@"WebImage" predicate:predicate sort:sortDescriptors fetchOffset:MAX_CACHE_COUNT fetchLimit:0 ];
}

- (void)deleteImageByURL:(NSString *)url
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"imageURL=%@",url];
    
    [owdd deleteObjects:@"WebImage" predicate:predicate sort:nil fetchOffset:0 fetchLimit:0];
}

//裁剪图片
- (UIImage*)resizeImage:(UIImage*)image toWidth:(uint)width height:(uint)height
{
    if (width > 0 && height == 0)
        height = (width / image.size.width)*image.size.height;
    
    else if(width == 0 && height > 0)
        width = (height /image.size.height) * image.size.width;
    
    float imgWidth=0, imgHeight=0;
    
    if ((image.size.width / width) < (image.size.height / height)) {
        imgWidth = width;
        imgHeight = image.size.height * (width / image.size.width);
    }
    else {
        imgHeight = height;
        imgWidth = image.size.width * (height / image.size.height);
    }
    
    CGSize size = CGSizeMake(width, height);
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextTranslateCTM(context, 0.0, height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextSetBlendMode(context, kCGBlendModeCopy);
    
    CGContextDrawImage(context, CGRectMake((imgWidth - width) / 2.0f, 0.0, imgWidth, imgHeight), image.CGImage);
    UIImage *imageOut = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return imageOut;
}

@end
