//
//  ViewController.h
//  OWWebImageDemo
//
//  Created by grenlight on 13-11-15.
//  Copyright (c) 2013年 OOWWWW. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OWImageManager;

@interface ViewController : UIViewController<UICollectionViewDataSource, UICollectionViewDelegate>
{
    OWImageManager  *imageManager;
    NSMutableArray  *dataSource;
}
@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;

- (void)parseHTML:(NSString *)html;

@end
