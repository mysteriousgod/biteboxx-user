# StackFood Multivendor - Flutter Web App

A Flutter web application for food delivery services deployed on Vercel.

## Deployment to Vercel

### Prerequisites
- Flutter SDK installed
- Git repository set up

### Deployment Steps

1. **Prepare for Web Deployment**
   ```bash
   flutter config --enable-web
   ```

2. **Build the Web Application**
   ```bash
   flutter build web --release
   ```

3. **Deploy to Vercel**
   - Push your code to a Git repository
   - Go to [Vercel Dashboard](https://vercel.com/dashboard)
   - Click "Add New Project" and select your repository
   - Vercel will automatically detect the Flutter web project and use the configuration in `vercel.json`
   - The build command will be `flutter build web --release`
   - Output directory will be `build/web`

### Manual Deployment (CLI)
```bash
# Install Vercel CLI
npm install -g vercel

# Deploy
vercel
```

### Environment Variables
If you have environment variables in your `.env` file, add them in Vercel's project settings under Environment Variables.

### Custom Domain
After deployment, you can add a custom domain in Vercel's project settings.

## Local Development
```bash
flutter run -d chrome --web-port=3000
```

## Build for Production
```bash
flutter build web --release
```

## Features
- Responsive Flutter web application
- Food ordering and delivery management
- Multi-vendor support
- Real-time notifications
- Google Maps integration
- Firebase integration

## Technologies Used
- Flutter
- Firebase
- Google Maps API
- Vercel for hosting

## Configuration
The `vercel.json` file contains the deployment configuration:
- Builds the Flutter web app using `flutter build web --release`
- Serves static files from `build/web` directory
- Handles client-side routing for SPA applications