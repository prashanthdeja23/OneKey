//
//  DataManager+FetchManager.m
//  OneKey
//
//  Created by PrashanthPukale on 7/16/14.
//  Copyright (c) 2014 DejaView Concepts. All rights reserved.
//

#import "DataManager+FetchManager.h"

@implementation DataManager (FetchManager)

- (NSArray*)getAllBeacons
{
    return [self fetchObjectsForEntiry:@"Beacon" inContext:self.managedObjectContext predicateString:nil];
}

@end
