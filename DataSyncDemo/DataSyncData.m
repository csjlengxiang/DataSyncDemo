//
//  DataSyncData.m
//  DataSyncDemo
//
//  Created by sijiechen3 on 16/10/11.
//  Copyright © 2016年 sijiechen3. All rights reserved.
//

#import "DataSyncData.h"
//#import "RealmLargeDataManager.h"
#import "RealmSmallDataManager.h"
#import <objc/runtime.h>
#import "NSObject+DataChange.h"

@implementation DataSyncData

@end

@implementation DataSyncRealmData

+ (NSString *)primaryKey {
    return @"key";
}

- (void)store {
    [RealmSmallDataManager store:self];
}

@end

@implementation DataSyncUploadResponseData

@end

@implementation DataSyncDownloadResponseData

@end
