#
# Be sure to run `pod lib lint Zoetrope.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "Zoetrope"
  s.version          = "1.0.0"
  s.summary          = "Animated gif image view with support for varying frame lengths written in Swift."

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!  
  s.description      = <<-DESC
  Who doesn't love animated gifs. Zoetrope adds a UIImageView subclass that displays animated images with support for 
  varying frame lengths. Simple.
                       DESC

  s.homepage         = "https://github.com/JanGorman/Zoetrope"
  s.license          = 'MIT'
  s.author           = { "Jan Gorman" => "gorman.jan@gmail.com" }
  s.source           = { :git => "https://github.com/JanGorman/Zoetrope.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/JanGorman'

  s.platform     = :ios, '9.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'

  s.source_files = 'Pod/Classes/**/*.swift'
  s.frameworks = 'ImageIO', 'MobileCoreServices', 'CoreGraphics'
end
