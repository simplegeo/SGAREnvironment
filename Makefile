default: release

# Create a Universal binary (iOS + Simulator)
release:
	xcodebuild -target SimpleGeoAR -configuration Release -sdk iphoneos4.2 build
	xcodebuild -target SimpleGeoAR -configuration Release -sdk iphonesimulator4.2 build
	-lipo -create build/Release-iphoneos/SimpleGeoAR.framework/SimpleGeoAR build/Release-iphonesimulator/SimpleGeoAR.framework/SimpleGeoAR -output build/Release-iphoneos/SimpleGeoAR.framework/SimpleGeoAR

dist: release
	cd build/Release-iphoneos/ && tar zcf ../../SimpleGeoAR.tgz SimpleGeoAR.framework/

clean:
	-rm -rf build
