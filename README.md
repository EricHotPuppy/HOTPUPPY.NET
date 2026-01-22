# Random Image Website

A simple static website that displays a random image on each page load.

Live at: **https://hotpuppy.net**

## Structure

```
.
├── index.html          # Main HTML file with random image logic
├── deploy.sh           # Automated deployment script
└── images/             # Directory for your images
    ├── image1.jpg
    ├── image2.jpg
    ├── image3.jpg
    └── image4.jpg
```

## Quick Start: Adding New Images

1. Drop your new images (any name) into the `images/` directory
2. Set AWS credentials:
   ```bash
   export AWS_ACCESS_KEY_ID="your-key"
   export AWS_SECRET_ACCESS_KEY="your-secret"
   export AWS_DEFAULT_REGION="us-west-2"
   ```
3. Run the deployment script:
   ```bash
   ./deploy.sh
   ```

The script will automatically:
- Rename new images to image5.jpg, image6.jpg, etc.
- Update index.html with the new image list
- Upload everything to S3
- Invalidate CloudFront cache
- Your site will be updated in minutes!

## Current Infrastructure

- **S3 Bucket**: `hotpuppy-net-s3-bucket` (us-west-2)
- **CloudFront Distribution**: `E3TTPPBYO03MM7`
- **Domain**: hotpuppy.net (via Route 53)
- **SSL Certificate**: AWS Certificate Manager
- **HTTPS**: Enabled (HTTP redirects to HTTPS)

## Manual Deployment

If you prefer to deploy manually without the script:

```bash
# Upload files to S3
aws s3 sync . s3://hotpuppy-net-s3-bucket \
    --exclude ".git/*" \
    --exclude "README.md" \
    --exclude "images/README.md" \
    --exclude "deploy.sh"

# Invalidate CloudFront cache (for immediate updates)
aws cloudfront create-invalidation \
    --distribution-id E3TTPPBYO03MM7 \
    --paths "/*"
```

## How It Works

- Each time the page loads, JavaScript randomly selects one image from the array
- All logic runs client-side, perfect for S3 static hosting
- CloudFront CDN provides fast global delivery and HTTPS
