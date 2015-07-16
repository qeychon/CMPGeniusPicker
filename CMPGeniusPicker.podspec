

Pod::Spec.new do |s|

  s.name         = "CMPGeniusPicker"
  s.version      = "0.1.1"
  s.summary      = "Fully configurable picker, which can be used as a time selection."
  s.homepage     = "https://github.com/qeychon/CMPGeniusPicker"
  s.screenshots  = "https://raw.githubusercontent.com/qeychon/CMPGeniusPicker/master/demo.gif"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "qeychon"  => "qeychon@compience.com" }
  s.platform     = :ios, "7.1"
  s.source       = { :git => "https://github.com/qeychon/CMPGeniusPicker.git", :tag => "0.1.1" }
  s.source_files  = "Classes", "CMPGeniusPicker/CMPGeniusPicker/Sources/**/*.{h,m}"
  s.requires_arc = true

end
