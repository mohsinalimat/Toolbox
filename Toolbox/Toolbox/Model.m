//
//  Model.m
//  Toolbox
//
//  Created by gener on 17/7/10.
//  Copyright © 2017年 Light. All rights reserved.
//

#import "Model.h"

@interface  DBTool: NSObject

@property(nonatomic,retain)LKDBHelper * helper;

@end

@implementation DBTool

    - (instancetype)init
    {
        self = [super init];
        if (self) {
            NSString *libraypath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES)lastObject];
            NSString * path = [libraypath stringByAppendingPathComponent:@"Database/ToolBox.db"];
            _helper = [[LKDBHelper alloc]initWithDBPath:path];
        }
        return self;
    }




+(instancetype)default
    {
        static DBTool * sigleton = nil;
        static dispatch_once_t dispatchonce;
        dispatch_once(&dispatchonce, ^{
            sigleton = [[DBTool alloc]init];
        });
        
        return sigleton;
    }

@end

#pragma mark
@interface NSString (isNull)

+(NSString*)stringFromStr:(NSString*)str;

@end

@implementation NSString (isNull)

+(NSString*)stringFromStr:(NSString*)str{
    
    return str ? str : @"";
    
}

@end


#pragma mark - BASE MODEL
@implementation Model

    -(instancetype)init
    {
        self = [super init];
        if (self) {
        }
        
        return self;
    }

    +(LKDBHelper *)getUsingLKDBHelper
    {
        return [DBTool default].helper;
    }

    //返回数据表名称
    + (NSString *)getTableName{
        return [[NSStringFromClass(self) stringByReplacingOccurrencesOfString:@"Model" withString:@""] uppercaseString];
    }

    //返回表主键
    -(NSString *)getPrimarykey{
        //子类必须重载
        return @"";
    }

    //写入数据操作
    +(void)saveToDbWith:(id)data{
        if ([data isKindOfClass:[NSArray class]]) {
            NSArray * arr = (NSArray*)data;
            if (arr.count < 1) {
                return;
            }
            dispatch_apply(arr.count, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(size_t index) {
                [[[self alloc]init] saveModelWith:arr[index]];
            });
        }
        else if ([data isKindOfClass:[NSDictionary class]]){
            [[[self alloc]init] saveModelWith:data];
        }
        //NSLog(@"插入完成%lu条数据!",(unsigned long)([data isKindOfClass:[NSArray class]]?((NSArray*)data).count:1));
    }

    +(void)saveToDbNotCheckWith:(id)data{
        if ([data isKindOfClass:[NSDictionary class]]){
            [[[self alloc]init] saveModelNotCheck:data];
        }
    }

    -(instancetype)modelWith:(NSDictionary*)dic{
        unsigned int outCount = 0;
        id _m = [[[self class]alloc]init];
        //[_m setValuesForKeysWithDictionary:dic];//...与以下操作是相反方向
        objc_property_t *list = class_copyPropertyList([self class], &outCount);
        for (int i =0; i < outCount; i++) {
            objc_property_t property = list[i];
            const char * charname = property_getName(property);
            NSString * name = [[NSString alloc]initWithUTF8String:charname];
            [_m setValue:[NSString stringFromStr:dic[name]] forKey:name];
        }
        
        free(list);
        return _m;
    }


     -(void)saveModelWith:(NSDictionary*)dic{
         NSString * query = [NSString stringWithFormat:@"%@='%@'",[self getPrimarykey],dic[[self getPrimarykey]]];
         id obj = [[DBTool default].helper searchSingle:[self class] where:query orderBy:nil];
         if (obj) {
             NSLog(@"已存在：%@",dic[[self getPrimarykey]]);
             return;
         }
         
         [self saveModelNotCheck:dic];
    }

    -(void)saveModelNotCheck:(NSDictionary*)dic{
        id _m  = [self modelWith:dic];
        [[DBTool default].helper insertToDB:_m];
    }

    #pragma mark - 查找删除
    -(NSArray*)searchWith:(NSString*)query orderBy:(NSString*)order
    {
        
        return [[DBTool default].helper search:[self class] where:query orderBy:order offset:0 count:UINT16_MAX];
        
    }

    +(NSArray*)searchWith:(NSString*)query orderBy:(NSString*)order
    {
        return [[[self alloc]init ] searchWith:query orderBy:order];
    }

    -(NSArray*)searchWithSql:(NSString*)sql{
        
            return [[DBTool default].helper search:[self class] withSQL:[NSString stringWithFormat:@"%@",sql]];
    }

    +(NSArray*)searchWithSql:(NSString*)sql{
        return [[[self alloc]init] searchWithSql:sql];
    }

    -(BOOL)deleteWith:(NSString*)query{
        
        return [[DBTool default].helper deleteWithClass:[self class] where:query];
    }

    +(BOOL)deleteWith:(NSString*)query{
        
        return [[[self alloc]init] deleteWith:query];
    }


@end

#pragma mark
@implementation AirplaneModel

-(NSString *)getPrimarykey{
    return @"airplaneId";
}
@end

@implementation PublicationsModel

-(NSString *)getPrimarykey{
    return @"book_uuid";
}
@end

@implementation SegmentModel

-(NSString *)getPrimarykey{
    return @"primary_id";
}
@end


///
@implementation BookmarkModel

-(NSString *)getPrimarykey{
    return @"seg_primary_id";
}

@end


@implementation APMMap

-(NSString *)getPrimarykey
{
    return @"primary_id";
}

@end
#pragma mark - other

@implementation UpdateInfo

-(NSString *)getPrimarykey
{
    return @"table_name";
}

@end


@implementation MsgRecord

-(NSString *)getPrimarykey{
    return @"path";
}

@end




