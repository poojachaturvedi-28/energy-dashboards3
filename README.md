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

## Documentation Highlights

This README now covers the main ways to work with and deploy the project:

- **CI/CD workflow details** for automated validation and publishing
- **GitHub Pages deployment steps** for hosting the static site
- **Local preview instructions** for running the app on your machine
- **Docker usage** for containerized development and deployment

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

## Deployment and CI/CD

This project is deployed as a static website and uses GitHub Actions for automated validation and publishing.

### Automated deployment workflow

Every push to the main branch triggers the workflow in [.github/workflows/deploy.yml](.github/workflows/deploy.yml), which:

- validates that the core site files exist
- runs the deployment job
- publishes the site to GitHub Pages from the gh-pages branch

A companion workflow file, [deploy.yml](deploy.yml), is also included for the same deployment target.

### GitHub Pages setup

1. Push the repository to GitHub.
2. Open your repository settings and go to Pages.
3. Select the source as Deploy from a branch.
4. Choose the gh-pages branch and the root folder.
5. Save the settings.

Your site will then be available at your GitHub Pages URL.

### Local development

Run the dashboard locally with:

```bash
python -m http.server 8000
```

Then open http://localhost:8000 in your browser.

### Docker option

You can also run the app using Docker Compose:

```bash
docker compose up --build
```

The app will be available at http://localhost:8080.

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

- GitHub: [@poojachaturvedi-28](https://github.com/poojachaturvedi-28)
- Email: pooja.chaturvedi@nirmauni.ac.in

---

**Happy monitoring! ⚡**
