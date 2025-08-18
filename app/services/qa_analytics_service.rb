class QaAnalyticsService
  def generate_quiz_summary(quiz_id)
    reports = QaReport.where(quiz_id: quiz_id)
    
    {
      total_attempts: reports.count,
      unique_users: reports.distinct.count(:user_id),
      average_score: reports.average(:score)&.round(1) || 0,
      completion_rate: calculate_completion_rate(reports),
      average_time_seconds: reports.average(:time_taken)&.to_i || 0,
      score_distribution: calculate_score_distribution(reports),
      recent_attempts: reports.recent.limit(10).includes(:user)
    }
  end

  def calculate_user_performance(user_id)
    reports = QaReport.where(user_id: user_id)
    recent_reports = reports.recent.limit(10)
    
    {
      total_quizzes: reports.count,
      average_score: reports.average(:score)&.round(1) || 0,
      perfect_scores: reports.where(score: 100).count,
      average_time: reports.average(:time_taken)&.to_i || 0,
      recent_scores: recent_reports.pluck(:score),
      improvement_trend: calculate_improvement_trend(recent_reports),
      strengths: identify_user_strengths(reports),
      weaknesses: identify_user_weaknesses(reports)
    }
  end

  def get_trending_questions(quiz_id)
    quiz = Quiz.find_by(id: quiz_id)
    return empty_trending_response unless quiz
    
    analytics = QuestionAnalytics.where(quiz_id: quiz_id)
    
    {
      total_questions: quiz.questions.count,
      most_difficult: format_question_analytics(
        analytics.where("difficulty_score > ?", 0.5).order(difficulty_score: :desc).limit(5)
      ),
      easiest: format_question_analytics(
        analytics.where("difficulty_score < ?", 0.3).order(:difficulty_score).limit(5)
      ),
      most_skipped: format_question_analytics(
        analytics.order(times_skipped: :desc).limit(5)
      ),
      least_attempted: format_question_analytics(
        analytics.order(:times_answered).limit(5)
      )
    }
  end

  def generate_time_based_metrics(quiz_id, period = "daily", count = 7)
    validate_period!(period)
    
    case period
    when "daily"
      generate_daily_metrics(quiz_id, count)
    when "weekly"
      generate_weekly_metrics(quiz_id, count)
    when "monthly"
      generate_monthly_metrics(quiz_id, count)
    end
  end

  def update_daily_metrics(quiz_id, date = Date.current)
    QuizMetricsDaily.generate_for_quiz_and_date(quiz_id, date)
  end

  def update_user_daily_metrics(user_id, date = Date.current)
    UserMetricsDaily.generate_for_user_and_date(user_id, date)
  end

  def get_category_performance(category)
    quizzes = Quiz.where(category: category)
    reports = QaReport.where(quiz_id: quizzes.pluck(:id))
    
    {
      category: category,
      total_quizzes: quizzes.count,
      total_attempts: reports.count,
      unique_users: reports.distinct.count(:user_id),
      average_score: reports.average(:score)&.round(1) || 0,
      completion_rate: calculate_completion_rate(reports),
      popular_quizzes: get_popular_quizzes_in_category(quizzes)
    }
  end

  def get_difficulty_analysis(quiz_id)
    quiz = Quiz.find(quiz_id)
    reports = quiz.qa_reports
    
    {
      difficulty_level: quiz.difficulty_level || 0,
      difficulty_label: quiz.difficulty_label,
      average_score: reports.average(:score)&.round(1) || 0,
      completion_rate: calculate_completion_rate(reports),
      score_by_user_level: analyze_score_by_user_level(reports),
      time_analysis: analyze_time_by_difficulty(reports)
    }
  end

  def generate_dashboard_summary(entity_type = nil, entity_id = nil)
    cache_key = build_cache_key(entity_type, entity_id)
    
    DashboardCache.fetch(cache_key, cache_type: "dashboard_summary", expires_in: 5.minutes) do
      if entity_type == "quiz" && entity_id
        generate_quiz_dashboard(entity_id)
      elsif entity_type == "user" && entity_id
        generate_user_dashboard(entity_id)
      else
        generate_system_dashboard
      end
    end
  end

  def refresh_all_metrics(date = Date.current)
    # Update all quiz metrics for the date
    Quiz.find_each do |quiz|
      update_daily_metrics(quiz.id, date)
    end
    
    # Update all user metrics for the date
    User.find_each do |user|
      update_user_daily_metrics(user.id, date)
    end
    
    # Clear expired cache
    DashboardCache.clear_expired!
    
    true
  end

  private

  def calculate_completion_rate(reports)
    return 0 if reports.count == 0
    completed = reports.where.not(completed_at: nil).count
    (completed.to_f / reports.count * 100).round(1)
  end

  def calculate_score_distribution(reports)
    return {} if reports.empty?
    
    {
      "0-59" => reports.where(score: 0..59).count,
      "60-69" => reports.where(score: 60..69).count,
      "70-79" => reports.where(score: 70..79).count,
      "80-89" => reports.where(score: 80..89).count,
      "90-100" => reports.where(score: 90..100).count
    }
  end

  def calculate_improvement_trend(recent_reports)
    scores = recent_reports.pluck(:score)
    return "stable" if scores.length < 2
    
    first_half = scores[0...(scores.length/2)]
    second_half = scores[(scores.length/2)..-1]
    
    first_avg = first_half.sum.to_f / first_half.length
    second_avg = second_half.sum.to_f / second_half.length
    
    if second_avg > first_avg + 5
      "improving"
    elsif second_avg < first_avg - 5
      "declining"
    else
      "stable"
    end
  end

  def identify_user_strengths(reports)
    reports.joins(:quiz)
           .group("quizzes.category")
           .having("AVG(qa_reports.score) >= ?", 80)
           .pluck("quizzes.category")
  end

  def identify_user_weaknesses(reports)
    reports.joins(:quiz)
           .group("quizzes.category")
           .having("AVG(qa_reports.score) < ?", 60)
           .pluck("quizzes.category")
  end

  def format_question_analytics(analytics)
    analytics.map do |qa|
      {
        question_id: qa.question_id,
        success_rate: qa.success_rate,
        skip_rate: qa.skip_rate,
        difficulty_score: qa.difficulty_score,
        times_shown: qa.times_shown,
        avg_time: qa.formatted_avg_time
      }
    end
  end

  def empty_trending_response
    {
      total_questions: 0,
      most_difficult: [],
      easiest: [],
      most_skipped: [],
      least_attempted: []
    }
  end

  def validate_period!(period)
    valid_periods = %w[daily weekly monthly]
    unless valid_periods.include?(period)
      raise ArgumentError, "Invalid period. Must be one of: #{valid_periods.join(', ')}"
    end
  end

  def generate_daily_metrics(quiz_id, count)
    end_date = Date.current
    start_date = end_date - (count - 1).days
    
    (start_date..end_date).map do |date|
      reports = QaReport.where(quiz_id: quiz_id)
                       .where("DATE(completed_at) = ?", date)
      
      {
        date: date,
        attempts: reports.count,
        unique_users: reports.distinct.count(:user_id),
        average_score: reports.average(:score)&.round(1) || 0,
        completion_rate: calculate_completion_rate(reports)
      }
    end
  end

  def generate_weekly_metrics(quiz_id, count)
    (0...count).map do |weeks_ago|
      week_start = weeks_ago.weeks.ago.beginning_of_week.to_date
      week_end = week_start + 6.days
      
      reports = QaReport.where(quiz_id: quiz_id)
                       .where(completed_at: week_start.beginning_of_day..week_end.end_of_day)
      
      {
        week_start: week_start,
        week_end: week_end,
        attempts: reports.count,
        unique_users: reports.distinct.count(:user_id),
        average_score: reports.average(:score)&.round(1) || 0,
        completion_rate: calculate_completion_rate(reports)
      }
    end
  end

  def generate_monthly_metrics(quiz_id, count)
    (0...count).map do |months_ago|
      month_start = months_ago.months.ago.beginning_of_month.to_date
      month_end = month_start.end_of_month
      
      reports = QaReport.where(quiz_id: quiz_id)
                       .where(completed_at: month_start.beginning_of_day..month_end.end_of_day)
      
      {
        month_start: month_start,
        month_end: month_end,
        month_name: month_start.strftime("%B %Y"),
        attempts: reports.count,
        unique_users: reports.distinct.count(:user_id),
        average_score: reports.average(:score)&.round(1) || 0,
        completion_rate: calculate_completion_rate(reports)
      }
    end
  end

  def get_popular_quizzes_in_category(quizzes)
    quizzes.joins(:qa_reports)
           .group("quizzes.id", "quizzes.title")
           .order("COUNT(qa_reports.id) DESC")
           .limit(5)
           .pluck("quizzes.title", "COUNT(qa_reports.id)")
           .map { |title, count| { title: title, attempts: count } }
  end

  def analyze_score_by_user_level(reports)
    {
      new_users: analyze_score_for_user_group(reports, "new"),
      regular_users: analyze_score_for_user_group(reports, "regular"),
      experienced_users: analyze_score_for_user_group(reports, "experienced")
    }
  end

  def analyze_score_for_user_group(reports, group)
    # Simplified logic - in real app would have user experience levels
    case group
    when "new"
      reports.joins(:user).merge(User.where("users.created_at > ?", 30.days.ago))
    when "regular"
      reports.joins(:user).merge(User.where("users.created_at" => 90.days.ago..30.days.ago))
    when "experienced"
      reports.joins(:user).merge(User.where("users.created_at < ?", 90.days.ago))
    else
      reports
    end.average(:score)&.round(1) || 0
  end

  def analyze_time_by_difficulty(reports)
    {
      average_time: reports.average(:time_taken)&.to_i || 0,
      median_time: calculate_median_time(reports),
      time_distribution: calculate_time_distribution(reports)
    }
  end

  def calculate_median_time(reports)
    times = reports.pluck(:time_taken).compact.sort
    return 0 if times.empty?
    
    mid = times.length / 2
    times.length.odd? ? times[mid] : (times[mid - 1] + times[mid]) / 2
  end

  def calculate_time_distribution(reports)
    return {} if reports.empty?
    
    {
      "< 1 min" => reports.where(time_taken: 0...60).count,
      "1-3 min" => reports.where(time_taken: 60...180).count,
      "3-5 min" => reports.where(time_taken: 180...300).count,
      "5-10 min" => reports.where(time_taken: 300...600).count,
      "> 10 min" => reports.where("time_taken >= ?", 600).count
    }
  end

  def build_cache_key(entity_type, entity_id)
    if entity_type && entity_id
      "dashboard_#{entity_type}_#{entity_id}"
    else
      "dashboard_system"
    end
  end

  def generate_quiz_dashboard(quiz_id)
    quiz = Quiz.find(quiz_id)
    
    {
      quiz_summary: generate_quiz_summary(quiz_id),
      trending_questions: get_trending_questions(quiz_id),
      recent_metrics: generate_time_based_metrics(quiz_id, "daily", 7),
      difficulty_analysis: get_difficulty_analysis(quiz_id)
    }
  end

  def generate_user_dashboard(user_id)
    user = User.find(user_id)
    
    {
      user_performance: calculate_user_performance(user_id),
      recent_activity: get_user_recent_activity(user_id),
      achievement_progress: calculate_achievement_progress(user_id),
      recommended_quizzes: get_recommended_quizzes(user_id)
    }
  end

  def generate_system_dashboard
    {
      total_users: User.count,
      total_quizzes: Quiz.count,
      total_attempts: QaReport.count,
      active_users_today: QaReport.completed_today.distinct.count(:user_id),
      popular_quizzes: Quiz.most_popular.limit(10),
      recent_activity: QaReport.recent.limit(20).includes(:user, :quiz)
    }
  end

  def get_user_recent_activity(user_id)
    QaReport.where(user_id: user_id)
            .recent
            .limit(10)
            .includes(:quiz)
  end

  def calculate_achievement_progress(user_id)
    reports = QaReport.where(user_id: user_id)
    
    {
      total_quizzes_completed: reports.count,
      perfect_scores: reports.where(score: 100).count,
      current_streak: calculate_streak(reports),
      badges_earned: calculate_badges(reports)
    }
  end

  def calculate_streak(reports)
    # Simplified streak calculation
    recent = reports.recent.limit(7).pluck(:completed_at)
    return 0 if recent.empty?
    
    streak = 1
    recent.each_cons(2) do |newer, older|
      if (newer.to_date - older.to_date).to_i == 1
        streak += 1
      else
        break
      end
    end
    streak
  end

  def calculate_badges(reports)
    badges = []
    badges << "First Timer" if reports.count >= 1
    badges << "Regular" if reports.count >= 10
    badges << "Expert" if reports.count >= 50
    badges << "Perfectionist" if reports.where(score: 100).count >= 5
    badges
  end

  def get_recommended_quizzes(user_id)
    # Get quizzes the user hasn't attempted yet
    attempted_quiz_ids = QaReport.where(user_id: user_id).pluck(:quiz_id).uniq
    Quiz.active
        .where.not(id: attempted_quiz_ids)
        .limit(5)
  end
end