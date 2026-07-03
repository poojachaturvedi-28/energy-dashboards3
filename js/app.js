// Energy Consumption Dashboard Application

// Sample Data
const energyData = {
    dailyData: [
        { date: '2026-06-27', usage: 15.2, cost: 1.82 },
        { date: '2026-06-28', usage: 18.5, cost: 2.22 },
        { date: '2026-06-29', usage: 16.8, cost: 2.02 },
        { date: '2026-06-30', usage: 20.1, cost: 2.41 },
        { date: '2026-07-01', usage: 19.3, cost: 2.32 },
        { date: '2026-07-02', usage: 21.5, cost: 2.58 },
        { date: '2026-07-03', usage: 22.8, cost: 2.74 }
    ],
    monthlyData: [
        { month: 'January', usage: 450 },
        { month: 'February', usage: 420 },
        { month: 'March', usage: 380 },
        { month: 'April', usage: 350 },
        { month: 'May', usage: 320 },
        { month: 'June', usage: 385 }
    ]
};

const COST_PER_KWH = 0.12; // $0.12 per kWh

// Initialize Dashboard
document.addEventListener('DOMContentLoaded', function() {
    console.log('Dashboard initialized');
    updateStatistics();
    createDailyChart();
    createMonthlyChart();
    populateDataTable();
});

// Update Statistics Cards
function updateStatistics() {
    const data = energyData.dailyData;
    const lastDay = data[data.length - 1];
    
    // Today's Usage
    const todayUsage = lastDay.usage.toFixed(1);
    document.getElementById('todayUsage').textContent = todayUsage;
    
    // Month's Usage
    const monthUsage = data.reduce((sum, day) => sum + day.usage, 0).toFixed(1);
    document.getElementById('monthUsage').textContent = monthUsage;
    
    // Average Daily Usage
    const avgUsage = (monthUsage / data.length).toFixed(1);
    document.getElementById('avgUsage').textContent = avgUsage;
    
    // Estimated Cost (Monthly)
    const monthCost = (monthUsage * COST_PER_KWH).toFixed(2);
    document.getElementById('costUsage').textContent = monthCost;
}

