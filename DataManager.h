//
//  DataManager.h
//  OneKey
//
//  Created by PrashanthPukale on 7/16/14.
//  Copyright (c) 2014 DejaView Concepts. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataManager : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (NSArray*)fetchObjectsForEntiry:(NSString*)entityName inContext:(NSManagedObjectContext*)context predicateString:(NSString*)predicateStr;
- (NSManagedObjectContext *)managedObjectContext;
+ (DataManager*)sharedManager;

@end
