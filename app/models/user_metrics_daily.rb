class UserMetricsDaily < ApplicationRecord
  # Associations
  belongs_to :user

  # Validations
  validates :user_id, presence: true
  validates :metric_date, presence: true
  validates :metric_date, uniqueness: { scope: :user_id }
  validates :quizzes_taken, numericality: { greater_than_or_equal_to: 0 }
  validates :quizzes_completed, numericality: { greater_than_or_equal_to: 0 }
  validates :perfect_scores, numericality: { greater_than_or_equal_to: 0 }
  validates :questions_answered, numericality: { greater_than_or_equal_to: 0 }
  validates :correct_answers, numericality: { greater_than_or_equal_to: 0 }
  validates :total_time_seconds, numericality: { greater_than_or_equal_to: 0 }

  # Custom validation
  validate :completed_cannot_exceed_taken
  validate :correct_cannot_exceed_answered

  # Scopes
  scope :for_date, ->(date) { where(metric_date: date) }
  scope :in_date_range, ->(start_date, end_date) { where(metric_date: start_date..end_date) }
  scope :recent, -> { order(metric_date: :desc) }
  scope :for_user, ->(user_id) { where(user_id: user_id) }
  scope :current_week, -> { where(metric_date: Date.current.beginning_of_week..Date.current.end_of_week) }
  scope :current_month, -> { where(metric_date: Date.current.beginning_of_month..Date.current.end_of_month) }

  # Class methods for aggregation
  def self.generate_for_user_and_date(user_id, date)
    reports = QaReport.where(user_id: user_id)
                      .where("DATE(completed_at) = ?", date)

    metrics = find_or_initialize_by(user_id: user_id, metric_date: date)

    metrics.update!(
      quizzes_taken: reports.count,
      quizzes_completed: reports.where.not(completed_at: nil).count,
      avg_score: reports.average(:score)&.round(1),
      total_time_seconds: reports.sum(:time_taken),
      perfect_scores: reports.where(score: 100).count,
      questions_answered: reports.sum(:total_questions),
      correct_answers: reports.sum(:correct_answers)
    )

    metrics
  end

  # Instance methods
  def completion_rate
    return 0 if quizzes_taken == 0
    (quizzes_completed.to_f / quizzes_taken * 100).round(1)
  end

  def accuracy_rate
    return 0 if questions_answered == 0
    (correct_answers.to_f / questions_answered * 100).round(1)
  end

  def perfect_score_rate
    return 0 if quizzes_completed == 0
    (perfect_scores.to_f / quizzes_completed * 100).round(1)
  end

  def average_time_per_quiz
    return 0 if quizzes_completed == 0
    (total_time_seconds.to_f / quizzes_completed).round
  end

  def formatted_total_time
    return "0m" if total_time_seconds == 0
    
    hours = total_time_seconds / 3600
    minutes = (total_time_seconds % 3600) / 60
    
    if hours > 0
      "#{hours}h #{minutes}m"
    else
      "#{minutes}m"
    end
  end

  private

  def completed_cannot_exceed_taken
    if quizzes_completed.present? && quizzes_taken.present? && quizzes_completed > quizzes_taken
      errors.add(:quizzes_completed, "can't be greater than quizzes taken")
    end
  end

  def correct_cannot_exceed_answered
    if correct_answers.present? && questions_answered.present? && correct_answers > questions_answered
      errors.add(:correct_answers, "can't be greater than questions answered")
    end
  end
end