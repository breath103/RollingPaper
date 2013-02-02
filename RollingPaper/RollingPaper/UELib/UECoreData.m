
//
//  UECoreData.m
//  RollingPaper
//
//  Created by 이상현 on 12. 11. 20..
//  Copyright (c) 2012년 상현 이. All rights reserved.
//

#import "UECoreData.h"

@implementation NSManagedObject(DictionarySupport)
-(void) setValuesWithDictionary : (NSDictionary*) dict{
    for( NSString* name in self.entity.propertiesByName.allKeys){
        // 실제데이터 모델에서 존재하는 프로퍼티들을 뽑는다.
        id value = [dict objectForKey:name];
        if(value == [NSNull null])
            value = NULL;
       
        //NSLog(@"%@",NSStringFromClass([[self valueForKey:name] class]));
        
        [self setValue:value forKey:name];
    }
}
+(NSArray*) entitiesWithDictionaryArray : (NSArray*) array
{
    NSMutableArray* entities = [NSMutableArray arrayWithCapacity:array.count];
    for(NSDictionary*p in array){
        NSManagedObject* entity= [[UECoreData sharedInstance]insertNewObject:NSStringFromClass(self) initWith:p];
        [entities addObject:entity];
    }
    return entities;
}
-(NSArray*) attributeNames{
    return [self.entity attributesByName].allKeys;
}

@end




@implementation UECoreData
@synthesize managedObjectContext       = __managedObjectContext;
@synthesize managedObjectModel         = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;


+ (UECoreData*)sharedInstance
{
    static dispatch_once_t pred;
    static UECoreData *sharedInstance = nil;
    dispatch_once(&pred, ^{
        sharedInstance = [[UECoreData alloc] init];
    });
    return sharedInstance;
}
#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (__managedObjectContext != nil) {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return __managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (__managedObjectModel != nil) {
        return __managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"RollingPaper" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return __managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (__persistentStoreCoordinator != nil) {
        return __persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"RollingPaper.sqlite"];
    
    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return __persistentStoreCoordinator;
}
#pragma mark - Application's Documents directory
// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                   inDomains:NSUserDomainMask] lastObject];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

- (NSManagedObject*) insertNewObject : (NSString*) entityName{
    return [NSEntityDescription insertNewObjectForEntityForName:entityName
                                         inManagedObjectContext:self.managedObjectContext];
}

- (NSManagedObject*) insertNewObject : (NSString*) entityName
                            initWith : (NSDictionary*) dictionary{
    NSManagedObject* newObject = [self insertNewObject:entityName];
    if(newObject){
        [newObject setValuesWithDictionary:dictionary];
    }
    return newObject;
}



@end
