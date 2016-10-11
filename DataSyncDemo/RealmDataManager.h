//
//  RealmDataManager.h
//  DataSyncDemo
//
//  Created by sijiechen3 on 16/10/11.
//  Copyright © 2016年 sijiechen3. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Realm/Realm.h>

@interface RealmDataManager : NSObject

+ (instancetype)sharedInstance;
- (void)store:(RLMObject *)object;
- (void)ustore:(RLMObject *)object;

//- (RLMResults *)ObjectsOfClass:(Class)class;
- (id)runBlock:(id (^)())block;
- (void)urunInRealm:(void (^)())block;

@end
