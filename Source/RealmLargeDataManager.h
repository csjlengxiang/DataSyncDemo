//
//  RealmDataManager.h
//  DataSyncDemo
//
//  Created by sijiechen3 on 16/10/11.
//  Copyright © 2016年 sijiechen3. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Realm/Realm.h>
#import "LargeDataSyncDelegate.h"

@interface RealmLargeDataManager : NSObject

+ (void)store:(RLMObject *)object;

- (instancetype)initWithDataClass:(Class)dataClass realmClass:(Class)realmClass;
- (NSArray<id<DataSyncLargeDataDelegate>> *)waitUploadSyncData;
- (void)storeUploadResponseArr:(NSArray<id<DataSyncUploadResponseLargeDataDelegate>> *)responseArr;
- (void)storeDownloadResponseArr:(NSArray<id<DataSyncDownloadResponseLargeDataDelegate>> *)responseArr;
- (int)maxServerUpdateUtc;
- (void)reset;

@end
