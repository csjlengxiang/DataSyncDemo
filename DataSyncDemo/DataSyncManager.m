//
//  DataSyncManager.m
//  DataSyncDemo
//
//  Created by sijiechen3 on 16/10/11.
//  Copyright © 2016年 sijiechen3. All rights reserved.
//

#import "DataSyncManager.h"
#import "RealmDataManager.h"
#import "DataSyncData.h"
#import "NSObject+DataChange.h"

@implementation DataSyncManager

+ (instancetype)sharedInstance {
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[[self class] alloc] init];
    });
    return instance;
}

- (NSString *)uploadJsonStr {
    NSArray<DataSyncData *> * res = [[RealmDataManager sharedInstance] waitUploadSyncData];
    NSMutableArray <DataSyncMantleData *> * mantleArr = [NSMutableArray new];
    for (DataSyncData * data in res) {
        [mantleArr addObject:[data data:[DataSyncMantleData class]]];
    }
    NSError * error = nil;
    NSArray * dic = [MTLJSONAdapter JSONArrayFromModels:mantleArr error:&error];
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:@{@"arr_data": dic} options:0 error:&error];
    NSString * result = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return result;
}

- (void)upload {
    NSLog(@"-- start upload");
    NSString * str = [self uploadJsonStr];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSData * jsonData = [str dataUsingEncoding:NSUTF8StringEncoding];
        NSError * err;
        NSMutableDictionary * dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                             options:NSJSONReadingMutableContainers
                                                               error:&err];
        dic[@"server_update_utc"] = @([[NSDate date] timeIntervalSince1970]);
        
        NSLog(@"response dic %@", dic);
        
        NSArray <DataSyncData *> *uploadingData = [[RealmDataManager sharedInstance] uploadingSyncData];
        
        for (DataSyncData * data in uploadingData) {
            if (dic[data.key]) {
                // success
                data.status = Completed;
                data.serverUpdateUtc = [dic[data.key] intValue] + 10;
            } else {
                data.status = Wait;
                data.serverUpdateUtc = [dic[data.key] intValue] + 10;
            }
        }
        
        NSLog(@"response ans %@", uploadingData);
    });
}

@end
