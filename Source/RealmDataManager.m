//
//  RealmDataManager.m
//  DataSyncDemo
//
//  Created by sijiechen3 on 16/10/11.
//  Copyright © 2016年 sijiechen3. All rights reserved.
//

#import "RealmDataManager.h"
#import "NSObject+DataChange.h"

@interface RealmDataManager ()

@property (nonatomic, strong) Class dataClass;
@property (nonatomic, strong) Class realmClass;

@end

@implementation RealmDataManager

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

+ (void)store:(RLMObject<DataSyncRealmDataDelegate> *)object {
    object.retryCount = 0;
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm transactionWithBlock:^{
        [realm addOrUpdateObject:object];
    }];
}

// 当 ret count = 0 应该 stop
- (NSArray<id<DataSyncDataDelegate>> *)waitUploadSyncData {
    [self reset];
    NSMutableArray * ret = [NSMutableArray new];
    RLMRealm *realm = [RLMRealm defaultRealm];
    // 注意此处需要原子操作
    [realm beginWriteTransaction];
    RLMResults * arr = [[[self.realmClass allObjects] objectsWhere:@"status == %d", Wait] sortedResultsUsingProperty:@"retryCount" ascending:YES];
    if (arr.count > 0) {
        RLMObject<DataSyncRealmDataDelegate> * firstData = [arr firstObject];
        if (firstData.retryCount == 3) { // 第一次出现retry 3次 就停止咯，为了防止冲击最新的，于是retry变为1
            arr = [[self.realmClass allObjects] objectsWhere:@"status == %d && retryCount == %d", Wait, 3];
            for (RLMObject<DataSyncRealmDataDelegate> * data in arr) {
                data.retryCount = 1;
            }
        } else {
            for (RLMObject<DataSyncRealmDataDelegate> * data in arr) {
                data.status = Ing;
                [ret addObject:[data data:self.dataClass]];
            }
        }
    }
    [realm commitWriteTransaction];
    return ret;
}

- (void)reset {
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    RLMResults * arr = [[self.realmClass allObjects] objectsWhere:@"status == %d", Ing];
    for (id<DataSyncRealmDataDelegate> data in arr) {
        data.status = Wait;
        data.retryCount += 1;
    }
    [realm commitWriteTransaction];
}

- (void)storeUploadResponseArr:(NSArray<id<DataSyncUploadResponseDataDelegate>> *)responseArr {
    NSMutableDictionary * responseDic = [NSMutableDictionary new]; // 全集
    for (id<DataSyncUploadResponseDataDelegate> responseData in responseArr) {
        responseDic[responseData.key] = responseData;
    }
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    RLMResults * arr = [[self.realmClass allObjects] objectsWhere:@"status == %d", Ing];
    for (id<DataSyncRealmDataDelegate> data in arr) { // 在上传过程中可能将ing->wait，故这里是子集
        if (responseDic[data.key]) {
            id<DataSyncUploadResponseDataDelegate> responseData = responseDic[data.key];
            if (responseData.status == Success) {
                data.status = Completed;
                data.serverUpdateUtc = responseData.serverUpdateUtc;
                continue;
            }
        }
        // 失败情况
        data.status = Wait;
        data.retryCount += 1;
    }
    [realm commitWriteTransaction];
}

- (void)storeDownloadResponseArr:(NSArray<NSObject<DataSyncDownloadResponseDataDelegate> *> *)responseArr {
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    for (NSObject<DataSyncDownloadResponseDataDelegate> * data in responseArr) {
        NSString * key = data.key;
        
        RLMObject<DataSyncRealmDataDelegate> * localRealmData = [self.realmClass objectForPrimaryKey:key];
        if (localRealmData) {
            if (localRealmData.status == Wait) {
                if (localRealmData.modifyUtc < data.modifyUtc) { // 被新数据覆盖
                    RLMObject<DataSyncRealmDataDelegate> * newRealmData = [data data:self.realmClass];
                    newRealmData.status = Completed;
                    [realm addOrUpdateObject:newRealmData];
                }
            } else if (localRealmData.status == Ing) {
                NSAssert(localRealmData.status != Ing, @"download data will not uploading");
            } else if (localRealmData.status == Completed) {
                NSAssert(localRealmData.modifyUtc <= data.modifyUtc, @"if local data is new and completed. bug");
                RLMObject<DataSyncRealmDataDelegate> * newRealmData = [(NSObject *)data data:self.realmClass];
                newRealmData.status = Completed;
                [realm addOrUpdateObject:newRealmData];
            }
        } else {
            RLMObject<DataSyncRealmDataDelegate> * newRealmData = [(NSObject *)data data:self.realmClass];
            newRealmData.status = Completed;
            [realm addOrUpdateObject:newRealmData];
        }
    }
    [realm commitWriteTransaction];
}

- (int)maxServerUpdateUtc {
    return [[[self.realmClass allObjects] maxOfProperty:@"serverUpdateUtc"] intValue];
}

@end
