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

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    for (int i = 0; i < 10; i++) {
        DataSyncData * data = [[DataSyncData alloc] init];
        data.key = [NSString stringWithFormat:@"key %d", i];
        data.status = Wait;
        data.modifyUtc = [[NSDate date] timeIntervalSince1970];
        [[data RealmData] store];
    }
    
    NSString * res =
    [[DataSyncManager sharedInstance] uploadJsonStr];
    
    NSLog(@"---- json %@", res);
}

@end
