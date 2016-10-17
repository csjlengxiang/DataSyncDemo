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

- (NSArray *)uploadingSyncData {
    NSMutableArray * ret = [NSMutableArray new];
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    RLMResults * arr = [[self.realmClass allObjects] objectsWhere:@"status == %d", Ing];
    for (id data in arr) {
        [ret addObject:[(NSObject *)data data:self.dataClass]];
    }
    [realm commitWriteTransaction];
    return ret;
}

- (NSArray *)waitUploadSyncData {
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

- (void)storeArr:(NSArray<id<DataSyncResponseDataDelegate>> *)responseArr {
    NSMutableDictionary * responseDic = [NSMutableDictionary new]; // 全集
    for (id<DataSyncResponseDataDelegate> responseData in responseArr) {
        responseDic[responseData.key] = responseData;
    }
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    RLMResults * arr = [[self.realmClass allObjects] objectsWhere:@"status == %d", Ing];
    for (id<DataSyncRealmDataDelegate> data in arr) { // 在上传过程中可能将ing->wait，故这里是子集
        if (responseDic[data.key]) {
            id<DataSyncResponseDataDelegate> responseData = responseDic[data.key];
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
    
    NSLog(@"%@", realm.configuration.fileURL);
}

@end
