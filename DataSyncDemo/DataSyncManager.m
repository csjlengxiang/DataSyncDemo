 //
//  DataSyncManager.m
//  DataSyncDemo
//
//  Created by sijiechen3 on 16/10/11.
//  Copyright © 2016年 sijiechen3. All rights reserved.
//

#import "DataSyncManager.h"
//#import "RealmLargeDataManager.h"
#import "RealmDataManager.h"
#import "DataSyncData.h"
#import "NSObject+DataChange.h"

@interface DataSyncUploadRequestData : MTLModel <MTLJSONSerializing>

@property (strong, nonatomic) NSString * key;
@property (assign, nonatomic) int modifyUtc;

@end

@implementation DataSyncUploadRequestData

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{@"key": @"key",
             @"modifyUtc": @"modify_utc"
             };
}

@end

@interface DataSyncDownloadRequestData : MTLModel <MTLJSONSerializing>

//@property (assign, nonatomic) int serverUpdateUtc;
//@property (assign, nonatomic) int number;

@end

@implementation DataSyncDownloadRequestData

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{//@"serverUpdateUtc": @"server_update_utc",
//             @"number": @"page_size"
             };
}

@end

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
        [self setupRealm];
        self.realmDataManager = [[RealmDataManager alloc] initWithDataClass:[DataSyncData class] realmClass:[DataSyncRealmData class]];
    }
    return self;
}

- (void)setupRealm {
    RLMRealmConfiguration *config = [RLMRealmConfiguration defaultConfiguration];
    config.schemaVersion = 1;
    config.migrationBlock = ^(RLMMigration *migration, uint64_t oldSchemaVersion) {
        if (oldSchemaVersion < 1) {
            // add retry count. default is 0.
        }
    };
    [RLMRealmConfiguration setDefaultConfiguration:config];
}

- (void)upload {
    NSLog(@"-- start upload");
    
    // 模拟请求的数据
    NSArray<DataSyncData *> * res = (NSArray<DataSyncData *> *)[self.realmDataManager waitUploadSyncData];
    NSMutableArray <DataSyncUploadRequestData *> * mantleArr = [NSMutableArray new];
    for (DataSyncData * data in res) {
        [mantleArr addObject:[data data:[DataSyncUploadRequestData class]]];
    }
    NSError * error = nil;
    NSArray * dic = [MTLJSONAdapter JSONArrayFromModels:mantleArr error:&error];
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:@{@"arr_data": dic} options:0 error:&error];
    NSString * result = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    // 模拟上传
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

        // 模拟返回的数据
        NSData * json = [result dataUsingEncoding:NSUTF8StringEncoding];
        NSError * err;
        NSMutableDictionary * dic = [NSJSONSerialization JSONObjectWithData:json
                                                             options:NSJSONReadingMutableContainers
                                                               error:&err];
//        dic[@"server_update_utc"] = @([[NSDate date] timeIntervalSince1970]);
        NSMutableArray<DataSyncUploadResponseData *> * responseArr = [NSMutableArray new];
        for (id responseData in dic[@"arr_data"]) {
            DataSyncUploadResponseData * data = [DataSyncUploadResponseData new];
            data.key = responseData[@"key"];
//            data.serverUpdateUtc = [responseData[@"modify_utc"] intValue] + 10;
            data.status = Success;
            [responseArr addObject:data];
        }
        [self.realmDataManager storeUploadResponseArr:responseArr];
    });
}

- (void)download {
    NSLog(@"-- start download");
    [self.realmDataManager reset];
    // 模拟请求的数据
    DataSyncDownloadRequestData * downloadRequest = [[DataSyncDownloadRequestData alloc] init];
//    downloadRequest.serverUpdateUtc = [self.realmDataManager maxServerUpdateUtc];
//    downloadRequest.number = 100;
    
    // 模拟请求
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 模拟返回的数据
        NSMutableArray <DataSyncDownloadResponseData *> * responseArr = [NSMutableArray new];
        for (int i = 0; i < 10; i++) {
            DataSyncDownloadResponseData * data = [[DataSyncDownloadResponseData alloc] init];
            data.key = [NSString stringWithFormat:@"download key %d", i];
//            data.serverUpdateUtc = [[NSDate date] timeIntervalSince1970] + 10;
            data.modifyUtc = [[NSDate date] timeIntervalSince1970];
            [responseArr addObject:data];
        }
        [self.realmDataManager storeDownloadResponseArr:responseArr];
        NSLog(@"-- download compeleted %@", responseArr);
    });
}

@end
