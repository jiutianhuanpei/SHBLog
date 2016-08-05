---
SHBLog
---
* 可以打印选定级别的 Log，可以打印多个级别的 Log。

```
[LogManager setLogLevel:SHBLogLevelAll];
[LogManager setLogLevel:SHBLogLevelWarning | SHBLogLevelError]; 
```

* 也可以把 Log 写入本地文件（默认）。

```
NSLog(@"path:\n%@", [[LogManager sharedInstance] currentLogPath]);
```

* 如果 Xcode 安装了 XcodeColors 插件，可以配置日志显示颜色

```
[LogManager setColor:[UIColor redColor] forType:SHBLogTypeInfo];
[LogManager setColor:[UIColor purpleColor] forType:SHBLogTypeWarning];
```

<image src="https://github.com/jiutianhuanpei/SHBLog/raw/master/SHBLog/temp.png" width=805 height=412></image>


