# Vercel Deployment Fix Guide

## Issues Identified

Based on the screenshot and code analysis, the following issues were preventing images and Google Maps from loading in production:

### 1. **Google Maps Not Loading**
- The Google Maps API key needs to be injected during build time
- Environment variable was incorrectly named in `.env` file
- Vercel environment variables were not configured

### 2. **Images Not Loading**
- The code was trying to load images through a non-existent backend proxy: `${baseUrl}/image-proxy?url=...`
- This proxy endpoint doesn't exist on the backend at `https://biteboxx.com`
- **Solution:** Removed the proxy requirement and load images directly

## Fixes Applied

### ✅ Fixed Files (Already Done)

1. **`.env`** - Renamed `YOUR_GOOGLE_MAPS_API_KEY` to `GOOGLE_MAPS_API_KEY`
2. **`web/index.html`** - Changed hardcoded API key to placeholder `YOUR_GOOGLE_MAPS_API_KEY`
3. **`vercel-build.sh`** - Added `GOOGLE_MAPS_API_KEY` to environment variables list
4. **`vercel.json`** - Added proper routing for assets (images, fonts, icons, etc.)
5. **`lib/common/widgets/custom_image_widget.dart`** - Removed image proxy requirement, now loads images directly

## Required Actions in Vercel Dashboard

### Step 1: Add Environment Variables

Go to your Vercel project settings → Environment Variables and add the following:

```
GOOGLE_MAPS_API_KEY=AIzaSyAubvGlINRYKLseOvU0KZBrF49WpeZ16BA
APP_NAME=BiteBoxx
BASE_URL=https://biteboxx.com
WEB_HOSTED_URL=https://biteboxx-user.vercel.app
FACEBOOK_APP_ID=452131619626499

# Firebase Web
FIREBASE_WEB_API_KEY=AIzaSyBrHF7qZasZfKix7exO1jMqXspGc8tVnZc
FIREBASE_WEB_APP_ID=1:651863605412:web:ed34e7c41d10960e682631
FIREBASE_WEB_MESSAGING_SENDER_ID=651863605412
FIREBASE_WEB_PROJECT_ID=biteboxx-dc20d
FIREBASE_WEB_AUTH_DOMAIN=biteboxx-dc20d.firebaseapp.com
FIREBASE_WEB_STORAGE_BUCKET=biteboxx-dc20d.firebasestorage.app
FIREBASE_WEB_MEASUREMENT_ID=G-2WRJLDNYJ7

# Firebase Android (for cross-platform logic)
FIREBASE_ANDROID_API_KEY=AIzaSyCNUTuR4L1SVVaT6vy9Z6lW3gm3V63iO6k
FIREBASE_ANDROID_APP_ID=1:651863605412:android:3cf54a39e823ef7b682631
FIREBASE_ANDROID_MESSAGING_SENDER_ID=651863605412
FIREBASE_ANDROID_PROJECT_ID=biteboxx-dc20d
FIREBASE_ANDROID_STORAGE_BUCKET=biteboxx-dc20d.firebasestorage.app

# Firebase iOS
FIREBASE_IOS_API_KEY=AIzaSyBpyH2qnwdW0h-p-tbTuXD2IAaaObzrSQw
FIREBASE_IOS_APP_ID=1:651863605412:ios:ed542932b3449da5682631
FIREBASE_IOS_MESSAGING_SENDER_ID=651863605412
FIREBASE_IOS_PROJECT_ID=biteboxx-dc20d
FIREBASE_IOS_STORAGE_BUCKET=biteboxx-dc20d.firebasestorage.app
FIREBASE_IOS_ANDROID_CLIENT_ID=651863605412-53j2b4ehb0l5kqf8n5gttr50dhcjmu9q.apps.googleusercontent.com
FIREBASE_IOS_CLIENT_ID=651863605412-isgics249n4024snpsqe3eknt5kelv9g.apps.googleusercontent.com
FIREBASE_IOS_BUNDLE_ID=com.bitbox.user
```

**Important:** Make sure to set these for **Production**, **Preview**, and **Development** environments.

### Step 2: Deploy to Vercel

After adding the environment variables:

1. **Commit and push** the changes made to:
   - `.env`
   - `web/index.html`
   - `vercel-build.sh`
   - `vercel.json`
   - `lib/common/widgets/custom_image_widget.dart`

2. **Trigger a new deployment** in Vercel (it should auto-deploy on push)

3. **Wait for build to complete** (check build logs for any errors)

## Verification Steps

After deployment, verify:

1. **Google Maps Loads:**
   - Open browser console on https://biteboxx-user.vercel.app/
   - Check for Google Maps API errors
   - Map should be visible when selecting location

2. **Images Load:**
   - Check Network tab in browser DevTools
   - Look for image requests
   - Verify images are returning 200 status codes (not 404)

3. **No Console Errors:**
   - Open browser console
   - Should not see 404 errors for assets
   - Should not see CORS errors (unless the image source itself has CORS restrictions)

## Troubleshooting

### If Google Maps Still Not Loading:

1. Check Vercel build logs for the line: `🗺️  Injecting Google Maps API Key...`
2. Verify the API key is correctly set in Vercel environment variables
3. Check if the API key has the correct APIs enabled in Google Cloud Console:
   - Maps JavaScript API
   - Maps SDK for Android (if using mobile)
   - Geocoding API
   - Places API

### If Images Still Not Loading:

1. **Check if images have CORS issues:**
   - Open browser console and look for CORS errors
   - If images are from external sources, they need proper CORS headers

2. **Check backend is accessible:**
   ```bash
   curl https://biteboxx.com/api/v1/config
   ```

3. **Verify image URLs are correct:**
   - Check the Network tab to see what URLs are being requested
   - Make sure the BASE_URL environment variable is correct

### If Assets (fonts, icons) Not Loading:

1. Check the `vercel.json` routes are correctly configured
2. Verify the build output in `build/web` contains the assets
3. Check Vercel deployment logs for any asset-related errors

## Quick Deploy Commands

```bash
# Commit the changes
git add .
git commit -m "Fix: Google Maps and image loading in production"

# Push to trigger Vercel deployment
git push origin main
```

## Expected Build Output

In Vercel build logs, you should see:

```
🗺️  Injecting Google Maps API Key...
   + Replaced YOUR_GOOGLE_MAPS_API_KEY with actual key
✅  Build Complete! Output directory: build/web
```

If you see:
```
⚠️  GOOGLE_MAPS_API_KEY not found in environment variables. Maps might not load.
```

Then the environment variable is not set correctly in Vercel.
