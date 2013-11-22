//
//  OWMOCManager.m
//  OWWebImage
//
//  Created by 龙源 on 13-11-3.
//  Copyright (c) 2013年 OOWWWW. All rights reserved.
//

#import "OWMOCManager.h"
#import "OWCoreDataDelegate.h"

@implementation OWMOCManager

+ (OWMOCManager *)sharedInstance
{
    static OWMOCManager *instance ;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[OWMOCManager alloc] init];
        [instance setup];
    });
    return instance;
}

- (void)setup
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    dispatch_async(queue, ^{
        self.parentMOC = [[NSManagedObjectContext alloc]
                          initWithConcurrencyType:NSMainQueueConcurrencyType];
        [self.parentMOC setPersistentStoreCoordinator:[OWCoreDataDelegate sharedInstance].persistentStoreCoordinator];
        
        self.updateMOC = [[NSManagedObjectContext alloc]
                          initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [self.updateMOC setParentContext:self.parentMOC];

    });
}
@end
