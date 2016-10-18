//
//  DataSyncManager.h
//  DataSyncDemo
//
//  Created by sijiechen3 on 16/10/11.
//  Copyright © 2016年 sijiechen3. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataSyncManager : NSObject

+ (instancetype)sharedInstance;
- (void)upload;
- (void)download;

@end
