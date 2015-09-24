require 'yaml'
require 'forecast'

describe Forecast do
  
  location = 'Sidney'
  
  # Load Fixtures
  locations = YAML.load_file(File.expand_path(File.dirname(__FILE__) + "/fixtures/locations.yml"))
  
  # Get Location
  coords = locations[location] ? locations[location] : location
  latitude = coords['latitude'].to_f
  longitude = coords['longitude'].to_f
  
  # Configure Forecast
  Forecast.configure do |config|
    config.scale = :celsius
    config.provider = :open_weather_map
  end
  
  def dump_forecast(forecast)
    if forecast != nil
      puts forecast.time.strftime("%F %T") + " | " + forecast.temperature.to_s + " | " + forecast.condition.to_s + " | " + forecast.text.to_s + " | " + forecast.icon.to_s
    else
      puts 'nil'
    end
  end
  
  it "currently" do 
    puts "\n\n"
    puts "> #{location.to_s} currently (" + Forecast.config.provider.to_s + ")"
    puts "*************************************************************"
    forecast = Forecast.currently(latitude, longitude)
    dump_forecast(forecast)
    expect(forecast).not_to be_nil
  end
  
  
  
  it "hourly" do 
    puts "\n\n"
    puts "> #{location.to_s} hourly (" + Forecast.config.provider.to_s + ")"
    puts "*************************************************************"
    forecasts = Forecast.hourly(latitude, longitude)
    forecasts.each do |forecast|
      dump_forecast(forecast)
    end
    expect(forecasts.size).to be >= 1
  end
  
  it "daily" do
    puts "\n\n"
    puts "> #{location.to_s} daily (" + Forecast.config.provider.to_s + ")"
    puts "*************************************************************"
    forecasts = Forecast.daily(latitude, longitude)
    forecasts.each do |forecast|
      dump_forecast(forecast)
    end
    expect(forecasts.size).to be >= 1
  end
  
  it "select_time" do 
    time = Time.now + (24 * 60 * 60)
    puts "\n\n"
    puts "> #{location.to_s} at tomorrow, #{time.strftime("%T")} (" + Forecast.config.provider.to_s + ")"
    puts "*************************************************************"
    forecast = Forecast.daily(latitude, longitude).select_time(time)
    dump_forecast(forecast)
    expect(forecast).not_to be_nil
  end
end