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


//BASE MODEL
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


    -(NSArray*)searchWith:(NSString*)query
    {
        
        return [[DBTool default].helper search:[self class] where:query orderBy:nil offset:0 count:INT16_MAX];
        
    }
    
    
    +(NSArray*)searchWith:(NSString*)query
    {
        return [[[self alloc]init ] searchWith:query];
    }
    
    -(void)setModelWith:(NSDictionary *)dic
    {
    }
    
@end

#pragma mark - 飞机信息
@implementation AirplaneModel
    -(void)setModelWith:(NSDictionary*)dic{
        id obj = [self.helper searchSingle:[self class] where:[NSString stringWithFormat:@"airplaneId=%@",dic[@"airplaneId"]] orderBy:nil];
        if (obj) {
            NSLog(@"已存在飞机：%@",dic[@"airplaneId"]);
            return;
        }
        
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
        
        [self.helper insertToDB:self];
        NSLog(@"inser model");
    }

    
    -(instancetype)initWith:(NSDictionary*)dic{
        return self;
    }
    
@end








