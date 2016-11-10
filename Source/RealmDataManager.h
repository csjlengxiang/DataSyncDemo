//
//  RealmDataManager.h
//  DataSyncDemo
//
//  Created by sijiechen3 on 16/10/11.
//  Copyright © 2016年 sijiechen3. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Realm/Realm.h>
#import "DataSyncDelegate.h"

@interface RealmDataManager : NSObject

+ (void)store:(RLMObject *)object;

- (instancetype)initWithDataClass:(Class)dataClass realmClass:(Class)realmClass;
- (NSArray<id<DataSyncDataDelegate>> *)waitUploadSyncData;
- (void)storeUploadResponseArr:(NSArray<id<DataSyncUploadResponseDataDelegate>> *)responseArr;
- (void)storeDownloadResponseArr:(NSArray<id<DataSyncDownloadResponseDataDelegate>> *)responseArr;
- (int)maxServerUpdateUtc;
- (void)reset;

@end
