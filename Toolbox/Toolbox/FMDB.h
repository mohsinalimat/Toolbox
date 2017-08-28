//
//  FMDB.h
//  Toolbox
//
//  Created by gener on 17/8/28.
//  Copyright © 2017年 Light. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FMDB/FMDB.h>

@interface FMDB : NSObject

+(instancetype)default;


-(void)insertWithArray:(NSArray*)arr;

- (void)insertWithDic:(NSDictionary *)dic;

@end
