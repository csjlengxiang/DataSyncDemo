//
//  ViewController.m
//  DataSyncDemo
//
//  Created by sijiechen3 on 16/10/11.
//  Copyright © 2016年 sijiechen3. All rights reserved.
//

#import "ViewController.h"
#import "DataSyncData.h"
#import "DataSyncManager.h"
#import "NSObject+DataChange.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [DataSyncManager sharedInstance];
    
    for (int i = 0; i < 10; i++) {
        DataSyncData * data = [[DataSyncData alloc] init];
        data.key = [NSString stringWithFormat:@"key %d", i];
        //data.status = Wait;
        //data.modifyUtc = [[NSDate date] timeIntervalSince1970];
        [[data data:[DataSyncRealmData class]] addOrUpdate];
    }
    
    [[DataSyncManager sharedInstance] upload];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[DataSyncManager sharedInstance] download];
    });
    

    RLMRealm * realm = [RLMRealm defaultRealm];
    NSLog(@"%@", realm.configuration.fileURL);
}

@end
