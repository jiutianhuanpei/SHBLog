
Pod::Spec.new do |s|

  s.name         = "SHBLog"
  s.version      = "0.0.2"
  s.summary      = "根据 DDLog 而写的，大大精简了代码量"


  s.description  = <<-DESC
    需要和 Xcode 插件 XcodeColors 配合使用。

                   DESC

  s.homepage     = "http://jiutianhuanpei.github.io"


  s.license      = "MIT"
  # s.license      = { :type => "MIT", :file => "FILE_LICENSE" }

  s.author             = { "shenhongbang" => "shenhongbang@163.com" }


   s.platform     = :ios
  # s.platform     = :ios, "5.0"

  s.source       = { :git => "https://github.com/jiutianhuanpei/SHBLog.git", :tag => "#{s.version}" }


  s.source_files  = "SHBLogResource/*.{h,m}"
  #s.exclude_files = "Classes/Exclude"

  # s.public_header_files = "Classes/**/*.h"

  # s.resource  = "icon.png"
  # s.resources = "Resources/*.png"

  # s.preserve_paths = "FilesToSave", "MoreFilesToSave"


  # s.framework  = "SomeFramework"
   s.frameworks = "UIKit"

  # s.library   = "iconv"
  # s.libraries = "iconv", "xml2"


  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  If your library depends on compiler flags you can set them in the xcconfig hash
  #  where they will only apply to your library. If you depend on other Podspecs
  #  you can include multiple dependencies to ensure it works.

    s.requires_arc = true

  # s.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
  # s.dependency "JSONKit", "~> 1.4"

end
