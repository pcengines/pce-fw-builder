#!/bin/bash

DASHARO_PATH=$1
PLATFORMS_OVERRIDE=$2

# Check for platform config files and build list of target platforms
platforms=()
for i in {2..7}; do
	if [ -f "$DASHARO_PATH/configs/config.pcengines_seabios_apu$i" ]; then
		platforms+=("seabios_apu$i")
	fi
done

# If platforms override is provided, use it instead
if [ -n "$PLATFORMS_OVERRIDE" ]; then
	IFS=',' read -r -a platforms <<<"$PLATFORMS_OVERRIDE"
fi

# Loop through each platform and build
for platform in "${platforms[@]}"; do
	echo "Starting build for $platform..."
	./build.sh dev-build "$DASHARO_PATH" "seabios_$platform"

	# Capture the exit code of the build process
	status_code=$?

	# Check if the build was successful
	if [ $status_code -ne 0 ]; then
		echo "Build failed for $platform with status code $status_code."
		exit $status_code
	fi
	mv $DASHARO_PATH/build/coreboot.rom seabios_${platform}.rom
	sha256sum seabios_${platform}.rom >seabios_${platform}.sha256sum
done

echo "All builds completed successfully."
cat *.sha256sum
