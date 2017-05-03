
Pod::Spec.new do |s|

  s.name         = "YXPopupHandleView"
  s.version      = "1.0.1"
  s.summary      = "alert,actionSheet,notice effect of YXPopupHandleView"
  s.homepage     = "https://github.com/liuyongxin/YXPopupHandleView"
  s.license      = { :type => "MIT", :file => "LICENSE" }

  s.author             = { "Louis_liu" => "717811709@qq.com" }
  #s.platform     = :ios
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/liuyongxin/YXPopupHandleView.git", :tag => s.version }

  s.source_files  = "PopupView/*.{h,m}"

  # s.public_header_files = "Classes/**/*.h"


  # ――― Resources ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  A list of resources included with the Pod. These are copied into the
  #  target bundle with a build phase script. Anything else will be cleaned.
  #  You can preserve files from being cleaned, please don't preserve
  #  non-essential files like tests, examples and documentation.
  #

  # s.resource  = "icon.png"
  # s.resources = "Resources/*.png"

  # s.preserve_paths = "FilesToSave", "MoreFilesToSave"


  # ――― Project Linking ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Link your library with frameworks, or libraries. Libraries do not include
  #  the lib prefix of their name.
  #

  # s.framework  = "SomeFramework"
  # s.frameworks = "SomeFramework", "AnotherFramework"

  # s.library   = "iconv"
  # s.libraries = "iconv", "xml2"


  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  If your library depends on compiler flags you can set them in the xcconfig hash
  #  where they will only apply to your library. If you depend on other Podspecs
  #  you can include multiple dependencies to ensure it works.

  # s.requires_arc = true

  # s.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
  # s.dependency "JSONKit", "~> 1.4"

end
