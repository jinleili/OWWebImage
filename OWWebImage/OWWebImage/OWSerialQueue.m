//
//  OWSerialQueue.m
//  OWWebImage
//
//  Created by  grenlight on 11-9-3.
//  Copyright (c) 2011年 OOWWWW. All rights reserved.
//

#import "OWSerialQueue.h"

@implementation OWSerialQueue
@synthesize queue;

+(OWSerialQueue *)sharedInstance
{
    static OWSerialQueue *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[OWSerialQueue alloc] init];
        [instance setup];
    });
    return instance;
}

-(void)dealloc
{
    dispatch_resume(queue);
    dispatch_release(queue);
}   

-(void)setup
{
    queue = dispatch_queue_create("com.qikan.imageDownload",NULL);
}
@end
