require "test_helper"

class QaAnalyticsServiceTest < ActiveSupport::TestCase
  fixtures :users, :quizzes

  setup do
    @quiz = quizzes(:quiz_one)
    @user = users(:user_one)
    @service = QaAnalyticsService.new
    
    # Create some test data
    create_sample_qa_reports
  end

  test "generate_quiz_summary should return quiz statistics" do
    summary = @service.generate_quiz_summary(@quiz.id)
    
    assert_not_nil summary
    assert_equal 5, summary[:total_attempts]
    assert_equal 3, summary[:unique_users]
    assert_equal 80.0, summary[:average_score]
    assert_equal 100.0, summary[:completion_rate]
    assert_equal 240, summary[:average_time_seconds]
  end

  test "generate_quiz_summary should handle quiz with no reports" do
    empty_quiz = quizzes(:quiz_three)
    summary = @service.generate_quiz_summary(empty_quiz.id)
    
    assert_not_nil summary
    assert_equal 0, summary[:total_attempts]
    assert_equal 0, summary[:unique_users]
    assert_equal 0, summary[:average_score]
    assert_equal 0, summary[:completion_rate]
    assert_equal 0, summary[:average_time_seconds]
  end

  test "calculate_user_performance should return user statistics" do
    performance = @service.calculate_user_performance(@user.id)
    
    assert_not_nil performance
    assert_equal 3, performance[:total_quizzes]
    assert_equal 80.0, performance[:average_score]
    assert_equal 1, performance[:perfect_scores]
    assert_equal 250, performance[:average_time]
    assert_includes performance[:recent_scores], 100
    assert_includes performance[:recent_scores], 80
  end

  test "calculate_user_performance should handle user with no reports" do
    new_user = User.create!(name: "New User", email: "new@example.com")
    performance = @service.calculate_user_performance(new_user.id)
    
    assert_not_nil performance
    assert_equal 0, performance[:total_quizzes]
    assert_equal 0, performance[:average_score]
    assert_equal 0, performance[:perfect_scores]
    assert_equal 0, performance[:average_time]
    assert_empty performance[:recent_scores]
  end

  test "get_trending_questions should return question statistics" do
    # Create questions and analytics
    question1 = Question.create!(quiz: @quiz, content: "Q1", points: 1)
    question2 = Question.create!(quiz: @quiz, content: "Q2", points: 2)
    
    QuestionAnalytics.create!(
      question: question1,
      quiz: @quiz,
      times_shown: 100,
      times_answered: 90,
      times_correct: 45,
      times_skipped: 10,
      difficulty_score: 0.5
    )
    
    QuestionAnalytics.create!(
      question: question2,
      quiz: @quiz,
      times_shown: 100,
      times_answered: 85,
      times_correct: 70,
      times_skipped: 15,
      difficulty_score: 0.2
    )
    
    trending = @service.get_trending_questions(@quiz.id)
    
    assert_not_nil trending
    assert_equal 2, trending[:total_questions]
    assert_not_empty trending[:most_difficult]
    assert_not_empty trending[:easiest]
    assert_not_empty trending[:most_skipped]
    
    # Check most difficult question
    assert_equal question1.id, trending[:most_difficult].first[:question_id]
    assert_equal 50.0, trending[:most_difficult].first[:success_rate]
    
    # Check easiest question
    assert_equal question2.id, trending[:easiest].first[:question_id]
  end

  test "get_trending_questions should handle quiz with no questions" do
    empty_quiz = quizzes(:quiz_three)
    trending = @service.get_trending_questions(empty_quiz.id)
    
    assert_not_nil trending
    assert_equal 0, trending[:total_questions]
    assert_empty trending[:most_difficult]
    assert_empty trending[:easiest]
    assert_empty trending[:most_skipped]
  end

  test "generate_time_based_metrics should return daily metrics" do
    metrics = @service.generate_time_based_metrics(@quiz.id, "daily", 7)
    
    assert_not_nil metrics
    assert_kind_of Array, metrics
    assert_equal 7, metrics.length
    
    today_metrics = metrics.find { |m| m[:date] == Date.current }
    assert_not_nil today_metrics
    assert_equal 5, today_metrics[:attempts]
    assert_equal 80.0, today_metrics[:average_score]
  end

  test "generate_time_based_metrics should support weekly aggregation" do
    metrics = @service.generate_time_based_metrics(@quiz.id, "weekly", 4)
    
    assert_not_nil metrics
    assert_kind_of Array, metrics
    assert_equal 4, metrics.length
    
    this_week_metrics = metrics.first
    assert_not_nil this_week_metrics
    assert_equal Date.current.beginning_of_week, this_week_metrics[:week_start]
  end

  test "generate_time_based_metrics should support monthly aggregation" do
    metrics = @service.generate_time_based_metrics(@quiz.id, "monthly", 3)
    
    assert_not_nil metrics
    assert_kind_of Array, metrics
    assert_equal 3, metrics.length
    
    this_month_metrics = metrics.first
    assert_not_nil this_month_metrics
    assert_equal Date.current.beginning_of_month.to_date, this_month_metrics[:month_start]
  end

  test "generate_time_based_metrics should handle invalid period" do
    assert_raises(ArgumentError) do
      @service.generate_time_based_metrics(@quiz.id, "invalid", 7)
    end
  end

  test "update_daily_metrics should create or update quiz metrics" do
    date = Date.current
    @service.update_daily_metrics(@quiz.id, date)
    
    metrics = QuizMetricsDaily.find_by(quiz_id: @quiz.id, metric_date: date)
    assert_not_nil metrics
    assert_equal 5, metrics.total_attempts
    assert_equal 3, metrics.unique_users
    assert_equal 80.0, metrics.avg_score
  end

  test "update_daily_metrics should create or update user metrics" do
    date = Date.current
    @service.update_user_daily_metrics(@user.id, date)
    
    metrics = UserMetricsDaily.find_by(user_id: @user.id, metric_date: date)
    assert_not_nil metrics
    assert_equal 3, metrics.quizzes_taken
    assert_equal 3, metrics.quizzes_completed
    assert_equal 80.0, metrics.avg_score
  end

  test "get_category_performance should return category statistics" do
    performance = @service.get_category_performance("General")
    
    assert_not_nil performance
    assert_equal "General", performance[:category]
    assert_equal 1, performance[:total_quizzes]
    assert_equal 5, performance[:total_attempts]
    assert_equal 80.0, performance[:average_score]
  end

  test "get_difficulty_analysis should return difficulty breakdown" do
    analysis = @service.get_difficulty_analysis(@quiz.id)
    
    assert_not_nil analysis
    assert_equal 2, analysis[:difficulty_level]
    assert_equal "Easy", analysis[:difficulty_label]
    assert_equal 80.0, analysis[:average_score]
    assert_equal 100.0, analysis[:completion_rate]
  end

  private

  def create_sample_qa_reports
    # Create diverse test data
    users_list = [users(:user_one), users(:user_two), users(:admin_user)]
    
    # User one takes quiz one 3 times
    QaReport.create!(
      quiz: @quiz,
      user: @user,
      score: 100,
      total_questions: 10,
      correct_answers: 10,
      time_taken: 200,
      completed_at: Time.current
    )
    
    QaReport.create!(
      quiz: @quiz,
      user: @user,
      score: 80,
      total_questions: 10,
      correct_answers: 8,
      time_taken: 250,
      completed_at: 1.day.ago
    )
    
    QaReport.create!(
      quiz: @quiz,
      user: @user,
      score: 60,
      total_questions: 10,
      correct_answers: 6,
      time_taken: 300,
      completed_at: 2.days.ago
    )
    
    # User two takes quiz one
    QaReport.create!(
      quiz: @quiz,
      user: users(:user_two),
      score: 85,
      total_questions: 10,
      correct_answers: 8,
      time_taken: 220,
      completed_at: Time.current
    )
    
    # Admin takes quiz one
    QaReport.create!(
      quiz: @quiz,
      user: users(:admin_user),
      score: 75,
      total_questions: 10,
      correct_answers: 7,
      time_taken: 260,
      completed_at: Time.current
    )
  end
end