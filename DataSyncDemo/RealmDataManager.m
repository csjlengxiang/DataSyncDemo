//
//  RealmDataManager.m
//  DataSyncDemo
//
//  Created by sijiechen3 on 16/10/11.
//  Copyright © 2016年 sijiechen3. All rights reserved.
//

#import "RealmDataManager.h"
#import "DataSyncDelegate.h"

@interface RealmDataManager ()

@property (nonatomic, strong) dispatch_queue_t ioQueue;

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
        self.ioQueue = dispatch_queue_create("ioQueue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (void)store:(RLMObject *)object {
    dispatch_async(self.ioQueue, ^{
        RLMRealm *realm = [RLMRealm defaultRealm];
        [realm transactionWithBlock:^{
            [realm addOrUpdateObject:object];
        }];
    });
}

- (void)ustore:(RLMObject *)object {
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm transactionWithBlock:^{
        [realm addOrUpdateObject:object];
    }];
}

- (void)urunInRealm:(void (^)())block {
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm transactionWithBlock:^{
        block();
    }];
}

- (id)runBlock:(id (^)())block {
    __block id res;
    dispatch_sync(self.ioQueue, ^{
        res = block();
    });
    return res;
}

@end
