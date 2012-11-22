//
//  UECoreData.h
//  RollingPaper
//
//  Created by 이상현 on 12. 11. 20..
//  Copyright (c) 2012년 상현 이. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
@interface NSManagedObject(DictionarySupport)
-(void) setValuesWithDictionary : (NSDictionary*) dict;
@end

@interface UECoreData : NSObject
@property (readonly, strong, nonatomic) NSManagedObjectContext* managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel*   managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
+ (UECoreData*)sharedInstance;
- (void)saveContext;
- (NSManagedObject*) insertNewObject : (NSString*) entityName;
- (NSManagedObject*) insertNewObject : (NSString*) entityName
                            initWith : (NSDictionary*) dictionary;
@end
