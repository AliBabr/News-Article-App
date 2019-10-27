class Api::V1::QuestionsController < ApplicationController

  def create
    message = validate()
    if message == 'true'
      answer_options = params[:answer_options].values
      if params[:correct_option].to_i <= answer_options.length
        questions = Question.new(question_params)
        if questions.save
          answer_options.each do |op|
            questions.answer_options.create(answer: op)
          end
          response = Hash.new{|h,k| h[k]=Hash.new(&h.default_proc) }
          answers = []
          questions.answer_options.each do |ans_opt|
            answers << {option: ans_opt.answer}
          end
          response[:question] = {id: questions.id, points: questions.points, correct_option: questions.correct_option, total_days: questions.total_days, options: answers}
          render json: response , status=> 200
        else
          render json: news.errors.messages , :status => 400
        end
      else
        render json: {message: "Please provide correct value for correct option"}, :status => 401
      end
    else
      message = message.split("_")
      render json: {message: message[0]}, :status => message[1].to_i
    end
  end

  def index
    message = validate()
    if message == 'true'
      response = []
      all_question = Question.all
      all_question.each do |q|
        question_hash = []
        answer_options = []
        q.answer_options.each do |ans_opt|
          answer_options << {option: ans_opt.answer}
        end
        response << {id: q.id, question: q.question, days_left: q.total_days, points: q.points, options: answer_options}
      end
      render json: response, status => 200
    else
      message = message.split("_")
      render json: {message: message[0]}, :status => message[1].to_i
    end
  end

  def update
    message = validate()
    if message == 'true'
      news = News.find_by_id(params[:id])
      if news.present?
        news.update(news_params)
        if news.errors.any?
          render json: news.errors.messages , :status => 400
        else
          image_url = ''
          if news.image.attached?
            image_url = url_for(news.image)
          end
          render json: {title: news.title, website_address: news.website_address, description: news.description, url: news.url, category: news.category, image: image_url }, :status => 200
        end
      else
        render json: {message: "News Not found!"}, :status => 404
      end
    else
      message = message.split("_")
      render json: {message: message[0]}, :status => message[1].to_i
    end
  end

  def destroy
    message = validate()
    if message == 'true'
      news = News.find_by_id(params[:id])
      if news.present?
        news.destroy
        render json: {message: "News deleted successfully!"}, :status => 200
      else
        render json: {message: "News Not found!"}, :status => 404
      end
    else
      message = message.split("_")
      render json: {message: message[0]}, :status => message[1].to_i
    end
  end

  private

  def validate
    user = User.find_by_uuid(request.headers['X-SPUR-USER-ID'])
    if user.present?
      if User.validate_token(request.headers['X-SPUR-USER-ID'],request.headers['Authentication-Token'])
        return "true"
      else
        return "Unauthorized" + "_" + "401"
      end
    else
      return "User Not Found!" + "_" + "404"
    end
  end

  def question_params
    params.permit(:question, :points, :correct_option, :total_days)
  end

  def answer_option_params
    params.permit(:answer)
  end

end