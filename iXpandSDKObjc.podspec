Pod::Spec.new do |s|
  s.name         = "iXpandSDKObjc"
  s.version      = "1.0.9"
  s.summary      = "iXpand Objc SDK for SANDISK IXPAND: https://developer.westerndigital.com/develop/sandisk/ixpand-sdk-home-main.html"
  s.homepage     = "https://github.com/leshkoapps/iXpandSDKObjc"
  s.license      = 'MIT'
  s.author       = { "Artem Meleshko" => "support@everappz.com" }
  s.source       = { :git => "https://github.com/leshkoapps/iXpandSDKObjc.git", :tag => s.version.to_s }
  s.ios.deployment_target = '9.0'
  s.source_files = 'SDK/*.{h,m}'
  s.requires_arc = true
  s.preserve_paths = 'Frameworks/*.framework'
  ixpand_framework_os  = 'iXpandSDKlib'
  ixpand_framework_sim = 'iXpandSDKlibSim'
  other_frameworks_common = ['MobileCoreServices', 'ExternalAccessory', 'CoreFoundation', 'Foundation', 'SystemConfiguration', 'CFNetwork', 'Security']
  # -ObjC forces the linker to load ALL Obj-C classes/categories from the
  # static iXpandSDKlib(Sim) framework into THIS pod's dynamic framework, so
  # consumers resolve every class from the embedded framework (no missing
  # symbols) without linking the static lib themselves.
  other_ldflags_os  = '$(inherited) -ObjC -framework ' + other_frameworks_common.join(' -framework ') + ' -framework ' + ixpand_framework_os  + ' -lz -lstdc++ -lc'
  other_ldflags_sim = '$(inherited) -ObjC -framework ' + other_frameworks_common.join(' -framework ') + ' -framework ' + ixpand_framework_sim + ' -lz -lstdc++ -lc'
  # pod_target_xcconfig (NOT xcconfig): apply the static-lib link flags ONLY to
  # this pod's own target. Using `xcconfig` propagated them to consumer/app
  # targets too, which statically linked iXpandSDKlib a SECOND time and caused
  # "Class ... is implemented in both iXpandSDKObjc.framework and <app>" runtime
  # duplicate-class warnings.
  s.pod_target_xcconfig = {
    'FRAMEWORK_SEARCH_PATHS'                      => '"$(PODS_ROOT)/iXpandSDKObjc/Frameworks"',
    'OTHER_LDFLAGS[sdk=iphonesimulator*]'         => other_ldflags_sim,
    'OTHER_LDFLAGS[sdk=iphoneos*]'                => other_ldflags_os
  }
end