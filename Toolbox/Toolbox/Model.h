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

@interface Model : NSObject

+(void)saveToDbWith:(NSArray*)data;

+(NSArray*)searchWith:(NSString*)query orderBy:(NSString*)order;
    
@end


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








