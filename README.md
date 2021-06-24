---
SHBLog
---



一、`SHBPrint` 方法不变，仅打印传入文本。

<br/>

二、新增日志等级

```
//日志等级
typedef NS_ENUM(NSUInteger, HBLogLevel) {
    HBLogLevel_Normal,
    HBLogLevel_Warning,
    HBLogLevel_Error,
    HBLogLevel_Fatal,
};
```
分别调用以下 API 可打印对应等级的日志：

```
void HBLog(NSString *mat, ...);
void HBWarnLog(NSString *mat, ...);
void HBErrorLog(NSString *mat, ...);
void HBFatal(NSString *mat, ...);
```

<br/>

三、新增日志输入等级

```
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
```

调用 `void HBSetOutputLevel(HBLogOutputLevel level)` 设置需要显示在控制台的日志等级，若不设置则默认为 `HBLogOutputLevel_All ` 打印所有日志，但不打印日志。


若需要输出日志到本地文件，需要增加打印等级 `HBLogOutputLevel_Writen `，同时通过 `void HBSetLogPath(NSString *logPath)` 设置日志路径。

	
<br/>

代码实现及效果如下：


<image src="https://github.com/jiutianhuanpei/SHBLog/raw/master/SHBLog/temp.png" width=805 height=412></image>


