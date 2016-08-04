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

![效果截图](http://upload-images.jianshu.io/upload_images/144854-7ac2a39fc67c9449.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
