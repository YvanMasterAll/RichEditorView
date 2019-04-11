Pod::Spec.new do |s|
  s.name             = "RichEditorView"
  s.version          = "6.0.2"
  s.summary          = "Rich Text Editor for iOS written in Swift"
  s.homepage         = "https://github.com/YvanMasterAll/RichEditorView"
  s.license          = 'BSD 3-clause'
  s.author           = { "YvanMasterAll" => "1136838669@qq.com" }
  s.source           = { :git => "https://github.com/YvanMasterAll/RichEditorView.git", :tag => s.version.to_s }

  s.platform     = :ios, '8.0'
  s.swift_version = '4.0'
  s.requires_arc = true

  s.source_files = 'RichEditorView/Classes/*'
  s.resources = [
      'RichEditorView/Assets/icons/*',
      'RichEditorView/Assets/editor/*'
  ]
end
