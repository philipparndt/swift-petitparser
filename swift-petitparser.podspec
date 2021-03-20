#
#  Be sure to run `pod spec lint swift-petitparser.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|
  spec.swift_version = '5.0'
  spec.name         = "swift-petitparser"
  spec.version      = "1.2.1"
  spec.summary      = "PetitParser for Swift - Parser combinator using fluent API"
  spec.description  = <<-DESC
  Parser combinator using fluent API written completely in Swift. This library is available for other languages as well.
                   DESC
  spec.homepage     = "https://github.com/philipparndt/swift-petitparser"
  # spec.screenshots  = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author       = { "Philipp Arndt" => "2f.mail@gmx.de" }

  #  When using multiple platforms
  spec.ios.deployment_target = "13.0"
  spec.osx.deployment_target = "10.15"
  spec.watchos.deployment_target = "6.0"
  spec.tvos.deployment_target = "13.0"
  spec.source       = { :git => "https://github.com/philipparndt/swift-petitparser.git", :tag => "#{spec.version}" }
  spec.source_files  = "src/swift-petitparser/**/*.swift"
end
