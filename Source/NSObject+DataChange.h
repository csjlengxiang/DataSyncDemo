//
//  NSObject+DataChange.h
//  DataSyncDemo
//
//  Created by sijiechen3 on 2016/10/17.
//  Copyright © 2016年 sijiechen3. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

@interface NSObject (DataChange)

- (id)data:(Class)class;

@end
