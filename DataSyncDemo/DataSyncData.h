//
//  DataSyncData.h
//  DataSyncDemo
//
//  Created by sijiechen3 on 16/10/11.
//  Copyright © 2016年 sijiechen3. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LargeDataSyncDelegate.h"
#import "SmallDataSyncDelegate.h"
#import <Mantle/Mantle.h>
#import <Realm/Realm.h>

@interface DataSyncData : NSObject <DataSyncSmallDataDelegate>

// 讲道理，data其实并没有必要控制realm data存储状态等相关的东西，应该在store时候realm data自动进行相关状态的切换
// 除非我们想手动控制状态才需要对应上...
@property (strong, nonatomic) NSString * key;
//@property (assign, nonatomic) UploadStatus status;
//@property (assign, nonatomic) int modifyUtc;
//@property (assign, nonatomic) int serverUpdateUtc;

@end

@interface DataSyncRealmData : RLMObject <DataSyncRealmSmallDataDelegate>

@property NSString * key;
@property UploadStatus status;
@property int modifyUtc;
//@property int serverUpdateUtc;
//@property int retryCount;

- (void)addOrUpdate;
- (void)addOrUpdateWithUploadStatus:(UploadStatus)status modifyUtc:(int)modifyUtc;

@end

@interface DataSyncUploadResponseData : NSObject <DataSyncUploadResponseSmallDataDelegate>

@property (strong, nonatomic) NSString * key;
@property (assign, nonatomic) UploadResponseStatus status;
//@property (assign, nonatomic) int serverUpdateUtc;

@end

@interface DataSyncDownloadResponseData : NSObject <DataSyncDownloadResponseSmallDataDelegate>

@property (strong, nonatomic) NSString * key;
@property (assign, nonatomic) int modifyUtc;
//@property (assign, nonatomic) int serverUpdateUtc;

@end
