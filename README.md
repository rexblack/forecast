forecast
========

> A Forecast-Multi-API-Wrapper with a unified model and integrated caching

## API Support

* Open Weather Map
* Yahoo RSS
* Forecast.io
* Wunderground


## Fetch

#### Forecast.current( latitude, longitude )
Get the current weather for a specified location
```ruby
forecast = Forecast.current(54.9999, 9.534)
```

#### Forecast.hourly( latitude, longitude )
Get hourly forecasts for a specified location
```ruby
forecasts = Forecast.hourly(54.9999, 9.534)
```


#### Forecast.daily( latitude, longitude )
Get daily forecasts for a specified location
```ruby
forecasts = Forecast.daily(54.9999, 9.534)
```

### Collections

#### ForecastCollection.select_time( date )
Fetches forecast for the specified date from a collection.
```ruby
forecast = Forecast.daily(54.9999, 9.534).select_time(Time.now + (24 * 60 * 60) * 2)
```

## Model

<table>
  <tr>
    <th>Name</th>
    <th>Description</th>
  </tr>
  <tr>
    <td>condition</td>
    <td>Condition string identifier.</td>
  </tr>
  <tr>
    <td>time</td>
    <td>DateTime of the forecast</td>
  </tr>
  <tr>
    <td>icon</td>
    <td>Returns icon identifier</td>
  </tr>
  <tr>
    <td>latitude</td>
    <td>Location coordinate latitude</td>
  </tr>
  <tr>
    <td>longitude</td>
    <td>Location coordinate longitude</td>
  </tr>
  <tr>
    <td>temperature</td>
    <td>Temperature</td>
  </tr>
  <tr>
    <td>temperature_min</td>
    <td>Minimum Temperature</td>
  </tr>
  <tr>
    <td>temperature_max</td>
    <td>Maximum Temperature</td>
  </tr>
</table>


## Conditions

<table>
  <tr>
    <th>Code</th>
    <th>Name</th>
  </tr>
  <tr>
    <td>100</td>
    <td>Clear</td>
  </tr>
  <tr>
    <td>200</td>
    <td>Partly Cloudy</td>
  </tr>
  <tr>
    <td>210</td>
    <td>Cloudy</td>
  </tr>
  <tr>
    <td>220</td>
    <td>Mostly Cloudy</td>
  </tr>
  <tr>
    <td>300</td>
    <td>Light Rain</td>
  </tr>
  <tr>
    <td>310</td>
    <td>Rain</td>
  </tr>
  <tr>
    <td>320</td>
    <td>Heavy Rain</td>
  </tr>
  <tr>
    <td>400</td>
    <td>Light Snow</td>
  </tr>
  <tr>
    <td>410</td>
    <td>Snow</td>
  </tr>
  <tr>
    <td>500</td>
    <td>Storm</td>
  </tr>
</table>


## Themes
Bundled with the plugin is an icon-mapping for [weather_icons](http://erikflowers.github.io/weather-icons/)

## Rails Integration

##### Add weather-icons theme to your stylesheets
```erb
<%= stylesheet_link_tag "http://cdnjs.cloudflare.com/ajax/libs/weather-icons/1.2/css/weather-icons.css", media: "all", "data-turbolinks-track" => true %>
```

##### Create a forecast-helper
```ruby
module ApplicationHelper
  def forecast(latitude, longitude, date)
    forecast = Forecast.daily(latitude, longitude).select_date(date)
    content_tag('span', content_tag('i', ' ', class: "forecast-icon " + forecast.icon) + " ".html_safe + content_tag('span', (forecast.temp.to_s + "&#176;").html_safe, class: 'forecast-temp'), class: 'forecast')
  end
end
```

##### Create a view
```erb
<h1>Forecast Test</h1>
<p>
  The weather of tomorrow in New York: <%= forecast(41.145495, -73.994901, Time.now + 60*60*24) %>
</p>
```

#### Example Configuration

```ruby
# config/initializers/forecast.rb
Forecast::configure do |config|
  config.config_file = Rails.root.to_s + "/config/forecast.yml"
  config.cache = {
    expire: 1 * 60 * 60, 
    prefix: 'forecast', 
    url: "redis://xxx/"
  }
end
```

```yml
# config/forecast.yml
forecast:
  temperature: celsius
  theme: custom_theme
  themes: 
    custom_theme:
      Clear: 'icon-clear'
      Light Rain: 'icon-rain'
      Rain: 'icon-rain'
      Heavy Rain: 'icon-rain'
      Partly Cloudy: 'icon-cloudy'
      Cloudy: 'icon-cloudy'
      Mostly Cloudy: 'icon-cloudy'
      Light Snow: 'icon-snow'
      Snow: 'icon-snow'
      Heavy Snow: 'icon-snow'
      Thunderstorm: 'icon-thunderstorm'
```

## Command Line Interface

```cli
Usage: forecast COMMAND [OPTIONS]

Commands
     current: get current weather
     daily: get daily forecasts
     hourly: get hourly forecasts

Options
    -l, --location LAT,LNG           Location
    -p, --provider PROVIDER          Supported API Providers: forecast_io, open_weather_map, wunderground, yahoo
    -a, --api_key API_KEY            Apply an api key if neccessary
    -s, --scale SCALE                Scale: one of celsius, fahrenheit or kelvin
```

## Run Tests
To run the tests execute `rspec spec` from the command line
```cli
rspec spec
```

## Changelog
See the [Changelog](CHANGELOG.md) for recent enhancements, bugfixes and deprecations.
