//
//  ViewController.m
//  FMDBConfigDemo
//
//  Created by Zhenwei Guan on 2018/10/10.
//  Copyright © 2018 Zhenwei Guan. All rights reserved.
//

#import "ViewController.h"
#import "FMDB.h"
#import "FMDBConfig.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *keyTF;

@property (weak, nonatomic) IBOutlet UILabel *allConfigs;


@property (strong, nonatomic) FMDatabase *db;

@end

@implementation ViewController


//    NSString *sql = @"create table config (id integer primary key autoincrement, x text);"
//    "create table bulktest2 (id integer primary key autoincrement, y text);"
//    "create table bulktest3 (id integer primary key autoincrement, z text);"
//    "insert into bulktest1 (x) values ('XXX');"
//    "insert into bulktest2 (y) values ('YYY');"
//    "insert into bulktest3 (z) values ('ZZZ');";

//    NSString *createTableSQL2 = @"create table configTest (id integer primary key autoincrement);";
//    [self.db executeUpdate:createTableSQL2];

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [FMDBConfig sharedInstance];
    
    
    NSString *password = [[FMDBConfig sharedInstance] valueFromKey:kPassword];
    NSString *userName = [[FMDBConfig sharedInstance] valueFromKey:kUserName];
    
    NSString *test = [[FMDBConfig sharedInstance] valueFromKey:kTestConfig2];
    
    // Do any additional setup after loading the view, typically from a nib.
    
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentsDirectory = [paths objectAtIndex:0];
//    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"config.db"];
//    // 1.创建数据库文件config.db（若不存在）。
//    self.db = [FMDatabase databaseWithPath:path];
    
//    [self.db open];
//
//    BOOL isExist = [self.db tableExists:@"config"];
//
//    if (!isExist)
//    {
//        // 2.创建config表。(若不存在)
//        NSString *createTableSQL = @"create table config (id integer primary key autoincrement, config1 text);";
//        [self.db executeUpdate:createTableSQL];
//    }
    
//    // 3.插入唯一的一条记录。(若不存在)
//    NSString *sql = @"insert into config (id,config1,cxy) values(?,?,?) ";
//
//    BOOL res = [self.db executeUpdate:sql, @(10),@"xxxxxYou111",@"cxyTest"];
//    // 测试结果表明，当id存在情况下的重复插入不能成功；应该可以update.
//
//    NSString *sqlQuery = @"select *from config where id = ?";
//    FMResultSet *rs = [self.db executeQuery:sqlQuery, @(10)];
//    while ([rs next])
//    {
//        NSLog(@"12 exists!");
//        int userId = [rs intForColumn:@"id"];
//    }
//
//    FMResultSet *schema = [self.db getTableSchema:@"config"]; //configTest config
//    NSMutableString *str = [NSMutableString string];
//    while ([schema next])
//    {
//        NSString *column = [schema stringForColumn:@"name"];
//        [str appendString:column];
//        [str appendString:@" "];
//    }
//    self.allConfigs.text = [str copy];
}

- (IBAction)doMagic:(id)sender
{
//    FMResultSet *schema = [self.db getTableSchema:@"config"];
//    //getTableSchema
//    NSMutableArray *columns = [NSMutableArray array];
//
//    while ([schema next]) {
//        //retrieve values for each record
//
//        NSString *column = [schema stringForColumn:@"name"];
//        [columns addObject:column];
//        NSLog(@"111");
////        NSString *str = [schema stringForColumnIndex:0];
////        NSString *str1 = [schema stringForColumnIndex:1];
//    }
//
//    NSLog(@"done");
    
    [[FMDBConfig sharedInstance] configWithKey:kUserName value:@"gzw"];
    [[FMDBConfig sharedInstance] configWithKey:kPassword value:@"123456"];
    
    
//    FMResultSet *result =  [_db executeQuery:@"select * from config where id = 1"];        // 从结果集里面往下找
//    while ([result next]) {
//        NSString *configStr = [result stringForColumn:@"config1"];
//        NSString *cxyStr = [result stringForColumn:@"cxy"];
//        int idValue = [result intForColumn:@"id"];
//        NSLog(@"config1:%@", configStr);
//        NSLog(@"record id:%@", @(idValue));
//        NSLog(@"cxy:%@", cxyStr);
//    }
}

- (IBAction)addKey:(id)sender
{
    NSString *key = self.keyTF.text;
    if ([key length] > 0)
    {
        NSString *sql = [NSString stringWithFormat:@"ALTER TABLE %@ ADD %@ INTEGER",@"config", key];
        BOOL result = [self.db executeUpdate:sql];
        if (result)
        {
            NSLog(@"插入字段成功");
        }
        else
        {
            NSLog(@"插入字段失败");
        }
    }
    
    FMResultSet *schema = [self.db getTableSchema:@"config"];
    NSMutableString *str = [NSMutableString string];
    while ([schema next])
    {
        NSString *column = [schema stringForColumn:@"name"];
        [str appendString:column];
        [str appendString:@" "];
    }
    self.allConfigs.text = [str copy];
}

- (IBAction)config1Set:(id)sender
{
    [GFMDBConfig cleanAll];
    
//    NSString *sql = @"insert into config (id,config1,cxy) values(?,?,?) ";
//    BOOL res = [self.db executeUpdate:sql, @(10),@"xxxxxYou111",@"cxyTest"];

    // 结果表明：update某个config的值不会影响其他的。 注意：这里的问号只能用来表达值，而不能是key。
//    NSString *sql = @"UPDATE config SET config1 = ? WHERE id = ?";
//    BOOL res = [self.db executeUpdate:sql, @"suzhiwanjia", @"9"];
//    if (!res) {
//        NSLog(@"error to UPDATE data");
//    } else {
//        NSLog(@"success to UPDATE data");
//        [self queryData];
//    }
//    [db close];

    
}



@end
