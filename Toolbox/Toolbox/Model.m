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

//tools
#pragma mark
@interface NSString (isNull)
+(NSString*)stringFromStr:(NSString*)str;
@end

@implementation NSString (isNull)

+(NSString*)stringFromStr:(NSString*)str{
    
    return str ? str : @"";
    
}

@end




//BASE MODEL
#pragma mark
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
        return NSStringFromClass(self);
    }

    //插入数据操作
    +(void)saveToDbWith:(NSArray*)data{
        NSLog(@"开始插入数据库...");
        dispatch_apply(data.count, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(size_t index) {
            [[[self alloc]init] setModelWith:data[index]];
        });
        
        NSLog(@"插入完成!");
    }

    -(instancetype)modelFromDic:(NSDictionary*)dic{
        
        unsigned int outCount = 0;
        id _m = [[[self class]alloc]init];
//        [_m setValuesForKeysWithDictionary:dic];//...与以下操作是相反方向
        
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

    -(void)setModelWith:(NSDictionary*)dic{
    }


    //search
    -(NSArray*)searchWith:(NSString*)query orderBy:(NSString*)order
    {
        
        return [[DBTool default].helper search:[self class] where:query orderBy:order offset:0 count:UINT16_MAX];
        
    }
    
    
    +(NSArray*)searchWith:(NSString*)query orderBy:(NSString*)order
    {
        return [[[self alloc]init ] searchWith:query orderBy:order];
    }
    

@end

#pragma mark - 飞机信息
@implementation AirplaneModel
  -(void)setModelWith:(NSDictionary*)dic{

        NSString * query = [NSString stringWithFormat:@"airplaneId='%@'",dic[@"airplaneId"]];
        id obj = [[DBTool default].helper searchSingle:[self class] where:query orderBy:nil];
        if (obj) {
            NSLog(@"已存在飞机：%@",dic[@"airplaneId"]);
            return;
        }
      
      /*
         self.aipcCec = dic[@"aipcCec"];
         self.aircraftNotes = dic[@"aircraftNotes"];
         self.airplaneId = dic[@"airplaneId"];
         self.airplaneLineNumber = dic[@"airplaneLineNumber"];
         self.airplaneMajorModel = dic[@"airplaneMajorModel"];
         self.airplaneMinorModel = dic[@"airplaneMinorModel"];
         self.airplaneRegistry = dic[@"airplaneRegistry"];
         self.airplaneSerialNumber = dic[@"airplaneSerialNumber"];
         self.customerEffectivity = dic[@"customerEffectivity"];
         self.operatorCd = dic[@"operatorCd"];
         self.operatorName = dic[@"operatorName"];
         self.ownerCode = dic[@"ownerCode"];
         self.tailNumber = dic[@"tailNumber"];
      */
         id _m  = [self modelFromDic:dic];
        [[DBTool default].helper insertToDB:_m];
    }



@end









