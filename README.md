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

<image src="http://oa7jjah9m.bkt.clouddn.com/QQ20160805-0@2x.png" width=536 height=274></image>


![QQ20160805-0@2x.png](http://oa7jjah9m.bkt.clouddn.com/QQ20160805-0@2x.png)
