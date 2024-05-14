#!/bin/bash

DASHARO_PATH=$1
PLATFORMS_OVERRIDE=$2

# Check for platform config files and build list of target platforms
platforms=()
for i in {2..7}; do
	if [ -f "$DASHARO_PATH/configs/config.pcengines_apu$i" ]; then
		platforms+=("apu$i")
	fi
done

# If platforms override is provided, use it instead
if [ -n "$PLATFORMS_OVERRIDE" ]; then
	IFS=',' read -r -a platforms <<<"$PLATFORMS_OVERRIDE"
fi

# Loop through each platform and build
for platform in "${platforms[@]}"; do
	echo "Starting build for $platform..."
	./build.sh dev-build "$DASHARO_PATH" "$platform"

	# Capture the exit code of the build process
	status_code=$?

	# Check if the build was successful
	if [ $status_code -ne 0 ]; then
		echo "Build failed for $platform with status code $status_code."
		exit $status_code
	fi
done

echo "All builds completed successfully."

find "$DASHARO_PATH/build" -type f -exec sha256sum {} + >/tmp/iter_hashes
cut -d" " -f1 /tmp/iter_hashes | sort | uniq >/tmp/iter_hash_only
comm -3 /tmp/iter_hash_only /tmp/v4.19.0.1_hash_only | wc -l
