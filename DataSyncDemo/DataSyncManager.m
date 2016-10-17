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

@interface DataSyncManager ()

@property (strong, nonatomic) RealmDataManager * realmDataManager;

@end

@implementation DataSyncManager

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
        self.realmDataManager = [[RealmDataManager alloc] initWithDataClass:[DataSyncData class] realmClass:[DataSyncRealmData class]];
    }
    return self;
}

- (void)upload {
    NSLog(@"-- start upload");
    
    NSArray<DataSyncData *> * res = [self.realmDataManager waitUploadSyncData];
    NSMutableArray <DataSyncRequestData *> * mantleArr = [NSMutableArray new];
    for (DataSyncData * data in res) {
        [mantleArr addObject:[data data:[DataSyncRequestData class]]];
    }
    NSError * error = nil;
    NSArray * dic = [MTLJSONAdapter JSONArrayFromModels:mantleArr error:&error];
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:@{@"arr_data": dic} options:0 error:&error];
    NSString * result = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    // 模拟上传
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        NSData * json = [result dataUsingEncoding:NSUTF8StringEncoding];
        NSError * err;
        NSMutableDictionary * dic = [NSJSONSerialization JSONObjectWithData:json
                                                             options:NSJSONReadingMutableContainers
                                                               error:&err];
        dic[@"server_update_utc"] = @([[NSDate date] timeIntervalSince1970]);

        
        NSMutableArray<DataSyncResponseData *> * responseArr = [NSMutableArray new];
        for (id responseData in dic[@"arr_data"]) {
            DataSyncResponseData * data = [DataSyncResponseData new];
            data.key = responseData[@"key"];
            data.serverUpdateUtc = [responseData[@"modify_utc"] intValue] + 10;
            data.status = Success;
            [responseArr addObject:data];
        }
        
        [self.realmDataManager storeArr:responseArr];
        
        //[self.realmDataManager storeArr:uploadingData];
        
        //NSLog(@"response ans %@", uploadingData);
    });
}

@end
