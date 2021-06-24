//
//  SHBLog.h
//  SHBLog
//
//  Created by shenhongbang on 2016/11/26.
//  Copyright © 2016年 沈红榜. All rights reserved.
//

#import <Foundation/Foundation.h>

//日志等级
typedef NS_ENUM(NSUInteger, HBLogLevel) {
    HBLogLevel_Normal,
    HBLogLevel_Warning,
    HBLogLevel_Error,
    HBLogLevel_Fatal,
};

//日志输出等级
typedef NS_OPTIONS(NSUInteger, HBLogOutputLevel) {
    HBLogOutputLevel_Normal = 1 << 0,
    HBLogOutputLevel_Warning = 1 << 1,
    HBLogOutputLevel_Error = 1 << 2,
    HBLogOutputLevel_Fatal = 1 << 3,
    
    HBLogOutputLevel_All = (HBLogOutputLevel_Normal
                      | HBLogOutputLevel_Warning
                      | HBLogOutputLevel_Error
                      | HBLogOutputLevel_Fatal),
    
    //权用于标记日志是否需要输出到文件，需要设置日志路径
    HBLogOutputLevel_Writen = 1 << 20,
};

/**
 只有打印，无前缀
  */
void SHBPrint(NSString *mat, ...);


/// 设置日志输出级别
/// @param level 日志输出级别
void HBSetOutputLevel(HBLogOutputLevel level);

/// 设置日志存储路径
/// @param logPath 日志路径
void HBSetLogPath(NSString *logPath);

/**
 仿系统打印，以时间、进程id为前缀
 以下打印接受 HBSetOutputLevel()    HBSetLogPath()  函数设置
 */
void HBLog(NSString *mat, ...);
void HBWarnLog(NSString *mat, ...);
void HBErrorLog(NSString *mat, ...);
void HBFatal(NSString *mat, ...);

