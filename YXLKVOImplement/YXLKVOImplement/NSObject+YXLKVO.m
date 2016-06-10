//
//  NSObject+YXLKVO.m
//  YXLKVOImplement
//
//  Created by Tangtang on 16/6/10.
//  Copyright © 2016年 Tangtang. All rights reserved.
//

#import "NSObject+YXLKVO.h"
#import <objc/runtime.h>
#import <objc/message.h>

NSString *const kYXLClassPreFix = @"kYXLClassPreFix_";
NSString *const kYXLKVOAssociatedObservers = @"kYXLKVOAssociatedObservers";

@implementation NSObject (YXLKVO)

#pragma mark - getter->setter
static NSString *getterToSetter(NSString *getter) {
    if (getter.length <= 0) {
        return nil;
    }
    
    NSString *firstStr = [[getter substringToIndex:1] uppercaseString];
    NSString *otherStr = [getter substringFromIndex:1];
    
    NSString *setter = [NSString stringWithFormat:@"set%@%@:", firstStr, otherStr];
    
    return setter;
}

#pragma mark - setter->getter
static NSString *setterToGetter(NSString *setter) {
    if (setter.length <= 0 || ![setter hasPrefix:@"set"] || ![setter hasSuffix:@":"]) {
        return nil;
    }
    
    NSRange range = NSMakeRange(3, setter.length - 4);
    NSString *getter = [setter substringWithRange:range];
    NSString *firstStr = [[getter substringToIndex:1] lowercaseString];
    getter = [getter stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:firstStr];
    
    return getter;
}

#pragma mark - 重写class方法
static Class kvo_Class(id self, SEL _cmd) {
    return class_getSuperclass(object_getClass(self));
}

#pragma mark - 重写setter方法
static void kvo_Setter(id self, SEL _cmd, id newValue) {
    NSString *setter = NSStringFromSelector(_cmd);
    NSString *getter = setterToGetter(setter);
    
    if (!getter) {
        NSLog(@"getter method nothingness!!");
        return;
    }
    
    id oldValue = [self valueForKey:getter];
    
    //定义发送给父类的结构体
    struct objc_super superClass = {
        .receiver = self,
        .super_class = class_getSuperclass(object_getClass(self))
    };
    
    void (*objc_msgSendSuperCase)(void *, SEL, id) = (void *)objc_msgSendSuper;
    objc_msgSendSuperCase(&superClass, _cmd, newValue);
    
    NSMutableArray *observers = objc_getAssociatedObject(self, (__bridge const void *)kYXLKVOAssociatedObservers);
    [observers enumerateObjectsUsingBlock:^(YXLObserverInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.obsKey isEqualToString:getter]) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                obj.kvoBlock(self, getter, newValue, oldValue);
            });
        }
    }];
}

#pragma mark - KVO方法
- (void)YXL_addObserver:(NSObject *)observer
                WithKey:(NSString *)key
            resultBlock:(YXLKVOBlock)resultBlock {
    //根据getter方法转为setter方法,获取setter方法的实现 若不存在，则不进行下面的操作
    SEL setterSelector = NSSelectorFromString(getterToSetter(key));
    Method setterMethod = class_getInstanceMethod([self class], setterSelector);
    if (!setterMethod) {
        NSLog(@"setter method nothingness!!");
        return;
    }
    
    //查看是否添加前缀
    Class cla = object_getClass(self);
    NSString *classStr = NSStringFromClass(cla);
    
    if (![classStr hasPrefix:kYXLClassPreFix]) {
        cla = [self makeKVOClassWithClassName:classStr];
        //将对象指针修改指向中间类
        object_setClass(self, cla);
    }
    
    //查看是否重写Setter方法
    if (![self isOverriddenSetter:setterSelector]) {
        const char *type = method_getTypeEncoding(setterMethod);
        class_addMethod(cla, setterSelector, (IMP)kvo_Setter, type);
    }
    
    YXLObserverInfo *info = [[YXLObserverInfo alloc] initWithObserver:observer Key:key block:resultBlock];
    NSMutableArray *observers = objc_getAssociatedObject(self, (__bridge const void *)(kYXLKVOAssociatedObservers));
    if (!observers) {
        observers = [NSMutableArray array];
        objc_setAssociatedObject(self, (__bridge void *)kYXLKVOAssociatedObservers, observers, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    [observers addObject:info];
}

- (void)YXL_removeObserver:(NSObject *)observer withKey:(NSString *)key {
    NSMutableArray *observers = objc_getAssociatedObject(self, (__bridge const void *)kYXLKVOAssociatedObservers);
    YXLObserverInfo *observerInfo = nil;
    for (YXLObserverInfo *obser in observers) {
        if (obser.observer == observer && [obser.obsKey isEqualToString:key]) {
            observerInfo = obser;
            break;
        }
    }
    
    [observers removeObject:observerInfo];
}

#pragma mark - 创建中间的kvo监测类
- (Class)makeKVOClassWithClassName:(NSString *)originName {
    NSString *KVOString = [kYXLClassPreFix stringByAppendingString:originName];
    Class cla = NSClassFromString(KVOString);
    
    if (cla) {
        return cla;
    }
    
    Class originCla = object_getClass(self);
    //动态创建一个新类
    Class KVOClass = objc_allocateClassPair(originCla, KVOString.UTF8String, 0);
    Method classMethod = class_getInstanceMethod(originCla, @selector(class));
    const char *type = method_getTypeEncoding(classMethod);
    
    //修改class方法, 隐藏新创的类信息
    class_addMethod(KVOClass, @selector(class), (IMP)kvo_Class, type);
    
    objc_registerClassPair(KVOClass);
    
    return KVOClass;
}

#pragma mark - 检查是否重写setter的方法
- (BOOL)isOverriddenSetter:(SEL)selector {
    Class cla = object_getClass(self);
    unsigned int icount = 0;
    Method *methodList = class_copyMethodList(cla, &icount);
    for (unsigned int i = 0; i < icount; i++) {
        SEL nowSelector = method_getName(methodList[i]);
        if (nowSelector == selector) {
            free(methodList);
            return YES;
        }
    }
    
    free(methodList);
    return NO;
}

@end
