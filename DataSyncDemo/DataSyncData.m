//
//  DataSyncData.m
//  DataSyncDemo
//
//  Created by sijiechen3 on 16/10/11.
//  Copyright © 2016年 sijiechen3. All rights reserved.
//

#import "DataSyncData.h"
#import "RealmDataManager.h"
#import <objc/runtime.h>
#import "NSObject+DataChange.h"

@implementation DataSyncData

@end

@implementation DataSyncRealmData

+ (NSString *)primaryKey {
    return @"key";
}

- (void)store {
    self.status = Wait;
    self.modifyUtc = [[NSDate date] timeIntervalSince1970];
    [RealmDataManager store:self];
}

- (void)addOrUpdate {
    self.status = Wait;
    self.modifyUtc = [[NSDate date] timeIntervalSince1970];
    [RealmDataManager store:self];
}

- (void)addOrUpdateWithUploadStatus:(UploadStatus)status modifyUtc:(int)modifyUtc {
    self.status = status;
    self.modifyUtc = modifyUtc;
    [RealmDataManager store:self];
}

@end

@implementation DataSyncUploadResponseData

@end

@implementation DataSyncDownloadResponseData

@end
