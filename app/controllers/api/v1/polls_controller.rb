# frozen_string_literal: true

class Api::V1::PollsController < ApplicationController
  before_action :authenticate # call back for validating user
  before_action :set_poll, only: %i[submit_answer destroy]
  before_action :is_admin, only: %i[create update destroy]

  # Methode to create poll and its answer options
  def create
    answer_options = params[:answer_options].values
    poll = Poll.new(poll_params)
    if poll.save
      for_create_poll(poll, answer_options)
    else
      render json: @poll.errors.messages, status: 400
    end
  rescue StandardError => e # rescu if any exception occure
    render json: { message: 'Error: Something went wrong please check params... ' }, status: :bad_request
  end

  # Methode to get all polls and its answers
  def index
    @response = []
    get_polls
    render json: @response, status => 200
  rescue StandardError => e # rescu if any exception occure
    render json: { message: 'Error: Something went wrong... ' }, status: :bad_request
  end

  # Methode to submit answer
  def submit_answer
    if params[:option_id].present? && AnswerOption.find_by_id(params[:option_id].to_i).present?
      ans_opt = AnswerOption.find_by_id(params[:option_id].to_i)
      ans_opt.update(votes: ans_opt.votes + 1)
      render json: { message: 'Your answer has been saved!' }, status: 200
    else
      render json: { message: 'Answer option is empty or invalid!' }, status: 404
    end
  rescue StandardError => e # rescu if any exception occure
    render json: { message: 'Error: Something went wrong... ' }, status: :bad_request
  end

  # Methode to delete poll
  def destroy
    @poll.destroy
    render json: { message: 'Poll deleted successfully!' }, status: 200
  rescue StandardError => e # rescu if any exception occure
    render json: { message: 'Error: Something went wrong... ' }, status: :bad_request
  end

  private

  def poll_params # permit poll parametrs
    params.permit(:poll_question, :total_days)
  end

  def answer_option_params # permit answer option parameters
    params.permit(:answer)
  end

  def set_poll # set instance of poll
    @poll = Poll.find_by_id(params[:id])
    if @poll.present?
      return true
    else
      render json: { message: 'Poll Not found!' }, status: 404
    end
  end

  # Helper methode  for creating poll and its answer options
  def for_create_poll(poll, answer_options)
    answer_options.each do |op|
      poll.answer_options.create(answer: op, votes: 0)
    end
    response = Hash.new { |h, k| h[k] = Hash.new(&h.default_proc) }; answers = []
    poll.answer_options.each_with_index do |ans_opt, index|
      answers << { option_no: index + 1, option: ans_opt.answer, votes: ans_opt.votes }
    end
    response[:poll] = { id: poll.id, poll_question: poll.poll_question, total_days: poll.total_days, options: answers }
    render json: response, status => 200
  end

  def is_admin
    if @user.role == 'admin'
      true
    else
      render json: { message: 'Only admin can create/update/destroy questions!' }
    end
  end

  def get_polls # Helper methode for making response for get poll request
    Poll.all.each do |poll|
      answers = []
      days = poll.total_days.to_i - (((Time.now - poll.created_at) / 60) / 1440).to_i
      if days == 0
        poll_result(poll, answers, days)
      else
        poll.answer_options.each_with_index do |ans_opt, _index|
          answers << { option_id: ans_opt.id, option: ans_opt.answer, votes: ans_opt.votes }
        end
        total_votes = poll.answer_options.pluck(:votes)
        @response << { id: poll.id, poll_question: poll.poll_question, days_left: days, status: 'Active', total_votes: total_votes.sum, options: answers }
      end
    end
  end

  #Helper methode fow getting poll results
  def poll_result(poll, answers, days)
    if poll.result_day.blank?
      poll.update(result_day: Time.now)
      poll.answer_options.each_with_index do |ans_opt, _index|
        answers << { option_no: ans_opt.id, option: ans_opt.answer, votes: ans_opt.votes }
      end
      total_votes = poll.answer_options.pluck(:votes)
      @response << { id: poll.id, poll_question: poll.poll_question, days_left: days, status: 'Result', total_votes: total_votes.sum, options: answers }
    else
      result_days_count = (((Time.now - poll.result_day) / 60) / 1440).to_i
      if result_days_count > 2
        poll.destroy
      else
        poll.answer_options.each_with_index do |ans_opt, _index|
          answers << { option_id: ans_opt.id, option: ans_opt.answer, votes: ans_opt.votes }
        end
        total_votes = poll.answer_options.pluck(:votes)
        @response << { id: poll.id, poll_question: poll.poll_question, days_left: days, status: 'Result', total_votes: total_votes.sum, options: answers }
      end
    end
  end
end