// Create Daily Chart (Line Chart)
function createDailyChart() {
    const ctx = document.getElementById('dailyChart').getContext('2d');
    const dates = energyData.dailyData.map(d => new Date(d.date).toLocaleDateString('en-US', { month: 'short', day: 'numeric' }));
    const usages = energyData.dailyData.map(d => d.usage);
    
    new Chart(ctx, {
        type: 'line',
        data: {
            labels: dates,
            datasets: [{
                label: 'Energy Usage (kWh)',
                data: usages,
                borderColor: '#3498db',
                backgroundColor: 'rgba(52, 152, 219, 0.1)',
                borderWidth: 2,
                fill: true,
                tension: 0.4,
                pointBackgroundColor: '#3498db',
                pointBorderColor: '#fff',
                pointBorderWidth: 2,
                pointRadius: 5,
                pointHoverRadius: 7
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: true,
            plugins: {
                legend: {
                    display: true,
                    labels: {
                        font: {
                            size: 12
                        },
                        color: '#2c3e50'
                    }
                }
            },
            scales: {
                y: {
                    beginAtZero: true,
                    grid: {
                        color: 'rgba(0, 0, 0, 0.05)'
                    },
                    ticks: {
                        color: '#7f8c8d'
                    },
                    title: {
                        display: true,
                        text: 'kWh'
                    }
                },
                x: {
                    grid: {
                        color: 'rgba(0, 0, 0, 0.05)'
                    },
                    ticks: {
                        color: '#7f8c8d'
                    }
                }
            }
        }
    });
}

// Create Monthly Chart (Bar Chart)
function createMonthlyChart() {
    const ctx = document.getElementById('monthlyChart').getContext('2d');
    const months = energyData.monthlyData.map(d => d.month);
    const usages = energyData.monthlyData.map(d => d.usage);
    
    new Chart(ctx, {
        type: 'bar',
        data: {
            labels: months,
            datasets: [{
                label: 'Monthly Usage (kWh)',
                data: usages,
                backgroundColor: [
                    'rgba(52, 152, 219, 0.7)',
                    'rgba(46, 204, 113, 0.7)',
                    'rgba(155, 89, 182, 0.7)',
                    'rgba(230, 126, 34, 0.7)',
                    'rgba(52, 73, 94, 0.7)',
                    'rgba(41, 128, 185, 0.7)'
                ],
                borderColor: [
                    '#3498db',
                    '#2ecc71',
                    '#9b59b6',
                    '#e67e22',
                    '#34495e',
                    '#2980b9'
                ],
                borderWidth: 2
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: true,
            indexAxis: 'x',
            plugins: {
                legend: {
                    display: true,
                    labels: {
                        font: {
                            size: 12
                        },
                        color: '#2c3e50'
                    }
                }
            },
            scales: {
                y: {
                    beginAtZero: true,
                    grid: {
                        color: 'rgba(0, 0, 0, 0.05)'
                    },
                    ticks: {
                        color: '#7f8c8d'
                    }
                },
                x: {
                    grid: {
                        color: 'rgba(0, 0, 0, 0.05)'
                    },
                    ticks: {
                        color: '#7f8c8d'
                    }
                }
            }
        }
    });
}

// Populate Data Table
function populateDataTable() {
    const tbody = document.getElementById('dataTableBody');
    tbody.innerHTML = ''; // Clear existing rows
    
    energyData.dailyData.forEach(day => {
        const row = document.createElement('tr');
        const date = new Date(day.date).toLocaleDateString('en-US', { 
            weekday: 'short', 
            year: 'numeric', 
            month: 'short', 
            day: 'numeric' 
        });
        
        // Determine status based on usage
        let status, statusClass;
        if (day.usage < 16) {
            status = 'Low';
            statusClass = 'status-low';
        } else if (day.usage < 19) {
            status = 'Normal';
            statusClass = 'status-normal';
        } else if (day.usage < 22) {
            status = 'High';
            statusClass = 'status-high';
        } else {
            status = 'Critical';
            statusClass = 'status-critical';
        }
        
        row.innerHTML = `
            <td>${date}</td>
            <td>${day.usage.toFixed(2)}</td>
            <td>$${day.cost.toFixed(2)}</td>
            <td class="${statusClass}">${status}</td>
        `;
        tbody.appendChild(row);
    });
}

// Utility Functions for Future Features

/**
 * Calculate energy savings between two dates
 * @param {string} startDate - Start date (YYYY-MM-DD)
 * @param {string} endDate - End date (YYYY-MM-DD)
 * @returns {object} Savings data
 */
function calculateSavings(startDate, endDate) {
    // Implementation for future feature
    return null;
}

/**
 * Generate energy report
 * @returns {string} HTML report
 */
function generateReport() {
    const totalUsage = energyData.dailyData.reduce((sum, day) => sum + day.usage, 0);
    const totalCost = energyData.dailyData.reduce((sum, day) => sum + day.cost, 0);
    const avgUsage = (totalUsage / energyData.dailyData.length).toFixed(2);
    
    return `
        <div class="report">
            <h3>Energy Consumption Report</h3>
            <p>Total Usage: ${totalUsage.toFixed(2)} kWh</p>
            <p>Total Cost: $${totalCost.toFixed(2)}</p>
            <p>Average Daily Usage: ${avgUsage} kWh</p>
            <p>Period: ${energyData.dailyData[0].date} to ${energyData.dailyData[energyData.dailyData.length - 1].date}</p>
        </div>
    `;
}

// Export functions for testing
if (typeof module !== 'undefined' && module.exports) {
    module.exports = {
        updateStatistics,
        calculateSavings,
        generateReport
    };
}
