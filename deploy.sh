#!/bin/bash

# HOTPUPPY.NET Deployment Script
# Renames new images, updates index.html, and deploys to S3

set -e

# Configuration
IMAGES_DIR="images"
S3_BUCKET="hotpuppy-net-s3-bucket"
CLOUDFRONT_ID="E3TTPPBYO03MM7"

echo "🔍 Scanning for images..."

# Find all existing numbered images
existing_images=($(ls ${IMAGES_DIR}/image*.jpg 2>/dev/null | sort -V || true))
next_number=${#existing_images[@]}
next_number=$((next_number + 1))

# Find any images that aren't properly named
unnumbered_images=($(find ${IMAGES_DIR} -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) ! -name "image*.jpg" 2>/dev/null || true))

# Rename unnumbered images
if [ ${#unnumbered_images[@]} -gt 0 ]; then
    echo "📝 Found ${#unnumbered_images[@]} new image(s) to rename..."
    for img in "${unnumbered_images[@]}"; do
        extension="${img##*.}"
        new_name="${IMAGES_DIR}/image${next_number}.jpg"

        # If it's not a jpg, convert the name to jpg (you may want to actually convert the file)
        if [ "$extension" != "jpg" ]; then
            echo "   Warning: ${img} is not a .jpg file, renaming anyway to ${new_name}"
        fi

        echo "   Renaming: $(basename $img) → $(basename $new_name)"
        git mv "$img" "$new_name" 2>/dev/null || mv "$img" "$new_name"
        next_number=$((next_number + 1))
    done
else
    echo "✅ No new images to rename"
fi

# Count total images
total_images=($(ls ${IMAGES_DIR}/image*.jpg 2>/dev/null | sort -V || true))
image_count=${#total_images[@]}

echo "📊 Total images: ${image_count}"

# Update index.html with the image list
echo "📝 Updating index.html..."

# Generate the images array
images_array="        const images = ["
for i in $(seq 1 $image_count); do
    if [ $i -lt $image_count ]; then
        images_array="${images_array}\n            'images/image${i}.jpg',"
    else
        images_array="${images_array}\n            'images/image${i}.jpg'"
    fi
done
images_array="${images_array}\n        ];"

# Create a temporary file with the updated content
awk -v arr="$images_array" '
/^[ \t]*const images = \[/,/^[ \t]*\];/ {
    if (/^[ \t]*const images = \[/) {
        print arr
        skip=1
    }
    if (/^[ \t]*\];/ && skip==1) {
        skip=0
        next
    }
    if (skip==1) next
}
!skip {print}
' index.html > index.html.tmp && mv index.html.tmp index.html

echo "✅ Updated index.html with ${image_count} images"

# Check if AWS credentials are set
if [ -z "$AWS_ACCESS_KEY_ID" ]; then
    echo "❌ AWS credentials not set. Please set AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY environment variables."
    exit 1
fi

# Upload to S3
echo "☁️  Uploading to S3..."
aws s3 sync . s3://${S3_BUCKET} \
    --exclude ".git/*" \
    --exclude "README.md" \
    --exclude "images/README.md" \
    --exclude "deploy.sh" \
    --exclude ".gitignore"

echo "🔄 Invalidating CloudFront cache..."
aws cloudfront create-invalidation \
    --distribution-id ${CLOUDFRONT_ID} \
    --paths "/*" > /dev/null

echo ""
echo "✨ Deployment complete!"
echo "🌐 Your site will be updated at https://hotpuppy.net in a few minutes"
echo ""
echo "📋 Summary:"
echo "   - Images in bucket: ${image_count}"
echo "   - S3 Bucket: ${S3_BUCKET}"
echo "   - CloudFront: ${CLOUDFRONT_ID}"
