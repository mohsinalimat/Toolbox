//
//  Model.m
//  Toolbox
//
//  Created by gener on 17/7/10.
//  Copyright © 2017年 Light. All rights reserved.
//

#import "Model.h"
#define ToolboxDBName @"Toolbox"

@interface  DBTool: NSObject
@property(nonatomic,retain)LKDBHelper * helper;
@end
@implementation DBTool

    - (instancetype)init
    {
        self = [super init];
        if (self) {
            _helper = [[LKDBHelper alloc]initWithDBName:ToolboxDBName];
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

//
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
        NSLog(@"开始插入数据库...");
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
        NSLog(@"插入完成!");
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
         
         id _m  = [self modelWith:dic];
         [[DBTool default].helper insertToDB:_m];
    }


    #pragma mark -
    //search
    -(NSArray*)searchWith:(NSString*)query orderBy:(NSString*)order
    {
        
        return [[DBTool default].helper search:[self class] where:query orderBy:order offset:0 count:UINT16_MAX];
        
    }
    

    //查找
    +(NSArray*)searchWith:(NSString*)query orderBy:(NSString*)order
    {
        return [[[self alloc]init ] searchWith:query orderBy:order];
    }
    

@end

#pragma mark
@implementation AirplaneModel

-(NSString *)getPrimarykey{
    //子类必须重载
    return @"airplaneId";
}

@end

@implementation PublicationsModel
-(NSString *)getPrimarykey{
    //子类必须重载
    return @"book_uuid";
}

@end


#pragma mark - other

@implementation UpdateInfo

-(NSString *)getPrimarykey
{
    return @"table_name";
}

@end







