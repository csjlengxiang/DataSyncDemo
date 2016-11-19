//
//  DataSyncData.h
//  DataSyncDemo
//
//  Created by sijiechen3 on 16/10/11.
//  Copyright © 2016年 sijiechen3. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LargeDataSyncDelegate.h"
#import <Mantle/Mantle.h>
#import <Realm/Realm.h>

@interface DataSyncData : NSObject <DataSyncLargeDataDelegate>

@property (strong, nonatomic) NSString * key;
@property (assign, nonatomic) UploadStatus status;
@property (assign, nonatomic) int modifyUtc;
@property (assign, nonatomic) int serverUpdateUtc;

@end

@interface DataSyncRealmData : RLMObject <DataSyncRealmLargeDataDelegate>

@property NSString * key;
@property UploadStatus status;
@property int modifyUtc;
@property int serverUpdateUtc;
@property int retryCount;

- (void)store;

@end

@interface DataSyncUploadResponseData : NSObject <DataSyncUploadResponseLargeDataDelegate>

@property (strong, nonatomic) NSString * key;
@property (assign, nonatomic) UploadResponseStatus status;
@property (assign, nonatomic) int serverUpdateUtc;

@end

@interface DataSyncDownloadResponseData : NSObject <DataSyncDownloadResponseLargeDataDelegate>

@property (strong, nonatomic) NSString * key;
@property (assign, nonatomic) int modifyUtc;
@property (assign, nonatomic) int serverUpdateUtc;

@end
