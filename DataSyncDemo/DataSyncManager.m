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
    NSArray * res = [[RealmDataManager sharedInstance] runBlock:^id{
        RLMResults * datas = [DataSyncRealmData allObjects];
        __block NSMutableArray * arr = [NSMutableArray new];
        
        for (DataSyncRealmData * realmData in datas) {
            
            DataSyncData * data = [realmData Data];
            data.status = Ing;
            [[RealmDataManager sharedInstance] ustore:[data RealmData]];
            [arr addObject:[data MantleData]];
        }
        return arr;
    }];
    
    NSError * error = nil;
    NSArray * dic = [MTLJSONAdapter JSONArrayFromModels:res error:&error];
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:@{@"arr_data": dic} options:0 error:&error];
    NSString * result = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return result;
}

@end
