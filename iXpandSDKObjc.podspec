Pod::Spec.new do |s|
  s.name         = "iXpandSDKObjc"
  s.version      = "1.0.2"
  s.summary      = "iXpand Objc SDK for SANDISK IXPAND: https://developer.westerndigital.com/develop/sandisk/ixpand-sdk-home-main.html"
  s.homepage     = "https://github.com/leshkoapps/iXpandSDKObjc"
  s.license      = 'MIT'
  s.author       = { "Artem Meleshko" => "support@everappz.com" }
  s.source       = { :git => "https://github.com/leshkoapps/iXpandSDKObjc.git", :tag => s.version.to_s }
  s.ios.deployment_target = '9.0'
  s.source_files = 'SDK/*.{h,m}'
  s.requires_arc = true
  # s.vendored_framework = 'Frameworks/iXpandSDKlib.framework', 'Frameworks/iXpandSDKlibSim.framework'
  # s.vendored_framework = 'Frameworks/iXpandSDKlib.framework'
  s.preserve_paths = 'Frameworks/*.framework'
  # s.libraries        = 'c++', 'z', 'c'
  # s.compiler_flags = '-lc', '-lc++', '-lz'
  # s.ios.framework  = 'MobileCoreServices', 'ExternalAccessory', 'CoreFoundation', 'Foundation', 'SystemConfiguration', 'CFNetwork', 'Security'
  # s.xcconfig = {'OTHER_LDFLAGS[sdk=iphonesimulator*]' => '$(inherited) -framework "iXpandSDKlibSim"', 'OTHER_LDFLAGS[sdk=iphoneos*]' => '$(inherited) -framework "iXpandSDKlib"' }
  # s.pod_target_xcconfig = { 'VALID_ARCHS[sdk=iphonesimulator*]' => '' }

  other_frameworks_os =  ['iXpandSDKlib']
  other_frameworks_sim =  ['iXpandSDKlibSim']
  other_frameworks_common =  ['MobileCoreServices', 'ExternalAccessory', 'CoreFoundation', 'Foundation', 'SystemConfiguration', 'CFNetwork', 'Security']

  other_ldflags_os = '$(inherited) -framework ' + other_frameworks_common.join(' -framework ') + other_frameworks_os.join(' -framework ') +
    ' -lz -lstdc++ -lc'

  other_ldflags_sim = '$(inherited) -framework ' + other_frameworks.join(' -framework ') + other_frameworks_sim.join(' -framework ') +
    ' -lz -lstdc++ -lc'
  
  s.xcconfig     = { 
    'FRAMEWORK_SEARCH_PATHS' => '"$(PODS_ROOT)/iXpandSDKObjc/Frameworks"',

    'OTHER_LDFLAGS[arch=i386]'  => other_ldflags_sim,
    'OTHER_LDFLAGS[arch=x86_64]'  => other_ldflags_sim,

    'OTHER_LDFLAGS[arch=arm64]'  => other_ldflags_os,
    'OTHER_LDFLAGS[arch=arm64e]'  => other_ldflags_os,
    'OTHER_LDFLAGS[arch=armv7]'  => other_ldflags_os,
    'OTHER_LDFLAGS[arch=armv7s]' => other_ldflags_os
    
  }





end
