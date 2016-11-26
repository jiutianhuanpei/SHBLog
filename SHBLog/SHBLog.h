//
//  SHBLog.h
//  SHBLog
//
//  Created by shenhongbang on 2016/11/26.
//  Copyright © 2016年 中移(杭州)信息技术有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 仿系统打印，以时间、进程id为前缀
 */
void SHBPrint(NSString *mat, ...);

/**
 只有打印，无前缀
 */
void SHBLog(NSString *mat, ...);


