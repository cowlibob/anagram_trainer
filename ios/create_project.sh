#!/bin/bash
# Script to create Xcode project structure manually

PROJECT_DIR="/Users/james/Projects/anagram_trainer/AnagramTrainerIOS"
PROJECT_NAME="AnagramTrainer"

cd "$PROJECT_DIR"

# Create .xcodeproj structure
mkdir -p "${PROJECT_NAME}.xcodeproj/project.xcworkspace/xcshareddata"
mkdir -p "${PROJECT_NAME}.xcodeproj/xcuserdata/$USER.xcuserdatad/xcschemes"

# Minimal Contents.json for workspace
cat > "${PROJECT_NAME}.xcodeproj/project.xcworkspace/contents.xcworkspacedata" << 'WORKSPACE'
<?xml version="1.0" encoding="UTF-8"?>
<Workspace
   version = "1.0">
   <FileRef
      location = "self:">
   </FileRef>
</Workspace>
WORKSPACE

echo "Project structure created. Now need to generate project.pbxproj..."
echo "This requires Xcode or xcodegen."
