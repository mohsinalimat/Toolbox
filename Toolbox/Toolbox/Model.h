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

 @param data 数据集合（数组或字典）
 */
+(void)saveToDbWith:(id)data;

//直接插入，不检测是否存在
+(void)saveToDbNotCheckWith:(id)data;

/**
 根据查询条件查找
 
 @param query 查询条件
 @param order 排序项
 
 @return Array
 */
+(NSArray*)searchWith:(NSString*)query
              orderBy:(NSString*)order;


+(NSArray*)searchWithSql:(NSString*)sql;

+(BOOL)deleteWith:(NSString*)query;//删除表中数据

+(BOOL)isExistTable;//表是否存在

/**
 创建实例

 @param dic key-value

 @return 实例对象
 */
-(instancetype)modelWith:(NSDictionary*)dic;


/*私有方法，必须由子类重载.外部调用无意义。*/
-(NSString *)getPrimarykey;

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
@property(nonatomic,copy)NSString * airplaneSerialNumber;//MSN
@property(nonatomic,copy)NSString * customerEffectivity;//有效性-过滤手册内容
@property(nonatomic,copy)NSString * operatorCd;
@property(nonatomic,copy)NSString * operatorName;
@property(nonatomic,copy)NSString * ownerCode;
@property(nonatomic,copy)NSString * tailNumber;
@property(nonatomic,copy)NSString * customer_code;
@property(nonatomic,copy)NSString * customer_name;
@end

//手册BOOK
@interface PublicationsModel : Model
@property(nonatomic,copy)NSString * book_uuid;
@property(nonatomic,copy)NSString * cage_code;
@property(nonatomic,copy)NSString * customer_code;
@property(nonatomic,copy)NSString * customer_name;
@property(nonatomic,copy)NSString * display_title;
@property(nonatomic,copy)NSString * dm_version;
@property(nonatomic,copy)NSString * doc_abbreviation;
@property(nonatomic,copy)NSString * doc_class;
@property(nonatomic,copy)NSString * doc_number;
@property(nonatomic,copy)NSString * document_disclaimer;
@property(nonatomic,copy)NSString * document_owner;
@property(nonatomic,copy)NSString * eff_markup_type;
@property(nonatomic,copy)NSString * external_url;
@property(nonatomic,copy)NSString * fls_download;
@property(nonatomic,copy)NSString * forceLoad;
@property(nonatomic,copy)NSString * format;
@property(nonatomic,copy)NSString * model;
@property(nonatomic,copy)NSString * model_major;
@property(nonatomic,copy)NSString * model_minor;
@property(nonatomic,copy)NSString * oem_type;
@property(nonatomic,copy)NSString * publication_id;
@property(nonatomic,copy)NSString * publish_date;
@property(nonatomic,copy)NSString * reader_min_version;
@property(nonatomic,copy)NSString * rev_type;
@property(nonatomic,copy)NSString * revision_date;
@property(nonatomic,copy)NSString * revision_number;
@property(nonatomic,copy)NSString * source;
@property(nonatomic,copy)NSString * system;
@property(nonatomic,copy)NSString * tocType;
@property(nonatomic,copy)NSString * type;
@property(nonatomic,copy)NSString * useApModelMap;
@property(nonatomic,copy)NSString * booklocalurl;
@property(nonatomic,copy)NSString * metadataurl;

@end

//目录
@interface SegmentModel : Model
@property(nonatomic,copy)NSString *  primary_id;//主键ID - book_id + id
@property(nonatomic,copy)NSString *  parent_id;//目录项-父ID
@property(nonatomic,copy)NSString *  toc_id;//目录项-ID
@property(nonatomic,copy)NSString *  book_id;
@property(nonatomic,copy)NSString *  content_location;
@property(nonatomic,copy)NSString *  has_content;
@property(nonatomic,copy)NSString *  is_leaf;
@property(nonatomic,copy)NSString *  is_visible;
@property(nonatomic,copy)NSString *  mime_type;
@property(nonatomic,copy)NSString *  original_tag;
@property(nonatomic,copy)NSString *  revision_type;
@property(nonatomic,copy)NSString *  toc_code;
@property(nonatomic,copy)NSString *  title;
@property(nonatomic,copy)NSString *  effrg;//有效性，判断文档是否适用当前飞机(CEC关联),eg"101,114 203,211 451550三位分割"
@property(nonatomic,copy)NSString *  tocdisplayeff;//有效性显示的内容
@property(nonatomic,assign)NSInteger nodeLevel;//节点层级
@end

