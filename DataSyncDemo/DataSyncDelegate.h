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



//@protocol DataSyncAarryDataDelegate <NSObject>
//
//@property (strong, nonatomic) NSString * key;
//@property (assign, nonatomic) UploadStatus status;
//
//@end
//
@protocol DataSyncDataDelegate <NSObject>
//
//@property (strong, nonatomic) NSString * key;
//@property (assign, nonatomic) UploadStatus status;
//
@end
//
@protocol DataSyncRealmDataDelegate <NSObject>

//- (id)Data;
@property (strong, nonatomic) NSString * key;
@property (assign, nonatomic) UploadStatus status;
@property (assign, nonatomic) int serverUpdateUtc;

@end

@protocol DataSyncResponseDataDelegate <NSObject>

@property (strong, nonatomic) NSString * key;
@property (assign, nonatomic) UploadResponseStatus status;
@property (assign, nonatomic) int serverUpdateUtc;

@end
