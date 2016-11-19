//
//  NSObject+DataChange.m
//  DataSyncDemo
//
//  Created by sijiechen3 on 2016/10/17.
//  Copyright © 2016年 sijiechen3. All rights reserved.
//

#import "NSObject+DataChange.h"
#import <Realm/Realm.h>

@implementation NSObject (DataChange)

+ (NSArray<NSString *> *)getPropertyKeys:(Class)modelClass {
    NSMutableArray<NSString *> * result = [NSMutableArray<NSString *> array];
    if ([modelClass isSubclassOfClass:[RLMObject class]]) {
        NSArray<RLMProperty *> *properties = [[[[modelClass alloc] init] objectSchema] properties];
        for (RLMProperty * property in properties) {
            [result addObject:property.name];
        }
    } else {
        unsigned int propertiesCount;
        objc_property_t *properties = class_copyPropertyList(modelClass, &propertiesCount);
        for(unsigned int i = 0; i < propertiesCount; i++) {
            objc_property_t property = properties[i];
            NSString * key = [[NSString alloc] initWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
            if ([key isEqualToString:@"hash"] ||
                [key isEqualToString:@"superclass"] ||
                [key isEqualToString:@"debugDescription"] ||
                [key isEqualToString:@"description"]
                ) {
                continue;
            }
            [result addObject:key];
        }
        free(properties);
    }
    return [result copy];
}

- (BOOL)containsProperty:(NSString *)property {
    return [[NSMutableSet setWithArray:[NSObject getPropertyKeys:[self class]]] containsObject:property];
}

- (id)data:(Class)class {
    NSMutableSet<NSString *> * keysSet = [NSMutableSet setWithArray:[NSObject getPropertyKeys:[self class]]];
    NSMutableSet<NSString *> * dataKeysSet = [NSMutableSet setWithArray:[NSObject getPropertyKeys:class]];
    [keysSet intersectSet:dataKeysSet];
//    NSLog(@"key set: %@", keysSet);
    NSArray<NSString *> * keyArr = [keysSet allObjects];
    id data = [[class alloc] init];
    for (NSString * key in keyArr) {
        [data setValue:[self valueForKey:key] forKey:key];
    }
    return data;
}

@end