///
@interface BookmarkModel : Model
@property(nonatomic,copy)NSString * seg_primary_id;//KEY
@property(nonatomic,copy)NSString * seg_original_tag;
@property(nonatomic,copy)NSString * seg_toc_code;
@property(nonatomic,copy)NSString * seg_title;
@property(nonatomic,copy)NSString * seg_content_location;
@property(nonatomic,copy)NSString * seg_parents;

@property(nonatomic,copy)NSString * pub_book_uuid;
@property(nonatomic,copy)NSString * pub_booklocalurl;
@property(nonatomic,copy)NSString * pub_doc_abbreviation;
@property(nonatomic,copy)NSString * pub_document_owner;
@property(nonatomic,copy)NSString * pub_model;

@property(nonatomic,copy)NSString * airplaneId;
@property(nonatomic,copy)NSString * mark_content;//备注

@property(nonatomic,assign)NSInteger data_type;//RESERVE...
@end

//MSN - BOOKS映射(一个飞机可对应多个手册，所以删除手册时飞机的删除要慎重)
@interface APMMap : Model
@property(nonatomic,copy)NSString * primary_id;
@property(nonatomic,copy)NSString * bookid;
@property(nonatomic,copy)NSString * msn;
@end

@interface DataSourceModel : Model
@property(nonatomic,copy)NSString * location_url;
@property(nonatomic,copy)NSString * package_info;
@property(nonatomic,copy)NSString * sync_manifest;
@property(nonatomic,copy)NSString * server_baseline;
@property(nonatomic,assign)NSInteger  update_status;//当前数据源更新状态
@property(nonatomic,copy)NSString * misc;
@property(nonatomic,copy)NSString * time;

@property(nonatomic,assign)float ds_file_percent;//下载、解压进度
@property(nonatomic,assign)NSInteger total_files;//总文件数
@property(nonatomic,assign)NSInteger current_files;//已处理文件数
@end

@interface PublicationVersionModel : Model
@property (nonatomic, copy)NSString * book_uuid;
@property (nonatomic, copy)NSString * display_model;
@property (nonatomic, copy)NSString * display_title;
@property (nonatomic, copy)NSString * dm_version;
@property (nonatomic, copy)NSString * doc_abbreviation;
@property (nonatomic, copy)NSString * doc_number;
@property (nonatomic, copy)NSString * document_owner;
@property (nonatomic, copy)NSString * file_loc;
@property (nonatomic, copy)NSString * file_size;
@property (nonatomic, copy)NSString * fls_download;
@property (nonatomic, copy)NSString * forceLoad;
@property (nonatomic, copy)NSString * last_modified_datetime;
@property (nonatomic, copy)NSString * model_major;
@property (nonatomic, copy)NSString * order_datetime;
@property (nonatomic, copy)NSString * publication_id;
@property (nonatomic, copy)NSString * revision_date;
@property (nonatomic, copy)NSString * revision_number;
@property (nonatomic, copy)NSString * threshold;
@property (nonatomic, copy)NSString * threshold_unit;
@property (nonatomic, copy)NSString * data_source;
@end


@interface InstallLaterModel : Model
@property (nonatomic, copy)NSString * book_uuid;
@property (nonatomic, copy)NSString * display_model;
@property (nonatomic, copy)NSString * display_title;
@property (nonatomic, copy)NSString * dm_version;
@property (nonatomic, copy)NSString * doc_abbreviation;
@property (nonatomic, copy)NSString * doc_number;
@property (nonatomic, copy)NSString * document_owner;
@property (nonatomic, copy)NSString * file_loc;
@property (nonatomic, copy)NSString * last_modified_datetime;
@property (nonatomic, copy)NSString * model_major;
@property (nonatomic, copy)NSString * order_datetime;
@property (nonatomic, copy)NSString * publication_id;
@property (nonatomic, copy)NSString * revision_date;
@property (nonatomic, copy)NSString * revision_number;
@property (nonatomic, copy)NSString * data_source;
@property(nonatomic,copy)NSString * mark_valid_data; //修改生效日期

@end




#pragma mark - other
//表更新记录
@interface UpdateInfo : Model
@property(nonatomic,copy)NSString * table_name;
@property(nonatomic,assign)NSInteger update_time;
@property(nonatomic,copy)NSString *  ID;
@end

@interface MsgRecord : Model
@property(nonatomic,copy)NSString * path;

@end

