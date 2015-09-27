
use_frameworks!

def utils
	pod 'BuildaUtils', '0.1.0'
end

def tests
	pod 'DVR', :git => "https://github.com/czechboy0/DVR.git", :tag => "v0.0.5-czechboy0"
end

target 'XcodeServerSDK - OS X' do
	utils
end

target 'XcodeServerSDK - OS X Tests' do
	utils
	tests
end

target 'XcodeServerSDK - iOS' do
	utils
end

target 'XcodeServerSDK - iOS Tests' do
	utils
	tests
end

target 'XcodeServerSDK - watchOS' do
	utils
end
