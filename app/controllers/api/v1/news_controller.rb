# frozen_string_literal: true

class Api::V1::NewsController < ApplicationController
  before_action :authenticate # call back for validating user

  # Methode to get comic news
  def comic_news
    comics = Comics.new().get_all_comics
    insert_news(comics, 'comic')
    comics_news = []
    comics_news << { Comics: comics } if comics.present?
    render json: comics_news, status => 200
  rescue StandardError => e # rescue if any exception occure
    render json: { message: 'Error: Something went wrong... ' }, status: :bad_request
  end

  # Methode to get gaming news
  def gaming_news
    game_items = Gaming.new().get_all_games
    games = JSON.parse game_items
    insert_news(games['results'], 'gaming')
    gaming_news = []
    gaming_news << { Gaming: games['results'] } if games.present?
    render json: gaming_news, status => 200
  rescue StandardError => e # rescue if any exception occure
    render json: { message: 'Error: Something went wrong... ' }, status: :bad_request
  end

  # Methode that return all news
  def index
    comics = Comics.new().get_all_comics
    game_items = Gaming.new().get_all_games
    games = JSON.parse game_items
    insert_news(comics, 'comic')
    insert_news(games['results'], 'gaming')
    response = Hash.new { |h, k| h[k] = Hash.new(&h.default_proc) }
    response[:News] = { Comics: comics, Gaming: games['results'] }
    render json: response, status => 200
  rescue StandardError => e # rescue if any exception occure
    render json: { message: 'Error: Something went wrong... ' }, status: :bad_request
  end

  # Methode to get details for specific news
  def get_news_details
    if params[:id].present?
      response = []
      if params[:type] == 'comics'
        comics = Comics.new().get_details(params[:id].to_i)
        response << { Comics: comics } if comics.present?
      elsif params[:type] == 'gaming'
        game_items = Gaming.new().get_details(params[:id].to_i)
        games = JSON.parse game_items
        response << { Gaming: games } if games.present?
      end
      render json: response, status => 200
    else
      render json: { message: "Id can't be blank" }, status: 404
    end
  rescue StandardError => e # rescue if any exception occure
    render json: { message: 'Error: Something went wrong... ' }, status: :bad_request
  end

  # Methode for search news
  def search
    query = params[:query]
    if params[:query].blank? || query.length < 3
      render json: { message: 'Search query is not present or length is short!' }, status: 404
    else
      result = News.search(query); newss = []
      result.all.each do |ne|
        item = News.find_by_news_tok(ne.news_tok)
        newss << {category: ne.category, news: item.data}
      end
      render json: newss, status => 200
    end
  rescue StandardError => e # rescu if any exception occure
    render json: { message: 'Error: Something went wrong... ' }, status: :bad_request
  end

  def insert_news(news, type)
    if type == 'gaming'
      news.each do |game|
        News.find_or_create_by(title: game['name'], news_tok: game['id'], category: 'gaming', data: game)
      end
    elsif type == 'comic'
      news.each do |comic|
        News.find_or_create_by(title: comic.title, news_tok: comic.id, category: 'comics', data: comic)
      end
    end
  end

end
