//
//  MyCoreDataManager.h
//  MyCoreData
//
//  Created by Taurus on 16/5/28.
//  Copyright © 2016年 Taurus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface MyCoreDataManager : NSObject

+ (instancetype)shareCoreDataManager;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
