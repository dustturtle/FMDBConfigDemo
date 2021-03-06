//
//  FMDBConfig.h
//  FMDBConfigDemo
//
//  Created by Zhenwei Guan on 2018/10/11.
//  Copyright © 2018 Zhenwei Guan. All rights reserved.
//
//  已经支持了多线程并发，设置/取值/清理都是用queue来操作，保证线程安全。

#import <Foundation/Foundation.h>


#define GFMDBConfig [FMDBConfig sharedInstance]

// oc中的枚举不支持，目前就列举在这里，使用字符串; 不支持default,全部为空字符串/NO。

#define kTestConfig1 @"kTestConfig1"
#define kTestConfig2 @"kTestConfig2"
#define kTestConfig3 @"kTestConfig3"

#define kUserName @"kUserName"
#define kPassword @"kPassword"
#define kIsMuted @"kIsMuted"


@interface FMDBConfig : NSObject

+ (FMDBConfig *)sharedInstance;

- (BOOL)configWithKey:(NSString *)key value:(NSString *)value;

- (NSString *)valueFromKey:(NSString *)key;

// 用于保存开关类的配置项: @"0" NO/@"1" YES
- (BOOL)flagFromKey:(NSString *)key;

// 特殊用途，删除所有配置项的值。
- (void)cleanAll;

@end

