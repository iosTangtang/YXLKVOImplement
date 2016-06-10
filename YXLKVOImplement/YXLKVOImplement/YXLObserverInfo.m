//
//  YXLObserverInfo.m
//  YXLKVOImplement
//
//  Created by Tangtang on 16/6/10.
//  Copyright © 2016年 Tangtang. All rights reserved.
//

#import "YXLObserverInfo.h"

@implementation YXLObserverInfo

- (instancetype)initWithObserver:(NSObject *)observer Key:(NSString *)key block:(YXLKVOBlock)block {
    self = [super self];
    if (self) {
        _observer = observer;
        _obsKey = key;
        _kvoBlock = block;
    }
    return self;
}

@end
