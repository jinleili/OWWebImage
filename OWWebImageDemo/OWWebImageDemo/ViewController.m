//
//  ViewController.m
//  OWWebImageDemo
//
//  Created by grenlight on 13-11-15.
//  Copyright (c) 2013年 OOWWWW. All rights reserved.
//

#import "ViewController.h"
#import <OWWebImage/OWImageManager.h>
#import <ASIHTTPRequest/ASIHTTPRequest.h>
#import "HTMLParser.h"
#import "HTMLNode.h"
#import "OWCollectionViewCell.h"
#import "SecondViewController.h"

@interface ViewController ()
{
    ASIHTTPRequest  *request;
}
@end

@implementation ViewController

@synthesize collectionView;

- (id)init
{
    self = [super init];
    if (self) {
        imageManager = [[OWImageManager alloc] init];
        [imageManager setImageSavedForever:NO];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [collectionView registerNib:[UINib nibWithNibName:@"OWCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"Cell"];
    [self requestImageURLs];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [imageManager suspendWebImageQueue:NO];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [imageManager suspendWebImageQueue:YES];
}

- (void)dealloc
{
    [imageManager suspendWebImageQueue:YES];
    imageManager = nil;
    collectionView.dataSource = nil;
    collectionView.delegate = nil;
}

- (void)intoSecondController
{
    SecondViewController *controller = [[SecondViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)requestImageURLs
{
//    request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:@"http://flickr.com/"]];
//    __unsafe_unretained ASIHTTPRequest *weakRequest = request;
//    __unsafe_unretained ViewController *weakSelf = self;
//    [request setCompletionBlock:^{
//        [weakSelf parseHTML:weakRequest.responseData];
//    }];
//    [request setFailedBlock:^{
//        NSLog(@"request error:%@", weakRequest.error.description);
//    }];
//    [request startAsynchronous];
    self.title = @"First";
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Second" style:UIBarButtonItemStyleDone target:self action:@selector(intoSecondController)];
    self.navigationItem.rightBarButtonItem = rightButton;
    
    NSString *pagePath = [[NSBundle mainBundle] pathForResource:@"knewone" ofType:@"html"];
    NSString *html = [NSString stringWithContentsOfFile:pagePath encoding:NSUTF8StringEncoding error:nil];
    [self parseHTML:html];
}

- (void)parseHTML:(NSString *)html
{
    HTMLParser *parser = [[HTMLParser alloc] initWithString:html error:nil ];
    NSArray *imageNodes = [[parser body] findChildrenWithTag:@"img"];
    
    dataSource = [[NSMutableArray alloc] init];
    for (HTMLNode *node in imageNodes) {
        NSString *imagePath = [node getAttributeNamed:@"src"];
        [dataSource addObject:imagePath];
    }
    collectionView.dataSource = self;
    collectionView.delegate = self;
}

- (NSInteger)collectionView:(UICollectionView *)theCollectionView numberOfItemsInSection:(NSInteger)section
{
    return dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)theCollectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    
    OWCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    [cell setImageManager:imageManager];
    [cell setImageURL:dataSource[indexPath.row]];
    
    return cell;
}

@end
