//
//  RealmDataManager.m
//  DataSyncDemo
//
//  Created by sijiechen3 on 16/10/11.
//  Copyright © 2016年 sijiechen3. All rights reserved.
//

#import "RealmSmallDataManager.h"
#import "NSObject+DataChange.h"

@interface RealmSmallDataManager ()

@property (nonatomic, strong) Class dataClass;
@property (nonatomic, strong) Class realmClass;

@end

@implementation RealmSmallDataManager

+ (instancetype)sharedInstance {
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[[self class] alloc] init];
    });
    return instance;
}

- (instancetype)initWithDataClass:(Class)dataClass realmClass:(Class)realmClass {
    if (self = [super init]) {
        self.dataClass = dataClass;
        self.realmClass = realmClass;
    }
    return self;
}

+ (void)store:(RLMObject<DataSyncRealmSmallDataDelegate> *)object {
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm transactionWithBlock:^{
        [realm addOrUpdateObject:object];
    }];
}

- (NSArray<id<DataSyncSmallDataDelegate>> *)waitUploadSyncData {
    [self reset];
    NSMutableArray * ret = [NSMutableArray new];
    RLMRealm *realm = [RLMRealm defaultRealm];
    // 注意此处需要原子操作
    [realm beginWriteTransaction];
    RLMResults * arr = [[self.realmClass allObjects] objectsWhere:@"status == %d", Wait];
    for (RLMObject<DataSyncRealmSmallDataDelegate> * data in arr) {
        data.status = Ing;
        [ret addObject:[data data:self.dataClass]];
    }
    [realm commitWriteTransaction];
    return ret;
}

- (void)reset {
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    RLMResults * arr = [[self.realmClass allObjects] objectsWhere:@"status == %d", Ing];
    for (id<DataSyncRealmSmallDataDelegate> data in arr) {
        data.status = Wait;
    }
    [realm commitWriteTransaction];
}

- (void)storeUploadResponseArr:(NSArray<id<DataSyncUploadResponseSmallDataDelegate>> *)responseArr {
    NSMutableDictionary * responseDic = [NSMutableDictionary new]; // 全集
    for (id<DataSyncUploadResponseSmallDataDelegate> responseData in responseArr) {
        responseDic[responseData.key] = responseData;
    }
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    RLMResults * arr = [[self.realmClass allObjects] objectsWhere:@"status == %d", Ing];
    for (id<DataSyncRealmSmallDataDelegate> data in arr) { // 在上传过程中可能将ing->wait，故这里是子集
        if (responseDic[data.key]) {
            id<DataSyncUploadResponseSmallDataDelegate> responseData = responseDic[data.key];
            if (responseData.status == Success) {
                data.status = Completed;
                continue;
            }
        }
        // 失败情况
        data.status = Wait;
    }
    [realm commitWriteTransaction];
}

- (void)storeDownloadResponseArr:(NSArray<NSObject<DataSyncDownloadResponseSmallDataDelegate> *> *)responseArr {
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    for (NSObject<DataSyncDownloadResponseSmallDataDelegate> * data in responseArr) {
        NSString * key = data.key;
        
        RLMObject<DataSyncRealmSmallDataDelegate> * localRealmData = [self.realmClass objectForPrimaryKey:key];
        if (localRealmData) {
            if (localRealmData.status == Wait) {
                if (localRealmData.modifyUtc < data.modifyUtc) { // 被新数据覆盖
                    RLMObject<DataSyncRealmSmallDataDelegate> * newRealmData = [data data:self.realmClass];
                    newRealmData.status = Completed;
                    [realm addOrUpdateObject:newRealmData];
                }
            } else if (localRealmData.status == Ing) {
                NSAssert(localRealmData.status != Ing, @"download data will not uploading");
            } else if (localRealmData.status == Completed) {
                NSAssert(localRealmData.modifyUtc <= data.modifyUtc, @"if local data is new and completed. bug");
                if (localRealmData.modifyUtc < data.modifyUtc) {
                    RLMObject<DataSyncRealmSmallDataDelegate> * newRealmData = [(NSObject *)data data:self.realmClass];
                    newRealmData.status = Completed;
                    [realm addOrUpdateObject:newRealmData];
                }
            }
        } else {
            RLMObject<DataSyncRealmSmallDataDelegate> * newRealmData = [(NSObject *)data data:self.realmClass];
            newRealmData.status = Completed;
            [realm addOrUpdateObject:newRealmData];
        }
    }
    [realm commitWriteTransaction];
}

@end
