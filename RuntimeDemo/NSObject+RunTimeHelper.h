//
//  NSObject+RunTimeHelper.h
//  LotterySteward
//
//  Created by apple on 15/10/16.
//  Copyright © 2015年 ytx. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSObject (RunTimeHelper)

/**
 *  获取该类成员变量列表
 *
 *  @return 该类成员变量列表
 */

+ (NSArray *)arrayOfIvars;

/**
 *  取得该类属性列表
 *
 *  @return 该类属性列表
 */
+ (NSArray *)arrayOfProperties;


/**
 *  取得该类实例方法列表
 *
 *  @return 该类实例方法列表
 */

+ (NSArray *)arrayOfInstanceMethods;

/**
 *  取得该类方法方法列表
 *
 *  @return 该类方法方法列表
 */
+ (NSArray *)arrayOfClassMethods;

/**
 *  取得该类遵循协议列表
 *
 *  @return 该类遵循协议列表
 */
+ (NSArray *)arrayOfProtocols;

/**
 *  取得该工程所有类的列表
 *
 *  @return 该工程所有类的列表
 */
+ (NSArray *)arrayOfAllClass;

/**
 *  取得该对象中有值的的property字典
 *
 *  @return 该对象中有值的的property字典
 */
- (NSDictionary *)dictionaryOfPropertyKeyValues;


/**
 *  利用关联添加属性
 */
@property (nonatomic, strong) NSString *featureIdentifier;


@end



