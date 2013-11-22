//
//  OWSerialQueue.h
//  OWWebImage
//
//  Created by  grenlight on 11-9-3.
//  Copyright (c) 2011年 OOWWWW. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OWSerialQueue : NSObject

@property(nonatomic,assign)dispatch_queue_t   queue;

+(OWSerialQueue *)sharedInstance;
@end
