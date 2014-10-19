//
//  BFROStore.m
//  BigfootReports
//
//  Created by Colby Reineke on 8/12/13.
//  Copyright (c) 2013 Colby Reineke. All rights reserved.
//

#import "BFROStore.h"
#include <sys/xattr.h>

@implementation BFROStore

@synthesize model, context;

+ (BFROStore *)sharedStore
{
    static BFROStore *feedStore = nil;
    if(!feedStore)
        feedStore = [[BFROStore alloc] init];
    
    return feedStore;
}


- (id)init
{
    self = [super init];
    if(self) {
        
        model = [NSManagedObjectModel mergedModelFromBundles:nil];
        
        NSPersistentStoreCoordinator *psc =
        [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
        
        NSError *error = nil;
        
        NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"bfro1.sqlite"];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:[storeURL path]]) {
            NSURL *preloadURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"bfro1" ofType:@"sqlite"]];
            
            NSError* err = nil;
            
            if (![[NSFileManager defaultManager] copyItemAtURL:preloadURL toURL:storeURL error:&err]) {
                NSLog(@"Oops, could copy preloaded data");
            }
        }
        
        [self addSkipBackupAttributeToItemAtURL:storeURL];
        
        if (![psc addPersistentStoreWithType:NSSQLiteStoreType
                               configuration:nil
                                         URL:storeURL
                                     options:nil
                                       error:&error]) {
            [NSException raise:@"Open failed"
                        format:@"Reason: %@", [error localizedDescription]];
        }
        
        // Create the managed object context
        context = [[NSManagedObjectContext alloc] init];
        [context setPersistentStoreCoordinator:psc];
        
        // The managed object context can manage undo, but we don't need it
        [context setUndoManager:nil];
    }
    return self;
}
#pragma mark - Application's Documents directory


// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL

{
    
    assert([[NSFileManager defaultManager] fileExistsAtPath: [URL path]]);
    
    
    
    NSError *error = nil;
    
    BOOL success = [URL setResourceValue: [NSNumber numberWithBool: YES]
                                  forKey: NSURLIsExcludedFromBackupKey error: &error];
    
    if(!success){
        
        NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
        
    }
    
    return success;
}

@end
