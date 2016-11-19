//
//  RealmDataManager.h
//  DataSyncDemo
//
//  Created by sijiechen3 on 16/10/11.
//  Copyright © 2016年 sijiechen3. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Realm/Realm.h>
#import "SmallDataSyncDelegate.h"

@interface RealmSmallDataManager : NSObject

+ (void)store:(RLMObject *)object;

- (instancetype)initWithDataClass:(Class)dataClass realmClass:(Class)realmClass;
- (NSArray<id<DataSyncSmallDataDelegate>> *)waitUploadSyncData;
- (void)storeUploadResponseArr:(NSArray<id<DataSyncUploadResponseSmallDataDelegate>> *)responseArr;
- (void)storeDownloadResponseArr:(NSArray<id<DataSyncDownloadResponseSmallDataDelegate>> *)responseArr;
- (void)reset;

@end
