//
//  SecondViewController.m
//  OWWebImageDemo
//
//  Created by grenlight on 13-11-22.
//  Copyright (c) 2013年 grenlight. All rights reserved.
//

#import "SecondViewController.h"
#import <OWWebImage/OWImageManager.h>
#import <ASIHTTPRequest/ASIHTTPRequest.h>
#import "HTMLParser.h"
#import "HTMLNode.h"
#import "OWCollectionViewCell.h"

@interface SecondViewController ()

@end

@implementation SecondViewController

- (id)init
{
    self = [super initWithNibName:@"ViewController" bundle:nil];
    if (self) {
        imageManager = [[OWImageManager alloc] init];
        [imageManager setImageSavedForever:NO];
    }
    return self;
}

- (void)requestImageURLs
{
    self.title = @"Second";
    
    NSString *pagePath = [[NSBundle mainBundle] pathForResource:@"knewone2" ofType:@"html"];
    NSString *html = [NSString stringWithContentsOfFile:pagePath encoding:NSUTF8StringEncoding error:nil];
    [self parseHTML:html];
}
@end
