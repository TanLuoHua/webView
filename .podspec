Pod::Spec.new do |s|
  s.name     = ‘webView’
  s.version  = ‘1.0.0’
  s.license  = ‘ZUIYE’
  s.summary  = '下载ZIP，解压后加载webView，JS交互'
  s.homepage = 'https://github.com/yhl714387953/webView'
  s.authors  = { 'Sohayb Hassoun' => 'sohayb.hassoun@gmail.com' }
  s.source   = { :git => 'https://github.com/yhl714387953/webView.git', :tag => '2.0.4' }
  s.source_files = 'webView'
  s.requires_arc = true
  s.ios.deployment_target = ‘7.0’
  s.osx.deployment_target = '10.8'

  s.dependency 'AFNetworking', '~> 2.6.2'
  s.dependency 'UnzipKit', '~> 1.6'

end