# Random Image Website

A simple static website that displays a random image on each page load.

## Structure

```
.
├── index.html          # Main HTML file with random image logic
└── images/             # Directory for your images
    ├── image1.jpg
    ├── image2.jpg
    ├── image3.jpg
    ├── image4.jpg
    └── image5.jpg
```

## Setup

1. Add your images to the `images/` directory (named image1.jpg, image2.jpg, etc.)
2. To add more images, update the `images` array in `index.html`

## Deploy to AWS S3

### 1. Create an S3 Bucket
```bash
aws s3 mb s3://your-bucket-name
```

### 2. Upload Files
```bash
aws s3 sync . s3://your-bucket-name --exclude ".git/*"
```

### 3. Enable Static Website Hosting
```bash
aws s3 website s3://your-bucket-name --index-document index.html
```

### 4. Make Bucket Public
Create a bucket policy (replace `your-bucket-name`):
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PublicReadGetObject",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::your-bucket-name/*"
    }
  ]
}
```

Apply the policy:
```bash
aws s3api put-bucket-policy --bucket your-bucket-name --policy file://policy.json
```

### 5. Access Your Website
Your website will be available at:
```
http://your-bucket-name.s3-website-[region].amazonaws.com
```

## Using the AWS Console

Alternatively, you can use the AWS Console:
1. Go to S3 in AWS Console
2. Create a new bucket
3. Upload `index.html` and the `images/` folder
4. Go to Properties > Static website hosting > Enable
5. Set `index.html` as the index document
6. Go to Permissions > Block public access > Turn off blocking
7. Add the bucket policy above
8. Access your site via the endpoint shown in Static website hosting

## How It Works

- Each time the page loads, JavaScript randomly selects one image from the array
- Click "Load Another Image" button to see a different random image
- All logic runs client-side, perfect for S3 static hosting
