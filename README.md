---
SHBLog
---


　　Xcode8 之后不再支持插件，所以也不再支持 XcodeColors 插件显示不同的颜色。
　　<br>
　　剔除保存log日志功能，保持本库的纯粹性。同时代码也精简为两个api，如下：
　　

* `SHBLog` 的打印效果仿系统 `NSLog` 的效果。
* `SHBPrint` 则是其精简版，仅打印内容，不以时间、进程id为前缀。

代码实现及效果如下：


<image src="https://github.com/jiutianhuanpei/SHBLog/raw/master/SHBLog/temp.png" width=805 height=412></image>


