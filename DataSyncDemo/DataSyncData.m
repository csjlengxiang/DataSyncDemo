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

//- (DataSyncRealmData *)RealmData {
//    DataSyncRealmData * data = [[DataSyncRealmData alloc] init];
//    data.key = self.key;
//    data.status = self.status;
//    data.modifyUtc = self.modifyUtc;
//    return data;
//}
//
//- (DataSyncMantleData *)MantleData {
//    DataSyncMantleData * data = [[DataSyncMantleData alloc] init];
//    data.key = self.key;
//    data.modifyUtc = self.modifyUtc;
//    return data;
//}

- (void)update {
    self.status = Wait;
    [[self data:[DataSyncRealmData class]] store];
}

@end

@implementation DataSyncRealmData

+ (NSString *)primaryKey {
    return @"key";
}

- (void)store {
    [[RealmDataManager sharedInstance] store:self];
}

@end

@implementation DataSyncMantleData

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{@"key": @"key",
             @"modifyUtc": @"modify_utc"
             };
}

@end
