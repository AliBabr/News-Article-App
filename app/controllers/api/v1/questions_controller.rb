# frozen_string_literal: true

class Api::V1::QuestionsController < ApplicationController
  before_action :authenticate # call back for validating user
  before_action :set_question, only: %i[check_answer destroy]
  before_action :is_admin, only: %i[create update destroy]

  #Methode to create question and its answer options
  def create
    answer_options = params[:answer_options].values
    if (params[:correct_option].to_i <= answer_options.length) && (params[:correct_option].to_i > 0)
      questions = Question.new(question_params)
      if questions.save
        for_create_question(questions, answer_options)
      else
        render json: @questions.errors.messages, status: 400
      end
    else
      render json: { message: 'Please provide valid value for correct option' }, status: 401
    end
  rescue StandardError => e # rescu if any exception occure
    render json: { message: 'Error: Something went wrong please check params... ' }, status: :bad_request
  end

  #Methode to get all questions and its answers
  def index
    @response = []
    get_questions
    render json: @response, status => 200
  rescue StandardError => e # rescu if any exception occure
    render json: { message: 'Error: Something went wrong... ' }, status: :bad_request
  end

  #Methode to check if answer is correct or not
  def check_answer
    if params[:option_no].present?
      if @question.correct_option == params[:option_no].to_i
        points = @question.points.to_i + @user.points.to_i; @user.update(points: points)
        render json: { message: 'Congrates answer is correct!' }, status => 200
      else
        render json: { message: 'Answer is not correct please try again!' }, status: 404
      end
    else
      render json: { message: 'Answer option is empty!' }, status: 404
    end
  rescue StandardError => e # rescu if any exception occure
    render json: { message: 'Error: Something went wrong... ' }, status: :bad_request
  end

  #Methode to delete question
  def destroy
    @question.destroy
    render json: { message: 'Question deleted successfully!' }, status: 200
  rescue StandardError => e # rescu if any exception occure
    render json: { message: 'Error: Something went wrong... ' }, status: :bad_request
  end

  private

  def question_params #permit question parametrs
    params.permit(:question, :points, :correct_option, :total_days, :question_type)
  end

  def answer_option_params #permit answer option parameters
    params.permit(:answer)
  end

  def set_question #set instance of question
    @question = Question.find_by_id(params[:id])
    if @question.present?
      return true
    else
      render json: { message: 'Question Not found!' }, status: 404
    end
  end

  #Helper methode  for creating questiona and its answer options
  def for_create_question(questions, answer_options)
    answer_options.each do |op|
      questions.answer_options.create(answer: op)
    end
    response = Hash.new { |h, k| h[k] = Hash.new(&h.default_proc) }; answers = []
    questions.answer_options.each do |ans_opt|
      answers << { option: ans_opt.answer }
    end
    response[:question] = { question_id: questions.id, question: questions.question, points: questions.points, correct_option: questions.correct_option, total_days: questions.total_days, options: answers }
    render json: response, status => 200
  end

  def is_admin
    if @user.role == 'admin'
      return true
    else
      render json: { message: "Only admin can create/update/destroy questions!"}
    end
  end

  def get_questions #Helper methode for making response for get question request
    Question.where(question_type: "DAILY").each do |q|
      answer_options = []
      q.answer_options.each_with_index do |ans_opt, index|
        answer_options << { option_no: index + 1, option: ans_opt.answer }
      end
      @response << { question_id: q.id, question: q.question, points: q.points, question_type: q.question_type, options: answer_options }
    end
    Question.where(is_active: true, question_type: 'TRIVIA').each do |q|
      answer_options = []
      days = q.total_days.to_i - (((Time.now - q.created_at) / 60) / 1440).to_i
      if days == 0
        q.update(is_active: false)
      else
        q.answer_options.each_with_index do |ans_opt, index|
          answer_options << { option_no: index + 1, option: ans_opt.answer }
        end
        @response << { question_id: q.id, question: q.question, question_type: q.question_type, days_left: days, points: q.points, options: answer_options }
      end
    end
  end

end
