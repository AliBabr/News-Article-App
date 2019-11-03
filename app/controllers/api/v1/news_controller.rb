# frozen_string_literal: true

class Api::V1::NewsController < ApplicationController
  before_action :authenticate # call back for validating user
  before_action :set_news, only: %i[update destroy]
  before_action :is_admin, only: %i[create update destroy]

  #Methode that take parameters and create news
  def create
    news = News.new(news_params); image_url = ''
    if news.save
      image_url = url_for(news.image) if news.image.attached?
      render json: { id: news.id, title: news.title, website_address: news.website_address, description: news.description, url: news.url, category: news.category, image: image_url }, status: 200
    else
      render json: news.errors.messages, status: 400
    end
  rescue StandardError => e # rescue if any exception occure
    render json: { message: 'Error: Something went wrong... ' }, status: :bad_request
  end

  #Methode that return all news
  def index
    newss = []
    News.all.each do |ne|
      image_url = ''
      image_url = url_for(ne.image) if ne.image.attached?
      newss << { title: ne.title, website_address: ne.website_address, description: ne.description, url: ne.url, category: ne.category, image: image_url }
    end
    render json: newss, status => 200
  rescue StandardError => e # rescue if any exception occure
    render json: { message: 'Error: Something went wrong... ' }, status: :bad_request
  end

  #Methode to update News
  def update
    @news.update(news_params)
    if @news.errors.any?
      render json: @news.errors.messages, status: 400
    else
      image_url = ''
      image_url = url_for(@news.image) if @news.image.attached?
      render json: { title: @news.title, website_address: @news.website_address, description: @news.description, url: @news.url, category: @news.category, image: image_url }, status: 200
    end
  rescue StandardError => e # rescu if any exception occure
    render json: { message: 'Error: Something went wrong... ' }, status: :bad_request
  end

  #Methode to delete news
  def destroy
    @news.destroy
    render json: { message: 'News deleted successfully!' }, status: 200
  rescue StandardError => e # rescu if any exception occure
    render json: { message: 'Error: Something went wrong... ' }, status: :bad_request
  end

  #Methode for search news
  def search
    query = params[:query]
    if params[:query].blank? || query.length < 3
      render json: { message: 'Search query is not present or length is short!' }, status: 404
    else
      result = News.search(query); newss = []
      result.all.each do |ne|
        image_url = ''
        image_url = url_for(ne.image) if ne.image.attached?
        newss << { title: ne.title, website_address: ne.website_address, description: ne.description, url: ne.url, category: ne.category, image: image_url }
      end
      render json: newss, status => 200
    end
  rescue StandardError => e # rescu if any exception occure
    render json: { message: 'Error: Something went wrong... ' }, status: :bad_request
  end

  private

  def news_params
    params.permit(:title, :website_address, :description, :url, :category, :image)
  end

  def set_news
    @news = News.find_by_id(params[:id])
    if @news.present?
      return true
    else
      render json: { message: 'News Not found!' }, status: 404
    end
  end

  def is_admin
    if @user.role == 'admin'
      return true
    else
      render json: { message: "Only admin can create/update/destroy news!"}
    end
  end
end
