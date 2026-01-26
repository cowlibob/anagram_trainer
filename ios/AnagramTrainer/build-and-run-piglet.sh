#!/bin/bash

# Build and run AnagramTrainer on Piglet device
# Usage: ./build-and-run-piglet.sh

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Device info
DEVICE_NAME="Piglet"
DEVICE_ID="00008101-000849E61A78001E"

# Project info
SCHEME="AnagramTrainer"
BUNDLE_ID="uk.co.cowlibob.lettershift"
PROJECT_DIR="/Users/james/Projects/anagram_trainer/ios/AnagramTrainer"
BUILD_DIR="${PROJECT_DIR}/build"

echo -e "${GREEN}🔨 Building AnagramTrainer for ${DEVICE_NAME}...${NC}"

cd "$PROJECT_DIR"

# Clean build folder (optional, comment out if you want faster builds)
# echo -e "${YELLOW}Cleaning build folder...${NC}"
# xcodebuild clean -scheme "$SCHEME"

# Build, install, and launch - this replicates Xcode's "Build and Run"
echo -e "${YELLOW}Building and installing on device...${NC}"

# First, find the app bundle path after building
APP_PATH="${BUILD_DIR}/Build/Products/Debug-iphoneos/AnagramTrainer.app"

# Build the app
xcodebuild \
    -scheme "$SCHEME" \
    -destination "id=${DEVICE_ID}" \
    -configuration Debug \
    -derivedDataPath "$BUILD_DIR" \
    build

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Build failed${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Build successful!${NC}"

# Install the app (this will kill any running instance and install fresh)
echo -e "${GREEN}📱 Installing on ${DEVICE_NAME}...${NC}"
xcrun devicectl device install app --device "${DEVICE_ID}" "${APP_PATH}"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ App installed!${NC}"

    # Small delay to ensure installation completes
    sleep 1

    # Launch the app
    echo -e "${GREEN}🚀 Launching app on ${DEVICE_NAME}...${NC}"
    xcrun devicectl device process launch --device "${DEVICE_ID}" "${BUNDLE_ID}" 2>&1 | grep -v "^$"

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ App launched successfully!${NC}"
    else
        echo -e "${YELLOW}⚠️  App installed but failed to launch automatically${NC}"
        echo -e "${YELLOW}💡 Please open the app manually on the device${NC}"
    fi
else
    echo -e "${RED}❌ Installation failed${NC}"
    exit 1
fi
