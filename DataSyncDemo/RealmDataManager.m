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

+ (void)store:(RLMObject *)object {
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm transactionWithBlock:^{
        [realm addOrUpdateObject:object];
    }];
}

- (NSArray<id<DataSyncDataDelegate>> *)waitUploadSyncData {
    [self reset];
    NSMutableArray * ret = [NSMutableArray new];
    RLMRealm *realm = [RLMRealm defaultRealm];
    // 注意此处需要原子操作
    [realm beginWriteTransaction];
    RLMResults * arr = [[self.realmClass allObjects] objectsWhere:@"status == %d", Wait];
    for (id<DataSyncRealmDataDelegate> data in arr) {
        data.status = Ing;
        [ret addObject:[(NSObject *)data data:self.dataClass]];
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
    }
    [realm commitWriteTransaction];
}

- (void)storeDownloadResponseArr:(NSArray<id<DataSyncDownloadResponseDataDelegate>> *)responseArr {
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    for (id<DataSyncDownloadResponseDataDelegate> data in responseArr) {
        NSString * key = data.key;
        id<DataSyncRealmDataDelegate> localRealmData = [self.realmClass objectForPrimaryKey:key];
        if (localRealmData) {
            if (localRealmData.status == Wait) {
                if (localRealmData.modifyUtc < data.modifyUtc) { // 被新数据覆盖
                    id<DataSyncRealmDataDelegate> newRealmData = [(NSObject *)data data:self.realmClass];
                    newRealmData.status = Completed;
                    [realm addOrUpdateObject:newRealmData];
                }
            } else if (localRealmData.status == Ing) {
                NSAssert(localRealmData.status != Ing, @"download data will not uploading");
            } else if (localRealmData.status == Completed) {
                NSAssert(localRealmData.modifyUtc <= data.modifyUtc, @"if local data is new and completed. bug");
                id<DataSyncRealmDataDelegate> newRealmData = [(NSObject *)data data:self.realmClass];
                newRealmData.status = Completed;
                [realm addOrUpdateObject:newRealmData];
            }
        } else {
            id<DataSyncRealmDataDelegate> newRealmData = [(NSObject *)data data:self.realmClass];
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
