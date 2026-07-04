# Deployment Guide for Energy Dashboard

## AWS S3 Quick Reference

### Prerequisites
- AWS Account (free tier available)
- AWS CLI installed and configured
- Or AWS Console access

### Commands for Quick Deployment

```bash
# 1. Set your bucket name
$BUCKET_NAME = "energy-dashboard-yourusername"
$REGION = "us-east-1"

# 2. Create S3 bucket
aws s3 mb s3://$BUCKET_NAME --region $REGION

# 3. Enable static website hosting
aws s3 website s3://$BUCKET_NAME --index-document index.html

# 4. Add bucket policy for public access
aws s3api put-bucket-policy --bucket $BUCKET_NAME --policy file://policy.json

# 5. Upload files
aws s3 sync . s3://$BUCKET_NAME/ --exclude ".git*" --exclude "node_modules/*" --exclude ".env*"

# 6. Access your dashboard
# http://$BUCKET_NAME.s3-website-$REGION.amazonaws.com
```

### Bucket Policy (policy.json)

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::energy-dashboard-yourusername/*"
        }
    ]
}
```

### Cost Estimate
- **Storage**: ~$0.01-0.05/month (for this small website)
- **Data Transfer**: ~$0.085 per GB (usually free within AWS free tier for first 12 months)
- **Requests**: Minimal cost with S3 pricing

## GitHub Setup

### 1. Create GitHub Repository
- Go to github.com and create new repository
- Name: `energy-dashboard`
- Add description: "Energy Consumption Dashboard"
- Choose Public (for easy sharing)
- Do NOT initialize with README (we have one)

### 2. Push to GitHub

```bash
cd d:\energy-dahsboard

# Initialize git
git init

# Add all files
git add .

# Create commit
git commit -m "Initial commit: Add energy dashboard project"

# Add remote
git remote add origin https://github.com/yourusername/energy-dashboard.git

# Push to GitHub
git branch -M main
git push -u origin main
```

## Automated Deployment with GitHub Actions

Create `.github/workflows/deploy.yml` to auto-deploy to S3 on push:

```yaml
name: Deploy to S3

on:
  push:
    branches: [ main ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v2
    
    - name: Configure AWS credentials
      uses: aws-actions/configure-aws-credentials@v1
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: us-east-1
    
    - name: Sync to S3
      run: |
        aws s3 sync . s3://energy-dashboard-yourusername/ \
          --exclude ".git*" \
          --exclude "node_modules/*" \
          --exclude ".env*" \
          --delete
    
    - name: CloudFront Invalidation
      run: |
        aws cloudfront create-invalidation --distribution-id $DISTRIBUTION_ID --paths "/*"
      env:
        DISTRIBUTION_ID: ${{ secrets.CLOUDFRONT_DISTRIBUTION_ID }}
```

### Add GitHub Secrets
1. Go to Settings → Secrets and variables → Actions
2. Add:
   - `AWS_ACCESS_KEY_ID`: Your AWS access key
   - `AWS_SECRET_ACCESS_KEY`: Your AWS secret key
   - `CLOUDFRONT_DISTRIBUTION_ID`: (Optional, for CDN caching)

## Custom Domain Setup (Optional)

### Using AWS Route 53
1. Register or transfer domain to Route 53
2. Create S3 bucket with domain name
3. Create CNAME or A record pointing to S3 website endpoint

### Using CloudFront (Optional but Recommended)
1. Create CloudFront distribution
2. Set S3 bucket as origin
3. Use domain with CloudFront
4. Benefits: Global CDN, faster loading, better performance

## Troubleshooting

### S3 Access Denied
- Check bucket policy is set correctly
- Ensure "Block all public access" is unchecked
- Verify IAM user has S3 permissions

### Files Not Updating
- Clear browser cache
- Use CloudFront invalidation
- Check S3 object permissions are public

### GitHub Push Issues
- Check git remote: `git remote -v`
- Update git credentials if needed
- Ensure branch is `main`

## Maintenance

```bash
# Update dashboard after making changes
git add .
git commit -m "Update: Description of changes"
git push origin main

# This automatically deploys to S3 if GitHub Actions is set up
```

## Security Best Practices

1. ✅ Never commit `.env` files
2. ✅ Use AWS IAM users instead of root credentials
3. ✅ Enable S3 versioning for backup
4. ✅ Consider enabling HTTPS with CloudFront
5. ✅ Regularly review S3 access logs

Enjoy your energy dashboard! 📊⚡
