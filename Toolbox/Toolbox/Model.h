//
//  Model.h
//  Toolbox
//
//  Created by gener on 17/7/10.
//  Copyright © 2017年 Light. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <LKDBHelper/LKDBHelper.h>
#import <objc/runtime.h>

//BASE MODEL
@interface Model : NSObject

/**
 写入数据库

 @param data 数据集合
 */
+(void)saveToDbWith:(NSArray*)data;

/**
 根据查询条件查找
 
 @param query 查询条件
 @param order 排序项
 
 @return Array
 */
+(NSArray*)searchWith:(NSString*)query orderBy:(NSString*)order;


@end

//飞机信息
@interface AirplaneModel : Model
@property(nonatomic,copy)NSString * aipcCec;
@property(nonatomic,copy)NSString * aircraftNotes;
@property(nonatomic,copy)NSString * airplaneId;
@property(nonatomic,copy)NSString * airplaneLineNumber;
@property(nonatomic,copy)NSString * airplaneMajorModel;
@property(nonatomic,copy)NSString * airplaneMinorModel;
@property(nonatomic,copy)NSString * airplaneRegistry;
@property(nonatomic,copy)NSString * airplaneSerialNumber;
@property(nonatomic,copy)NSString * customerEffectivity;
@property(nonatomic,copy)NSString * operatorCd;
@property(nonatomic,copy)NSString * operatorName;
@property(nonatomic,copy)NSString * ownerCode;
@property(nonatomic,copy)NSString * tailNumber;
@end

//手册
@interface PublicationsModel : Model
@property(nonatomic,copy)NSString * attribute;
@property(nonatomic,copy)NSString * bookId;

@end






