# 💰 Smart Budget Manager

A comprehensive Flutter-based personal finance management application designed to help you take control of your finances across multiple budget categories.

[![Flutter](https://img.shields.io/badge/Flutter-3.5.4-blue.svg)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.0+-blue.svg)](https://dart.dev/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Web Support](https://img.shields.io/badge/Web-Supported-brightgreen.svg)](https://flutter.dev/web)

## 🌟 Overview

Smart Budget Manager is a modern, intuitive personal finance application that helps you manage your money across four key areas:
- **Monthly Expenses** - Track daily income and expenses
- **Special Purchases** - Manage wishlist and special item budgets  
- **Travel Budget** - Plan and track travel expenses by category
- **Savings Goals** - Set and achieve financial goals with progress monitoring

## ✨ Key Features

### 🏠 **Dashboard Overview**
- **Real-time Budget Cards**: Visual overview of all budget categories
- **Progress Indicators**: See your financial health at a glance
- **Quick Navigation**: Easy access to all features from the home screen
- **Monthly Summaries**: Current month financial snapshot

### 💳 **Monthly Expenses Management**
- **Income & Expense Tracking**: Record all your monthly financial transactions
- **Category-based Organization**: Organize expenses by Food, Transport, Entertainment, Bills, Shopping, and Other
- **Budget Setting**: Set monthly budgets and track spending against them
- **Visual Progress**: Progress bars showing budget consumption
- **Transaction History**: Complete record of all monthly transactions
- **Remaining Budget**: Real-time calculation of available funds

### 🛍️ **Special Purchases (Wishlist)**
- **Wishlist Management**: Create and manage your special purchase items
- **Priority System**: Set priority levels (Low, Medium, High) for items
- **Budget Allocation**: Set monthly budgets for special purchases
- **Purchase Tracking**: Mark items as purchased and track spending
- **Progress Monitoring**: Visual indicators of special purchase budget usage
- **Item Categories**: Organize items by type and priority

### ✈️ **Travel Budget Management**
- **Trip Planning**: Create and manage multiple travel trips
- **Comprehensive Categories**: Track expenses across 6 categories:
  - 🏨 Accommodation (Hotels, Airbnb)
  - 🍽️ Food & Dining (Restaurants, groceries)
  - 🚗 Transportation (Flights, taxis, car rentals)
  - 🎯 Activities (Tours, attractions, entertainment)
  - 🛍️ Shopping (Souvenirs, personal purchases)
  - 📋 Other (Miscellaneous expenses)
- **Trip Status Tracking**: Planning → Active → Completed workflow
- **Budget Monitoring**: Real-time expense tracking against trip budget
- **Trip History**: Complete record of past trips with spending summaries
- **Analytics**: Detailed spending breakdown by category

### 🎯 **Savings Goals**
- **Multiple Goal Management**: Create and track multiple savings goals simultaneously
- **9 Goal Categories**: Emergency Fund, Vacation, House, Car, Education, Retirement, Investment, Gadgets, Other
- **Priority System**: 4 priority levels (Low, Medium, High, Urgent) with color coding
- **Progress Tracking**: Visual progress bars and percentage completion
- **Target Date Monitoring**: Track days remaining until target date
- **Smart Calculations**: Automatic calculation of required monthly savings
- **Achievement System**: Celebrate completed goals with special UI
- **Savings Records**: Detailed history of all contributions

## 🛠️ Technical Features

### 📱 **Cross-Platform Support**
- **Flutter Framework**: Single codebase for multiple platforms
- **Web Compatibility**: Runs seamlessly in web browsers
- **Mobile Ready**: Optimized for iOS and Android devices
- **Responsive Design**: Adapts to different screen sizes

### 💾 **Data Management**
- **SQLite Database**: Robust local data storage for mobile devices
- **Web Storage Fallback**: In-memory storage for web platform testing
- **Data Persistence**: All your financial data is stored locally
- **Real-time Updates**: Instant UI updates when data changes

### 🎨 **User Interface**
- **Material Design 3**: Modern, clean, and intuitive interface
- **Color-coded Categories**: Visual distinction between different budget types
- **Interactive Cards**: Engaging card-based interface design
- **Progress Indicators**: Visual feedback for all budget tracking
- **Tabbed Navigation**: Organized content with easy navigation

### 🔄 **State Management**
- **Provider Pattern**: Efficient state management across the app
- **Reactive UI**: Automatic UI updates when data changes
- **Optimized Performance**: Smooth user experience with minimal lag
- **Error Handling**: Graceful handling of edge cases and errors

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.5.4 or higher
- Dart SDK 3.0 or higher
- Web browser (for web testing)
- Android/iOS device or emulator (for mobile testing)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/medaminenasfi/Smart-buudgeet-manager.git
   cd Smart-buudgeet-manager
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the application**
   
   For web:
   ```bash
   flutter run -d chrome --web-renderer html
   ```
   
   For mobile:
   ```bash
   flutter run
   ```

## 📱 Usage Guide

### Getting Started with Smart Budget Manager

1. **Launch the App**: Open Smart Budget Manager on your device
2. **Explore the Dashboard**: View your financial overview on the home screen
3. **Set Up Your First Budget**: Click on "Monthly Expenses" to set your monthly budget
4. **Add Transactions**: Start recording your income and expenses
5. **Create Goals**: Set up savings goals in the "Savings Goals" section
6. **Plan Travel**: Use "Travel Budget" for your next trip planning

### Monthly Expenses Workflow

1. **Set Monthly Budget**: Start by setting your total monthly budget
2. **Record Income**: Add your salary and other income sources
3. **Track Expenses**: Log expenses as they occur, categorized appropriately
4. **Monitor Progress**: Check your budget card regularly to see remaining funds
5. **Review Monthly**: At month-end, review your spending patterns

### Travel Planning Workflow

1. **Create Trip**: Set destination, budget, and travel dates
2. **Track Expenses**: Log expenses in appropriate categories during your trip
3. **Monitor Budget**: Keep an eye on your spending vs. budget
4. **Complete Trip**: Mark trip as complete when finished
5. **Review History**: Analyze past trips for better future planning

### Savings Goals Workflow

1. **Create Goal**: Set name, target amount, category, and target date
2. **Add Savings**: Regularly contribute to your goals
3. **Track Progress**: Monitor progress bars and remaining amounts
4. **Achieve Goals**: Celebrate when you reach your targets!

## 🏗️ Architecture

### Project Structure
```
lib/
├── database/          # Database operations and helpers
├── models/           # Data models for all entities
├── providers/        # State management with Provider pattern
├── screens/          # UI screens for different features
├── utils/           # Constants and utility functions
└── widgets/         # Reusable UI components
```

### Key Components

- **DatabaseHelper**: Manages SQLite database operations
- **Providers**: Handle business logic and state management
- **Models**: Define data structures for budgets, expenses, goals, etc.
- **Screens**: Individual pages for different app features
- **Widgets**: Reusable UI components like BudgetCard, CustomAppBar

## 🎯 Features in Detail

### Budget Categories

| Category | Purpose | Key Features |
|----------|---------|--------------|
| **Monthly Expenses** | Daily financial tracking | Income/expense recording, category organization, budget limits |
| **Special Purchases** | Wishlist management | Item prioritization, purchase tracking, budget allocation |
| **Travel Budget** | Trip expense management | Multi-category tracking, trip lifecycle, budget monitoring |
| **Savings Goals** | Long-term financial goals | Progress tracking, target dates, achievement celebrations |

### Data Visualization

- **Progress Bars**: Visual representation of budget usage
- **Percentage Indicators**: Exact completion percentages
- **Color Coding**: Intuitive color schemes for different categories
- **Status Badges**: Quick status identification with visual badges
- **Interactive Cards**: Engaging card-based data presentation

## 🔒 Privacy & Security

- **Local Storage**: All data is stored locally on your device
- **No Cloud Dependency**: Works completely offline
- **Data Control**: You have full control over your financial data
- **Privacy First**: No personal data is transmitted or stored externally

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👨‍💻 Author

**Mohamed Amine Nasfi**
- GitHub: [@medaminenasfi](https://github.com/medaminenasfi)

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Material Design team for the design system
- SQLite team for the robust database engine
- Provider package maintainers for state management solution

## 📞 Support

If you have any questions or need help with the app, please:
1. Check the documentation above
2. Search existing issues on GitHub
3. Create a new issue if your question isn't answered

---

**Smart Budget Manager** - Take control of your finances, one budget at a time! 💰✨
