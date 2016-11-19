//
//  DataSyncDelegate.h
//  DataSyncDemo
//
//  Created by sijiechen3 on 16/10/11.
//  Copyright © 2016年 sijiechen3. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, UploadStatus) {
    Wait,
    Ing,
    Completed,
};

typedef NS_ENUM(NSInteger, UploadResponseStatus) {
    Success,
    Failure,
};

@protocol DataSyncRealmLargeDataDelegate

@property NSString * key;
@property UploadStatus status;
@property int modifyUtc;
@property int serverUpdateUtc;
@property int retryCount;

@end

@protocol DataSyncLargeDataDelegate

@property (strong, nonatomic) NSString * key;
@property (assign, nonatomic) UploadStatus status;
@property (assign, nonatomic) int modifyUtc;
@property (assign, nonatomic) int serverUpdateUtc;

@end

@protocol DataSyncUploadResponseLargeDataDelegate

@property (strong, nonatomic) NSString * key;
@property (assign, nonatomic) UploadResponseStatus status;
@property (assign, nonatomic) int serverUpdateUtc;

@end

@protocol DataSyncDownloadResponseLargeDataDelegate

@property (strong, nonatomic) NSString * key;
@property (assign, nonatomic) int modifyUtc;
@property (assign, nonatomic) int serverUpdateUtc;

@end
