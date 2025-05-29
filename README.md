# 🌦️ Weather App

A simple Rails app that fetches and displays current weather data using the OpenWeather API.

---

## ✅ Prerequisites

Make sure you have the following installed:

- **Ruby** 2.7.6
- **Rails** 6.1
- **PostgreSQL** 12.x or higher
- **Bundler**
- **Redis** (optional, for caching)
- **Node/Yarn** (for JS runtime, if needed)
- **RSpec** (testing framework)

---

## 🛠️ Setup Instructions

### 1. Clone the Repository

```bash
git clone https://github.com/kalil1/weather_app.git
cd weather_app
```
2. Install Gems
```bash
bundle install
```
3. Database Setup
- Update the config/database.yml file with your PostgreSQL credentials if necessary.

- Then run:
```bash
rails db:create
rails db:migrate
```

4. Start the Rails Server
- Run the app on port 3000:

```bash
rails s
```
- Visit http://localhost:3000

### 3. Set Your API Key
1. Create a .env file in the root of the project to store your OpenWeather API key:
```bash
# Make sure you're in the root of the app directory /weather_app
echo "OPENWEATHER_API_KEY=your_api_key_here" > .env
```
2. 🧪 Running Tests
- Prepare the Test Database
```bash
rails db:test:prepare

```
- Then run the test suite:
```bash
bundle exec rspec

```