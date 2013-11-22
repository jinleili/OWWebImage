//
//  OWMOCManager.h
//  OWWebImage
//
//  Created by 龙源 on 13-11-3.
//  Copyright (c) 2013年 OOWWWW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface OWMOCManager : NSObject

@property (strong, nonatomic) NSManagedObjectContext *updateMOC;
@property (strong, nonatomic) NSManagedObjectContext *parentMOC;

+ (OWMOCManager *)sharedInstance;
@end
