Pod::Spec.new do |s|
  s.name             = "Zoetrope"
  s.version          = "4.0.0"
  s.summary          = "Animated gif image view with support for varying frame lengths written in Swift."

  s.description      = <<-DESC
  Who doesn't love animated gifs. Zoetrope adds a UIImageView extension that displays animated images with support for 
  varying frame lengths. Simple.
                       DESC

  s.homepage         = "https://github.com/JanGorman/Zoetrope"
  s.license          = 'MIT'
  s.author           = { "Jan Gorman" => "gorman.jan@gmail.com" }
  s.source           = { :git => "https://github.com/JanGorman/Zoetrope.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/JanGorman'

  s.ios.deployment_target = '8.0'
  s.swift_version = '4.2'

  s.source_files = 'Zoetrope/**/*.swift'
  s.frameworks = 'ImageIO', 'MobileCoreServices', 'CoreGraphics'
end
