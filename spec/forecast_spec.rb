require 'forecast'
describe Forecast do
  
  def dump_forecast(forecast)
    if forecast != nil
      puts forecast.date.strftime("%F %T") + " | " + forecast.temp.to_s + " | " + forecast.condition + " | " + forecast.icon
    else
      puts 'nil'
    end
  end
  
  it "current" do 
    puts "*** CURRENT ***"
    forecast = Forecast.current(54.9999, 9.534)
    dump_forecast(forecast)
    expect(forecast).not_to be_nil
  end
  it "hourly" do 
    puts "*** HOURLY FORECASTS ***"
    forecasts = Forecast.hourly(54.9999, 9.534)
    forecasts.each do |forecast|
      dump_forecast(forecast)
    end
    expect(forecasts.size).to be >= 1
  end
  it "daily" do 
    puts "*** DAILY FORECASTS ***"
    forecasts = Forecast.daily(54.9999, 9.534)
    forecasts.each do |forecast|
      #puts forecast.date.strftime("%F %T") + " | " + forecast.temp_min.to_s + " | " + forecast.temp_max.to_s + " | " + forecast.condition + " | " + forecast.icon
      dump_forecast(forecast)
    end
    expect(forecasts.size).to be >= 1
  end
  it "select_date" do 
    puts "*** SELECT FORECAST ***"
    forecast = Forecast.daily(54.9999, 9.534).select_date(Time.now + (24*60*60) * 2)
    dump_forecast(forecast)
    expect(forecast).not_to be_nil
  end
end