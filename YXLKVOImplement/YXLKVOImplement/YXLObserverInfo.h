//
//  YXLObserverInfo.h
//  YXLKVOImplement
//
//  Created by Tangtang on 16/6/10.
//  Copyright © 2016年 Tangtang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  用来执行观察者返回的数据的block
 *
 *  @param ObservedObj Observe
 *  @param ObservedKey 对应Observe的key
 *  @param newValue    改变后的新值
 *  @param oldValue    旧值
 */
typedef void(^YXLKVOBlock)(id ObservedObj, NSString *ObservedKey, id newValue, id oldValue);

@interface YXLObserverInfo : NSObject

@property (nonatomic, weak) NSObject        *observer;
@property (nonatomic, copy) NSString        *obsKey;
@property (nonatomic, copy) YXLKVOBlock     kvoBlock;


/**
 *  初始化被观察者信息类
 *
 *  @param observer 被观察者
 *  @param key      被观察者对应的key
 *  @param block    block
 *
 *  @return 返回YXLObserverInfo类的实例
 */
- (instancetype)initWithObserver:(NSObject *)observer Key:(NSString *)key block:(YXLKVOBlock)block;

@end
