
use_frameworks!

def utils
	pod 'BuildaUtils', '~> 0.3.2'
end

def tests
	pod 'DVR', :git => "https://github.com/czechboy0/DVR.git", :tag => "v0.0.5-czechboy0"
#	pod 'Nimble', '~> 3.1.0'
    pod 'Nimble', :git => "https://github.com/Quick/Nimble.git", :commit => "b9256b0bdecc4ef1f659b7663dcd3aab6f43fb5f"
end

target 'XcodeServerSDK' do
	utils
end

target 'XcodeServerSDKTests' do
	utils
	tests
end
