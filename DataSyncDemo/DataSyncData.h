//
//  DataSyncData.h
//  DataSyncDemo
//
//  Created by sijiechen3 on 16/10/11.
//  Copyright © 2016年 sijiechen3. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataSyncDelegate.h"
#import <Mantle/Mantle.h>
#import <Realm/Realm.h>

@class DataSyncRealmData;
@class DataSyncRequesteData;

@interface DataSyncData : NSObject ///<DataSyncDataDelegate>

@property (strong, nonatomic) NSString * key;
@property (assign, nonatomic) UploadStatus status;
@property (assign, nonatomic) int modifyUtc;
@property (assign, nonatomic) int serverUpdateUtc;

- (void)update;

@end

@interface DataSyncRealmData : RLMObject 

@property NSString * key;
@property UploadStatus status;
@property int modifyUtc;
@property int serverUpdateUtc;

- (void)store;

@end

@interface DataSyncRequestData : MTLModel <MTLJSONSerializing>

@property (strong, nonatomic) NSString * key;
@property (assign, nonatomic) int modifyUtc;

@end

@interface DataSyncResponseData : MTLModel <MTLJSONSerializing, DataSyncResponseDataDelegate>

@property (strong, nonatomic) NSString * key;
@property (assign, nonatomic) UploadResponseStatus status;
@property (assign, nonatomic) int serverUpdateUtc;

@end
