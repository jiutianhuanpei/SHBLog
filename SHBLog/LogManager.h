//
//  LogManager.h
//  Test
//
//  Created by shenhongbang on 16/8/4.
//  Copyright © 2016年 中移(杭州)信息技术有限公司. All rights reserved.
//

/**
 *  设置：如果安装了 XcodeColors 插件，可以开启不同颜色日志，按如下配置
 *  Edit Scheme -> Run -> Environment Variables 
 *  添加 XcodeColors : YES
 *
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// 控制台打印级数
typedef NS_ENUM(NSInteger, SHBLogLevel) {
    SHBLogLevelAll = 1,
    SHBLogLevelInfo = 1 << 1,
    SHBLogLevelWarning = 1 << 2,
    SHBLogLevelError = 1 << 3,
};

// Log 的样式
typedef NS_ENUM(NSInteger, SHBLogType) {
    SHBLogTypeNormal,
    SHBLogTypeInfo,
    SHBLogTypeWarning,
    SHBLogTypeError,
};

void SHBLog(NSString *mat, ...);
void SHBInfoLog(NSString *mat, ...);
void SHBWarnLog(NSString *mat, ...);
void SHBErrorLog(NSString *mat, ...);



@interface LogManager : NSObject

+ (LogManager *)sharedInstance;

/**
 *  设置显示的级别
 */
+ (void)setLogLevel:(SHBLogLevel)level;

/**
 *  为不同的log添加颜色
 *
 *  @param color 颜色
 *  @param type  log的type
 */
+ (void)setColor:(UIColor *)color forType:(SHBLogType)type;

/**
 *  打印
 *
 *  @param type     log type
 *  @param aMessage 消息
 */
+ (void)logType:(SHBLogType)type message:(NSString *)aMessage;


/**
 *  当前log文件地址
 */
@property (nonatomic, readonly, copy) NSString *currentLogPath;

@end
