//
//  DataSyncDelegate.h
//  DataSyncDemo
//
//  Created by sijiechen3 on 16/10/11.
//  Copyright © 2016年 sijiechen3. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SmallDataSyncDelegate.h"

@protocol DataSyncRealmLargeDataDelegate <DataSyncRealmSmallDataDelegate>

@property int serverUpdateUtc;
@property int retryCount;

@end

@protocol DataSyncLargeDataDelegate <DataSyncSmallDataDelegate>

@property (assign, nonatomic) int serverUpdateUtc;

@end

@protocol DataSyncUploadResponseLargeDataDelegate <DataSyncUploadResponseSmallDataDelegate>

@property (assign, nonatomic) int serverUpdateUtc;

@end

@protocol DataSyncDownloadResponseLargeDataDelegate <DataSyncDownloadResponseSmallDataDelegate>

@property (assign, nonatomic) int serverUpdateUtc;

@end
