# frozen_string_literal: true

class Comics
  def initialize
    @client = Marvel::Client.new
    @client.configure do |config|
      config.api_key = ENV['MARVEL_PUBLIC_KEY']
      config.private_key = ENV['MARVEL_PRIVATE_KEY']
    end
  end

  def get_all_comics
    comics = @client.comics
    if comics.present?
      return comics
    else
      return false
    end
  end

  def search_comic(title)
    comics = @client.comics(title: title)
    if comics.present?
      return comics
    else
      return false
    end
  end

  def get_details(id)
    comic = @client.comic(id)
    if comic.present?
      return comic
    else
      return false
    end
  end

end
