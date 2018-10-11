//
//  FMDBConfig.m
//  FMDBConfigDemo
//
//  Created by Zhenwei Guan on 2018/10/11.
//  Copyright © 2018 Zhenwei Guan. All rights reserved.
//
/// HINT: 这里的场景操作都应该比较快，直截了当的使用FMDatabaseQueue来解决多线程的问题是OK的；
/// 但对于某些耗时甚巨的操作（几秒甚至数十秒）,可以考虑单独make一个FMDatabase出来并放到单独的线程中去做:
/// (也可以在主线程尝试看看，在保证不会卡死页面的前提下对比耗时）。 用实践来检验一切！！！！！！

#import "FMDBConfig.h"
#import "FMDB.h"

@interface FMDBConfig ()
@property (nonatomic, strong) FMDatabase *db;
@property (nonatomic, strong) FMDatabaseQueue *dbQueue;

@property (nonatomic, strong) NSMutableDictionary *configs;
@property (nonatomic, strong) NSDictionary *defaults;
@end

@implementation FMDBConfig

#pragma - mark Singlton Method

+ (instancetype)sharedInstance
{
    static id globalConfig = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        globalConfig = [[self alloc] init];
    });
    
    return globalConfig;
}

// You may config default value here.
- (NSDictionary *)configDefaults
{
    return @{
             kPassword:@"666666",
             kTestConfig2:@"极致的菜就是川菜"
             };
}

#pragma - mark System methods

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _configs = [NSMutableDictionary dictionary];
        _defaults = [self configDefaults];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *path = [documentsDirectory stringByAppendingPathComponent:@"config.db"];
        
        // 1.创建数据库文件config.db（若不存在）。
        self.db = [FMDatabase databaseWithPath:path];
        [self.db open];
        
        BOOL isExist = [self.db tableExists:@"config"];
        if (!isExist)
        {
            // 2.创建config表。(若不存在)
            NSString *createTableSQL = @"create table config (id integer primary key autoincrement);";
            [self.db executeUpdate:createTableSQL];
        }
        
        /// 注意：这里的db只有一条记录；也可以改造成多条记录；
        /// 每条记录代表一个config, 数据库的字段是固定的，包括key/value及其他有必要添加的信息等。(YapDB是这么干的)
        /// TODO: 可以对这两种方法做性能测试（BenchMark），择其性能优者用之。
        
        // 3.插入唯一的一条记录。(若不存在)
        NSString *sqlQuery = @"select *from config where id = ?";
        FMResultSet *rs = [self.db executeQuery:sqlQuery, @(1)];
        BOOL isRecordExist = NO;
        while ([rs next])
        {
            isRecordExist = YES;
        }
        [rs close];
        
        if (!isRecordExist)
        {
            NSString *sql = @"insert into config (id) values(?) ";
            [self.db executeUpdate:sql, @(1)];
        }
        
        // 获取到所有的config名字
        FMResultSet *schema = [self.db getTableSchema:@"config"];
        while ([schema next])
        {
            NSString *column = [schema stringForColumn:@"name"];
            _configs[column] = [NSNumber numberWithBool:YES];
        }
        [schema close];
        
        _dbQueue = [FMDatabaseQueue databaseQueueWithPath:path];
    }
    
    return self;
}

- (BOOL)configWithKey:(NSString *)key value:(NSString *)value
{
    if ([key length] == 0 || value == nil)
    {
        // input invalid.
        return NO;
    }
    
    if (_configs[key] == nil)
    {
        // 该key不存在，需要先add.
        [self addKey:key];
        _configs[key] = [NSNumber numberWithBool:YES];
    }
    
    // 测试结果表明：update某个config的值不会影响其他的。 注意：这里的问号只能用来表达值，而不能是key。
    NSString *sql = [NSString stringWithFormat:@"UPDATE config SET %@ = ? where id = ?", key];
    
    __block BOOL result;
    [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        result = [db executeUpdate:sql, value, @(1)];
    }];
    return result;
}

- (NSString *)valueFromKey:(NSString *)key
{
    if (_configs[key] == nil)
    {
        if([_defaults[key] length] > 0)
        {
            // default
            return _defaults[key];
        }
        else
        {
            // 没有这个key,直接返回空字符串
            return @"";
        }
    }
    else
    {
        // 获取保存配置的该条记录。
        __block NSString *config = nil;
        [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
            FMResultSet *result = [db executeQuery:@"select * from config where id = 1"];
            while ([result next])
            {
                config = [result stringForColumn:key];
            }
            [result close];
        }];
        
        if ([config length] > 0)
        {
            return config;
        }
        else
        {
            if([_defaults[key] length] > 0)
            {
                // default
                return _defaults[key];
            }
            else
            {
                // 没有这个key,直接返回空字符串
                return @"";
            }
        }
    }
}

- (BOOL)flagFromKey:(NSString *)key
{
    return [self switchValue:[self valueFromKey:key]];
}

#pragma - mark inner methods
- (BOOL)switchValue:(NSString *)switchConfig
{
    if ([switchConfig isEqualToString:@"0"])
    {
        return NO;
    }
    
    if ([switchConfig isEqualToString:@"1"])
    {
        return YES;
    }
    
    return NO;
}

- (void)addKey:(NSString *)key
{
    NSString *sql = [NSString stringWithFormat:@"ALTER TABLE %@ ADD %@ TEXT",@"config", key];
    
    [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        BOOL result = [db executeUpdate:sql];
        if (result)
        {
            NSLog(@"add key success");
        }
        else
        {
            NSLog(@"add key failed");
        }
    }];
}

- (void)cleanAll
{
    NSString *deleteSql = @"delete from config";
    [self.db executeUpdate:deleteSql];
    
    [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        [db executeUpdate:deleteSql];
    }];
}

@end
