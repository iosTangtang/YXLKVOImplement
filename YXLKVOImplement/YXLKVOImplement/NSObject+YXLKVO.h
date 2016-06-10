//
//  NSObject+YXLKVO.h
//  YXLKVOImplement
//
//  Created by Tangtang on 16/6/10.
//  Copyright © 2016年 Tangtang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YXLObserverInfo.h"

@interface NSObject (YXLKVO)

/**
 *  添加观察者方法
 *
 *  @param observer    被观察的对象
 *  @param key         对应的key值
 *  @param resultBlock 数值改变之后返回数据的block
 */
- (void)YXL_addObserver:(NSObject *)observer
                WithKey:(NSString *)key
            resultBlock:(YXLKVOBlock)resultBlock;

/**
 *  移除观察者的方法
 *
 *  @param observer 要删除的被观察者
 *  @param key      要删除的被观察者的key值
 */
- (void)YXL_removeObserver:(NSObject *)observer withKey:(NSString *)key;

@end
