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

- (instancetype)init {
    if (self = [super init]) {
        
    }
    return self;
}

- (void)store:(RLMObject *)object {
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm transactionWithBlock:^{
        [realm addOrUpdateObject:object];
    }];
}

- (NSArray *)uploadingSyncData {
    NSMutableArray * ret = [NSMutableArray new];
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    RLMResults * arr = [[DataSyncRealmData allObjects] objectsWhere:@"status == %d", Ing];
    for (DataSyncRealmData * data in arr) {
        [ret addObject:[data data:[DataSyncData class]]];
    }
    [realm commitWriteTransaction];
    return ret;
}

- (NSArray<DataSyncData *> *)waitUploadSyncData {
    [self reset];
    NSMutableArray * ret = [NSMutableArray new];
    RLMRealm *realm = [RLMRealm defaultRealm];
    // 注意此处需要原子操作
    [realm beginWriteTransaction];
    RLMResults * arr = [[DataSyncRealmData allObjects] objectsWhere:@"status == %d", Wait];
    for (DataSyncRealmData * data in arr) {
        data.status = Ing;
        [ret addObject:[data data:[DataSyncData class]]];
    }
    [realm commitWriteTransaction];
    return ret;
}

- (void)reset {
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    RLMResults * arr = [[DataSyncRealmData allObjects] objectsWhere:@"status == %d", Ing];
    for (DataSyncRealmData * data in arr) {
        data.status = Wait;
    }
    [realm commitWriteTransaction];
}

@end
