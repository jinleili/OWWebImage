
#import "OWCoreDataDelegate.h"


@interface OWCoreDataDelegate()

@end


@implementation OWCoreDataDelegate

@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;

- (id)init
{
    self = [super init];
    
    if (self) {

    }
    return (self);
}

- (void) initializeSharedInstance
{
    self.parentMOC = [[NSManagedObjectContext alloc]
                      initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [self.parentMOC setPersistentStoreCoordinator:self.persistentStoreCoordinator];
    
//    self.updateMOC = [[NSManagedObjectContext alloc]
//                      initWithConcurrencyType:NSPrivateQueueConcurrencyType];
//    [self.updateMOC setParentContext:self.parentMOC];
//
}

+ (OWCoreDataDelegate *) sharedInstance
{
    static OWCoreDataDelegate *sharedInstance;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
        [sharedInstance initializeSharedInstance];
    });
    return sharedInstance;
}

#pragma mark - Core Data stack

- (NSManagedObjectModel *)managedObjectModel
{
    if (__managedObjectModel != nil)
    {
        return __managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"OWWebImage" withExtension:@"mom"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];

    return __managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (__persistentStoreCoordinator != nil)
    {
        return __persistentStoreCoordinator;
    }
    
    NSString *storePath = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:@"OWWebImage.sqlite"];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    // If the expected store doesn't exist, copy the default store.
    if (![fileManager fileExistsAtPath:storePath]) {
        NSString *defaultStorePath = [[NSBundle mainBundle] pathForResource:@"OWWebImage" ofType:@"sqlite"];
        if (defaultStorePath) {
            [fileManager copyItemAtPath:defaultStorePath toPath:storePath error:NULL];
        }
    }

    NSURL *storeUrl = [NSURL fileURLWithPath:storePath];
    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error]) {
        NSLog(@"persistentStoreCoordinator error %@, %@", error, [error userInfo]);
        abort();
    }  

    return __persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

- (NSString *)applicationDocumentsDirectory
{
//    NSLog(@"path:%@",[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]);
    return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
}


-(NSArray *)getCoreDataList:(NSString *)className
                byPredicate:(NSPredicate *)predicate
                    context:(NSManagedObjectContext *)context
{
    return [self getCoreDataList:className byPredicate:predicate
                            sort:nil fetchLimit:1 fetchOffset:0
                         context:context];

}

-(NSArray *)getCoreDataList:(NSString *)className
                byPredicate:(NSPredicate *)predicate
                       sort:(NSArray *)aSort
                 fetchLimit:(uint)limit
                fetchOffset:(uint)offset
                    context:(NSManagedObjectContext *)context
{
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:className
                                              inManagedObjectContext:context];
	[request setEntity:entity];
    [request setPredicate:predicate];
    [request setSortDescriptors:aSort];
    [request setFetchLimit:limit];
    [request setFetchOffset:offset];
    
    if (!context || !request) return nil;
    
	NSError *error = nil;
	NSArray *fetchResults;
    fetchResults = [context executeFetchRequest:request error:&error];
    
    if(error) return nil;
    
    return fetchResults;
}

-(void)deleteObjects:(NSString *)className
           predicate:(NSPredicate *)predicate
                sort:(NSArray *)aSort
         fetchOffset:(uint)offset
          fetchLimit:(uint)limit
{
    NSArray *arr = [self getCoreDataList:className byPredicate:predicate sort:aSort fetchLimit:limit fetchOffset:offset context:self.parentMOC];
    
    if(arr == nil || arr.count == 0) return;
    
    for (id item in arr) {
        [self.parentMOC deleteObject:item];
    }
    [self.parentMOC save:nil];
}

@end
