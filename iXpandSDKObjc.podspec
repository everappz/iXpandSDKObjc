Pod::Spec.new do |s|
  s.name         = "iXpandSDKObjc"
  s.version      = "1.0.7"
  s.summary      = "iXpand Objc SDK for SANDISK IXPAND"
  s.homepage     = "https://github.com/leshkoapps/iXpandSDKObjc"
  s.license      = 'MIT'
  s.author       = { "Artem Meleshko" => "support@everappz.com" }
  s.source       = { :git => "https://github.com/leshkoapps/iXpandSDKObjc.git", :tag => s.version.to_s }
  s.ios.deployment_target = '9.0'
  s.requires_arc = true

  s.preserve_paths = 'Frameworks/*.framework'

  # Framework is linked on device only — simulator gets nothing
  s.ios.vendored_frameworks = 'Frameworks/iXpandSDKlib.framework'

  other_frameworks = %w[MobileCoreServices ExternalAccessory CoreFoundation
                        Foundation SystemConfiguration CFNetwork Security]
  other_ldflags_base = other_frameworks.map { |f| "-framework #{f}" }.join(' ') +
                       ' -lz -lstdc++ -lc'

  s.pod_target_xcconfig = {
    # Search path only needed on device
    'FRAMEWORK_SEARCH_PATHS[sdk=iphoneos*]'               => '"$(PODS_ROOT)/iXpandSDKObjc/Frameworks"',

    # Device: link iXpand framework
    'OTHER_LDFLAGS[sdk=iphoneos*]'                        => "$(inherited) #{other_ldflags_base} -framework iXpandSDKlib",

    # Simulator: system frameworks only, NO iXpand
    'OTHER_LDFLAGS[sdk=iphonesimulator*]'                 => "$(inherited) #{other_ldflags_base}",

    # Macro so your ObjC/C++ code can #if out iXpand calls on simulator
    'GCC_PREPROCESSOR_DEFINITIONS[sdk=iphonesimulator*]'  => '$(inherited) IXPAND_DISABLED_SIM=1',
    'GCC_PREPROCESSOR_DEFINITIONS[sdk=iphoneos*]'         => '$(inherited)'
  }

  s.user_target_xcconfig = {
    'FRAMEWORK_SEARCH_PATHS[sdk=iphoneos*]' => '"$(PODS_ROOT)/iXpandSDKObjc/Frameworks"',
    'GCC_PREPROCESSOR_DEFINITIONS[sdk=iphonesimulator*]' => '$(inherited) IXPAND_DISABLED_SIM=1',
    'GCC_PREPROCESSOR_DEFINITIONS[sdk=iphoneos*]'        => '$(inherited)'
  }
end