#
#  Be sure to run `pod spec lint RegexAttributer.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  These will help people to find your library, and whilst it
  #  can feel like a chore to fill in it's definitely to your advantage. The
  #  summary should be tweet-length, and the description more in depth.
  #

  spec.name         = "RegexAttributer"
  spec.version      = "1.0"
  spec.summary      = "A Lightweight library to manage Regex dependent attribute generation"

  spec.description  = <<-DESC
  A Cocoapod library that helps you to make Regex calculations and generating attributes for attributed strings more easier.
                   DESC

  spec.homepage     = "https://github.com/rajavijayakumar/RegexAttributer"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author             = { "Raja Vijaya Kumar" => "developer.rajanayagam@gmail.com" }

  # spec.platform     = :ios
  # spec.platform     = :ios, "5.0"

  #  When using multiple platforms
  spec.ios.deployment_target = "9.0"
  spec.osx.deployment_target = "10.9"
  spec.swift_version = "4.0"
  # spec.watchos.deployment_target = "2.0"
  # spec.tvos.deployment_target = "9.0"

  spec.source       = { :git => "https://github.com/rajavijayakumar/RegexAttributer.git", :tag => "#{spec.version}" }
  spec.source_files  = "RegexAttributer/**/*.{h,m,swift}"
  # spec.exclude_files = "RegexAttributer/Exclude"
  
  # spec.public_header_files = "Classes/**/*.h"

end
