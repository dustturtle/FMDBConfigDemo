//
//  FMDBConfig.m
//  FMDBConfigDemo
//
//  Created by Zhenwei Guan on 2018/10/11.
//  Copyright © 2018 Zhenwei Guan. All rights reserved.
//

#import "FMDBConfig.h"
#import "FMDB.h"

@interface FMDBConfig ()
@property (nonatomic, strong) FMDatabase *db;

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
        
        // 3.插入唯一的一条记录。(若不存在)
        NSString *sqlQuery = @"select *from config where id = ?";
        FMResultSet *rs = [self.db executeQuery:sqlQuery, @(1)];
        BOOL isRecordExist = NO;
        while ([rs next])
        {
            isRecordExist = YES;
        }
        
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
    }
    
    return self;
}

// You may config default value here.
- (NSDictionary *)configDefaults
{
    return @{
             kPassword:@"666666",
             kTestConfig2:@"极致的菜就是川菜"
             };
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
    BOOL result = [self.db executeUpdate:sql, value, @(1)];
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
        FMResultSet *result =  [_db executeQuery:@"select * from config where id = 1"];
        NSString *config = nil;
        while ([result next])
        {
            config = [result stringForColumn:key];
        }
        
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
    BOOL result = [self.db executeUpdate:sql];
    if (result)
    {
        NSLog(@"add key success");
    }
    else
    {
        NSLog(@"add key failed");
    }
}

- (void)cleanAll
{
    NSString *deleteSql = @"delete from config";
    [self.db executeUpdate:deleteSql];
}

@end
