# Energy Consumption Dashboard

A beginner-friendly web application to monitor and analyze energy consumption with beautiful visualizations and real-time statistics.

## Features

- 📊 **Real-time Statistics**: View today's usage, monthly total, average daily consumption, and estimated costs
- 📈 **Interactive Charts**: Line chart for daily trends and bar chart for monthly overview
- 📋 **Detailed Logs**: Historical data table with consumption levels and cost tracking
- 💡 **Energy Saving Tips**: Practical tips to reduce energy consumption
- 📱 **Responsive Design**: Works seamlessly on desktop, tablet, and mobile devices
- 🎨 **Modern UI**: Clean, intuitive interface with smooth animations

## Technologies Used

- **HTML5**: Semantic markup and structure
- **CSS3**: Modern styling with Flexbox and Grid layout
- **JavaScript (Vanilla)**: Interactive functionality
- **Chart.js**: Beautiful data visualizations
- **No Framework Dependencies**: Pure vanilla JavaScript

## Project Structure

```
energy-dashboard/
├── index.html           # Main HTML file
├── css/
│   └── style.css        # Styling
├── js/
│   └── app.js           # Application logic
├── data/
│   └── energy-data.json # Sample data
├── .gitignore           # Git ignore file
├── README.md            # This file
└── package.json         # Project metadata
```

## Getting Started

### Prerequisites

- A modern web browser (Chrome, Firefox, Safari, Edge)
- Git installed on your machine
- AWS account for S3 deployment

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/energy-dashboard.git
   cd energy-dashboard
   ```

2. **Open the dashboard**
   - Option A: Double-click `index.html` in your file explorer
   - Option B: Use a local server
     ```bash
     # Using Python 3
     python -m http.server 8000
     
     # Using Python 2
     python -m SimpleHTTPServer 8000
     
     # Using Node.js (if installed)
     npx http-server
     ```
   - Open your browser and navigate to `http://localhost:8000`

## Usage

- **View Statistics**: Check energy usage at a glance with the statistics cards
- **Analyze Trends**: View daily and monthly charts to identify patterns
- **Track Costs**: Monitor estimated energy costs
- **Review Details**: Check the detailed daily log table
- **Get Tips**: Follow energy-saving recommendations

## Customization

### Update Energy Rates

Edit `js/app.js` and change the `COST_PER_KWH` variable:
```javascript
const COST_PER_KWH = 0.12; // Change to your local rate
```

### Add Real Data

Replace sample data in `data/energy-data.json` with your actual consumption data, or modify `energyData` in `js/app.js`.

### Customize Colors

Edit CSS variables in `css/style.css`:
```css
:root {
    --primary-color: #2c3e50;
    --secondary-color: #3498db;
    --accent-color: #e74c3c;
    /* ... more colors ... */
}
```

## Deployment

### Deploy to AWS S3 (Static Website Hosting)

#### Step 1: Create S3 Bucket

1. Go to [AWS S3 Console](https://s3.console.aws.amazon.com/)
2. Click "Create bucket"
3. Enter bucket name: `energy-dashboard-yourusername`
4. Choose region (closest to you)
5. **Uncheck** "Block all public access"
6. Click "Create bucket"

#### Step 2: Enable Static Website Hosting

1. Select your bucket
2. Go to "Properties" tab
3. Scroll to "Static website hosting"
4. Click "Edit"
5. Enable static website hosting
6. Index document: `index.html`
7. Click "Save changes"

#### Step 3: Set Bucket Permissions

1. Go to "Permissions" tab
2. Click on "Bucket Policy" section
3. Add this policy (replace bucket name):
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

#### Step 4: Upload Files

Option A: Using AWS Console
1. Click "Upload"
2. Drag and drop all files and folders
3. Click "Upload"

Option B: Using AWS CLI
```bash
# Install AWS CLI if not already installed
# Then configure your credentials
aws configure

# Upload to S3
aws s3 sync . s3://energy-dashboard-yourusername/ --exclude ".git*" --exclude "node_modules/*"
```

Option C: Using Git Actions (Automated Deployment)

Create `.github/workflows/deploy.yml`:
```yaml
name: Deploy to S3

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: actions/setup-node@v2
        with:
          node-version: '16'
      
      - name: Deploy to S3
        uses: jakejarvis/s3-sync-action@master
        with:
          args: --acl public-read --follow-symlinks --delete --exclude '.git*' --exclude 'node_modules/*'
        env:
          AWS_S3_BUCKET: energy-dashboard-yourusername
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          AWS_REGION: us-east-1
```

#### Step 5: Access Your Dashboard

Your dashboard will be available at:
```
http://energy-dashboard-yourusername.s3-website-us-east-1.amazonaws.com
```

Or with a custom domain (optional).

### Deploy Using GitHub Pages (Alternative)

1. Push code to GitHub
2. Go to repository Settings → Pages
3. Select main branch as source
4. Your dashboard will be at `https://yourusername.github.io/energy-dashboard`

## GitHub Repository Setup

### Initial Setup

```bash
# Initialize git (if not already done)
git init

# Add all files
git add .

# Create initial commit
git commit -m "Initial commit: Add energy dashboard"

# Create GitHub repository and add remote
git remote add origin https://github.com/yourusername/energy-dashboard.git

# Push to GitHub
git push -u origin main
```

### Keep Your Repo Updated

```bash
# Make changes and commit
git add .
git commit -m "Your commit message"

# Push to GitHub
git push origin main
```

## Future Enhancements

- [ ] Real-time data integration with IoT devices
- [ ] User authentication and profiles
- [ ] Data export (CSV, PDF)
- [ ] Advanced filtering and date range selection
- [ ] Predictive analytics
- [ ] Mobile app version
- [ ] Dark mode toggle
- [ ] Multi-language support
- [ ] Weather integration for consumption correlation

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For issues, questions, or suggestions, please open an issue on GitHub.

## Acknowledgments

- Chart.js for beautiful visualizations
- AWS for cloud infrastructure
- GitHub for version control

## Contact

- GitHub: [@yourusername](https://github.com/yourusername)
- Email: your.email@example.com

---

**Happy monitoring! ⚡**
