# frozen_string_literal: true

class Gaming
  def initialize; end

  def get_all_games
    url = URI('https://rawg-video-games-database.p.rapidapi.com/games')
    get_games(url)
  end

  def get_details(id)
    url = URI("https://rawg-video-games-database.p.rapidapi.com/games/#{id}")
    get_games(url)
  end

  def get_games(url)
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Get.new(url)
    request['x-rapidapi-host'] = ENV['x_rapidapi_host']
    request['x-rapidapi-key'] = ENV['x_rapidapi_key']
    response = http.request(request)
    if response.present?
      return response.read_body
    else
      return false
    end
  end

  def search_comic(title)
  end
end
