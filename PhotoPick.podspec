Pod::Spec.new do |s|
  s.name             = "PhotoPick"
  s.version          = "1.1.1"
  s.summary          = "Instagram-like photo browser"
  s.homepage         = "https://github.com/carloscorreia94/PhotoPick"
  s.license          = 'MIT'
  s.author           = { "carloscorreia94" => "pm.correia.carlos@gmail.com" }
  s.source           = { :git => "https://github.com/carloscorreia94/PhotoPick.git", :tag => s.version.to_s }
  s.platform     = :ios, '9.0'
  s.requires_arc = true
  s.source_files = 'Sources/**/*.swift'
  s.resources    = ['Sources/Assets.xcassets', 'Sources/**/*.xib']
end
