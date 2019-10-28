class Api::V1::QuestionsController < ApplicationController

  def create
    message = validate()
    if message == 'true'
      answer_options = params[:answer_options].values
      if (params[:correct_option].to_i <= answer_options.length) && (params[:correct_option].to_i > 0)
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
          response[:question] = {question_id: questions.id, points: questions.points, correct_option: questions.correct_option, total_days: questions.total_days, options: answers}
          render json: response , status=> 200
        else
          render json: questions.errors.messages , :status => 400
        end
      else
        render json: {message: "Please provide valid value for correct option"}, :status => 401
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
      Question.where(is_active: true).each do |q|
        question_hash = []
        answer_options = []
        days = q.total_days.to_i - (((Time.now - q.created_at)/60)/1440).to_i
        if days == 0
          q.update(is_active: false)
        else
          q.answer_options.each_with_index do |ans_opt, index|
            answer_options << {option_no: index + 1 ,option: ans_opt.answer}
          end
          response << {question_id: q.id, question: q.question, days_left: days, points: q.points, options: answer_options}
        end
      end
      render json: response, status => 200
    else
      message = message.split("_")
      render json: {message: message[0]}, :status => message[1].to_i
    end
  end

  def check_answer
    message = validate()
    if message == 'true'
      question = Question.find_by_id(params[:question_id])
      if question.present? && params[:option_no].present?
        if question.correct_option == params[:option_no].to_i
          points = question.points.to_i + @user.points.to_i
          @user.update(points: points)
          render json: {message: "Congrates answer is correct!"} , status => 200
        else
          render json: {message: "Answer is not correct please try again!"}, :status => 404
        end
      else
        render json: {message: "Question not found or answer option is empty!"}, :status => 404
      end
    else
      message = message.split("_")
      render json: {message: message[0]}, :status => message[1].to_i
    end
  end

  def destroy
    message = validate()
    if message == 'true'
      question = Question.find_by_id(params[:id])
      if question.present?
        question.destroy
        render json: {message: "Question deleted successfully!"}, :status => 200
      else
        render json: {message: "Question Not found!"}, :status => 404
      end
    else
      message = message.split("_")
      render json: {message: message[0]}, :status => message[1].to_i
    end
  end

  private

  def validate
    @user = User.find_by_uuid(request.headers['X-SPUR-USER-ID'])
    if @user.present?
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