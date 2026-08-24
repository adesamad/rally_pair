Pod::Spec.new do |s|
  s.name             = 'cv_rally_pair_log'
  s.version          = '0.1.0'
  s.summary          = 'Encrypted local diagnostic logs for Rally Pair.'
  s.description      = 'Stores authenticated encrypted diagnostic logs in an app-owned folder.'
  s.homepage         = 'https://example.invalid/cv_rally_pair_log'
  s.license          = { :type => 'Proprietary', :text => 'Internal use only.' }
  s.author           = { 'rally_pair' => 'dev@example.invalid' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '13.0'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'
end
