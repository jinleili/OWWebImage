//
//  WebImage.h
//  OWWebImage
//
//  Created by  grenlight on 11-9-3.
//  Copyright (c) 2011年 OOWWWW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface WebImage : NSManagedObject

@property (nonatomic, retain) NSDate * accessTime;
@property (nonatomic, retain) NSData * imageData;
@property (nonatomic, retain) NSString * imageURL;
@property (nonatomic, retain) NSString * summary;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * saveForever;

@end
