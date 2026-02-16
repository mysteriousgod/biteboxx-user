#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

echo "----------------------------------------------------------------"
echo "  Starting Vercel Build Script for Flutter"
echo "----------------------------------------------------------------"

# 1. Install Flutter (if not already cached/installed)
if [ ! -d "flutter" ]; then
    echo "⬇️  Flutter not found. Cloning stable branch..."
    git clone https://github.com/flutter/flutter.git -b stable
else
    echo "✅  Flutter directory found."
fi

# Add Flutter to PATH
export PATH="$PATH:`pwd`/flutter/bin"

echo "Running flutter doctor..."
flutter doctor

# 2. Generate .env file from Vercel Environment Variables
echo "📝 Generating .env file from environment variables..."

# Clear existing .env if any
rm -f .env
touch .env

# Helper function to append variables
append_to_env() {
    local var_name=$1
    local var_value=${!1}
    
    # Check if variable is set (even if empty string provided as value)
    if [ -n "$var_value" ]; then
        echo "$var_name=$var_value" >> .env
        echo "   + Added $var_name"
    else
        echo "   ! Warning: $var_name is not set in Vercel Environment Variables"
    fi
}

# Append all required variables
# Firebase - Web
append_to_env "FIREBASE_WEB_API_KEY"
append_to_env "FIREBASE_WEB_APP_ID"
append_to_env "FIREBASE_WEB_MESSAGING_SENDER_ID"
append_to_env "FIREBASE_WEB_PROJECT_ID"
append_to_env "FIREBASE_WEB_AUTH_DOMAIN"
append_to_env "FIREBASE_WEB_STORAGE_BUCKET"
append_to_env "FIREBASE_WEB_MEASUREMENT_ID"

# Firebase - Android (If needed for cross-platform logic in code)
append_to_env "FIREBASE_ANDROID_API_KEY"
append_to_env "FIREBASE_ANDROID_APP_ID"
append_to_env "FIREBASE_ANDROID_MESSAGING_SENDER_ID"
append_to_env "FIREBASE_ANDROID_PROJECT_ID"
append_to_env "FIREBASE_ANDROID_STORAGE_BUCKET"

# Firebase - iOS
append_to_env "FIREBASE_IOS_API_KEY"
append_to_env "FIREBASE_IOS_APP_ID"
append_to_env "FIREBASE_IOS_MESSAGING_SENDER_ID"
append_to_env "FIREBASE_IOS_PROJECT_ID"
append_to_env "FIREBASE_IOS_STORAGE_BUCKET"
append_to_env "FIREBASE_IOS_ANDROID_CLIENT_ID"
append_to_env "FIREBASE_IOS_CLIENT_ID"
append_to_env "FIREBASE_IOS_BUNDLE_ID"

# App Constants
append_to_env "APP_NAME"
append_to_env "BASE_URL"
append_to_env "WEB_HOSTED_URL"
append_to_env "FACEBOOK_APP_ID"

echo "✅ .env file created successfully."

# 3. Build the Application
echo "🚀 Building Flutter Web App..."

echo "   > Enabling web support..."
flutter config --enable-web

echo "   > Getting packages..."
flutter pub get

echo "   > Building release bundle..."
# --no-tree-shake-icons is often safer for complex apps
flutter build web --release --no-tree-shake-icons --web-renderer html

# 4. Post-Build Setup for Vercel
echo "📝 Post-build: Ensuring .env file is accessible..."

# Copy .env to the root of the build output (build/web/.env)
cp .env build/web/.env
echo "   + Copied .env to build/web/.env"

# Also ensure it exists in assets directory if flutter uses that path
mkdir -p build/web/assets
cp .env build/web/assets/.env
echo "   + Copied .env to build/web/assets/.env"

echo "----------------------------------------------------------------"
echo "✅  Build Complete! Output directory: build/web"
echo "----------------------------------------------------------------"
