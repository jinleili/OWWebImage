
//  Created by  grenlight on 11-9-3.
//  Copyright (c) 2011年 OOWWWW. All rights reserved.

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface OWCoreDataDelegate : NSObject
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

//@property (strong, nonatomic) NSManagedObjectContext *updateMOC;
@property (strong, nonatomic) NSManagedObjectContext *parentMOC;

- (NSString *)applicationDocumentsDirectory;

+(OWCoreDataDelegate *) sharedInstance;


-(NSArray *)getCoreDataList:(NSString *)className
                       byPredicate:(NSPredicate *)predicate
                           context:(NSManagedObjectContext *)context;

-(NSMutableArray *)getCoreDataList:(NSString *)className
                       byPredicate:(NSPredicate *)predicate
                              sort:(NSArray *)aSort 
                        fetchLimit:(uint)limit
                       fetchOffset:(uint)offset
                           context:(NSManagedObjectContext *)context;

-(void)deleteObjects:(NSString *)className
           predicate:(NSPredicate *)predicate
                sort:(NSArray *)aSort
         fetchOffset:(uint)offset
          fetchLimit:(uint)limit;

@end
