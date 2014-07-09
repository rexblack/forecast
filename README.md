forecast
========

A Forecast-Multi-API-Wrapper with a unified model and integrated caching


Integrating with rails
----------------------

#### Quick start

Add weather-icons theme to your stylesheets from cdn
```erb
<%= stylesheet_link_tag "http://cdnjs.cloudflare.com/ajax/libs/weather-icons/1.2/css/weather-icons.css", media: "all", "data-turbolinks-track" => true %>
```
Create a forecast-helper
```ruby
module ApplicationHelper
  def forecast(latitude, longitude, date)
    forecast = Forecast.daily(latitude, longitude).select_date(date)
    content_tag('span', content_tag('i', ' ', class: "forecast-icon " + forecast.icon) + " ".html_safe + content_tag('span', (forecast.temp.to_s + "&#176;").html_safe, class: 'forecast-temp'), class: 'forecast')
  end
end
```

Create a view
```erb
<h1>Forecast Test</h1>
<p>
  The weather of tomorrow in New York: <%= forecast(41.145495, -73.994901, Time.now + 60*60*24) %>
</p>
```