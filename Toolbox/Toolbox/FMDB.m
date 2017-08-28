//
//  FMDB.m
//  Toolbox
//
//  Created by gener on 17/8/28.
//  Copyright © 2017年 Light. All rights reserved.
//

#import "FMDB.h"

@implementation FMDB
{
    FMDatabase * _db;
}

+(instancetype)default{
    static FMDB * _singleton =  nil;
    static dispatch_once_t once;
    
    dispatch_once(&once, ^{
        _singleton = [[[self class] alloc ]init];
    });
    
    return _singleton;
}


-(instancetype)init{
    self = [super init];
    if (self) {
        NSString *path = [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingString:@"/Database"];
        NSString *filePath = [path stringByAppendingPathComponent:@"ToolBox.db"];

        _db = [FMDatabase databaseWithPath:filePath];
       
        if ([_db open]) {
            // 初始化数据表
            NSString *personSql = @"CREATE TABLE IF NOT EXISTS 'SEGMENT' ('rowid' INTEGER PRIMARY KEY AUTOINCREMENT  NOT NULL ,'primary_id' VARCHAR(255),'parent_id' VARCHAR(255),'toc_id' VARCHAR(255),'book_id' VARCHAR(255),'content_location' VARCHAR(255),'has_content' VARCHAR(2),'is_leaf' VARCHAR(5),'is_visible' VARCHAR(5),'mime_type' VARCHAR(10),'original_tag' VARCHAR(255),'revision_type' VARCHAR(255),'toc_code' VARCHAR(255),'title' VARCHAR(255),'effrg' VARCHAR(255),'tocdisplayeff' VARCHAR(255),'nodeLevel' VARCHAR(2)) ";
            
           BOOL b = [_db executeUpdate:personSql];
            if (b) {
                NSLog(@"create table success!");
            }else{
                NSLog(@"create table error!:%@",_db.lastError.localizedDescription);
            }
        }else{
            NSLog(@"open database fail!");
        }

        [_db close];

    }
    
    return self;
}

- (void)insertWithDic:(NSDictionary *)dic{
    [_db open];

    [_db executeUpdate:@"INSERT INTO SEGMENT(primary_id,parent_id,toc_id,book_id,content_location,has_content,is_leaf,is_visible,mime_type,original_tag,revision_type,toc_code,title,effrg,tocdisplayeff,nodeLevel)VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",dic[@"primary_id"],dic[@"parent_id"],dic[@"toc_id"],dic[@"book_id"],dic[@"content_location"],dic[@"has_content"],dic[@"is_leaf"],dic[@"is_visible"],dic[@"mime_type"],dic[@"original_tag"],dic[@"revision_type"],dic[@"toc_code"],dic[@"title"],dic[@"effrg"],dic[@"tocdisplayeff"],dic[@"nodeLevel"]];
    
    
    
    [_db close];
    
}

-(void)insertWithArray:(NSArray*)arr{

    NSDate * start = [NSDate date];
    
    [_db open];
    [_db beginTransaction];
    
    @try {
        for (NSDictionary * dic in arr) {
            [_db executeUpdate:@"INSERT INTO SEGMENT(primary_id,parent_id,toc_id,book_id,content_location,has_content,is_leaf,is_visible,mime_type,original_tag,revision_type,toc_code,title,effrg,tocdisplayeff,nodeLevel)VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",dic[@"primary_id"],dic[@"parent_id"],dic[@"toc_id"],dic[@"book_id"],dic[@"content_location"],dic[@"has_content"],dic[@"is_leaf"],dic[@"is_visible"],dic[@"mime_type"],dic[@"original_tag"],dic[@"revision_type"],dic[@"toc_code"],dic[@"title"],dic[@"effrg"],dic[@"tocdisplayeff"],dic[@"nodeLevel"]];
        }
       
        NSDate *endTime = [NSDate date];
        NSTimeInterval a = [endTime timeIntervalSince1970] - [start timeIntervalSince1970];
        NSLog(@"使用事务插入%ld条数据用时%.3f秒",arr.count,a);
        
    } @catch (NSException *exception) {
        NSLog(@"%@", exception.reason);
        [_db rollback];
    } @finally {
        [_db commit];
    }
    
    [_db close];
}



@end
