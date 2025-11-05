# Original Podspec
Pod::Spec.new do |s|
  s.name         = "iXpandSDKObjc"
  s.version      = "1.0.4"
  s.summary      = "iXpand Objc SDK for SANDISK IXPAND: https://developer.westerndigital.com/develop/sandisk/ixpand-sdk-home-main.html"
  s.homepage     = "https://github.com/leshkoapps/iXpandSDKObjc"
  s.license      = 'MIT'
  s.author       = { "Artem Meleshko" => "support@everappz.com" }
  s.source       = { :git => "https://github.com/leshkoapps/iXpandSDKObjc.git", :tag => s.version.to_s }
  s.ios.deployment_target = '9.0'
  s.source_files = 'SDK/*.{h,m}'
  s.requires_arc = true
  s.preserve_paths = 'Frameworks/*.framework'
  ixpand_framework_os =  'iXpandSDKlib'
  ixpand_framework_sim =  'iXpandSDKlibSim'
  other_frameworks_common =  ['MobileCoreServices', 'ExternalAccessory', 'CoreFoundation', 'Foundation', 'SystemConfiguration', 'CFNetwork', 'Security']
  other_ldflags_os = '$(inherited) -framework ' + other_frameworks_common.join(' -framework ') + ' -framework ' + ixpand_framework_os +
    ' -lz -lstdc++ -lc'
  other_ldflags_sim = '$(inherited) -framework ' + other_frameworks_common.join(' -framework ') + ' -framework ' + ixpand_framework_sim +
    ' -lz -lstdc++ -lc'
  s.xcconfig     = {
    'FRAMEWORK_SEARCH_PATHS' => '"$(PODS_ROOT)/iXpandSDKObjc/Frameworks"',
    'OTHER_LDFLAGS[sdk=iphonesimulator*]'  => other_ldflags_sim,
    'OTHER_LDFLAGS[sdk=iphoneos*]'  => other_ldflags_os
  }
end


# Pod::Spec.new do |s|
#   s.name         = "iXpandSDKObjc"
#   s.version      = "1.0.4"
#   s.summary      = "iXpand Objc SDK for SANDISK IXPAND: https://developer.westerndigital.com/develop/sandisk/ixpand-sdk-home-main.html"
#   s.homepage     = "https://github.com/leshkoapps/iXpandSDKObjc"
#   s.license      = 'MIT'
#   s.author       = { "Artem Meleshko" => "support@everappz.com" }
#   s.source       = { :git => "https://github.com/leshkoapps/iXpandSDKObjc.git", :tag => s.version.to_s }
#
#   s.ios.deployment_target = '9.0'
#   s.requires_arc = true
#   s.source_files = 'SDK/**/*.{h,m}'
#   s.preserve_paths = 'Frameworks/iXpandSDKlib.framework'
#   other_frameworks = %w[MobileCoreServices ExternalAccessory CoreFoundation Foundation SystemConfiguration CFNetwork Security]
#
#   # Per-SDK flags: link iXpand only on device; keep simulator clean.
#   s.pod_target_xcconfig = {
#     # Only search for vendored frameworks on device SDK
#     'FRAMEWORK_SEARCH_PATHS[sdk=iphoneos*]' => '"$(PODS_ROOT)/iXpandSDKObjc/Frameworks"',
#
#     # Device: link iXpand + Apple frameworks + z/c++
#     'OTHER_LDFLAGS[sdk=iphoneos*]' =>
#       '$(inherited) ' +
#       other_frameworks.map { |f| "-framework #{f}" }.join(' ') +
#       ' -framework iXpandSDKlib -lz -lstdc++ -lc',
#
#     # Simulator: DO NOT link iXpand at all (only system frameworks if you need them).
#     # You can even leave this empty to inherit the app’s defaults.
#     'OTHER_LDFLAGS[sdk=iphonesimulator*]' =>
#       '$(inherited) ' +
#       other_frameworks.map { |f| "-framework #{f}" }.join(' ') +
#       ' -lz -lstdc++ -lc',
#
#     # Provide a macro so your code can compile out iXpand calls on Simulator
#     'GCC_PREPROCESSOR_DEFINITIONS[sdk=iphonesimulator*]' =>
#       '$(inherited) IXPAND_DISABLED_SIM=1'
#   }
# end