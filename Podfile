
use_frameworks!

def utils
	pod 'BuildaUtils', '0.0.11'
	pod 'ReactiveCocoa', '4.0.2-alpha-1'
end

def dvr
	pod 'DVR', :git => "https://github.com/czechboy0/DVR.git", :tag => "v0.0.4-czechboy0" 
end

target 'XcodeServerSDK - OS X' do
	utils
end

target 'XcodeServerSDK - OS X Tests' do
	utils
	dvr
end

target 'XcodeServerSDK - iOS' do
	utils
end

target 'XcodeServerSDK - iOS Tests' do
	utils
	dvr
end

target 'XcodeServerSDK - watchOS' do
	utils
end
