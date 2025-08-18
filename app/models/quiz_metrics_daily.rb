class QuizMetricsDaily < ApplicationRecord
  # Associations
  belongs_to :quiz

  # Validations
  validates :quiz_id, presence: true
  validates :metric_date, presence: true
  validates :metric_date, uniqueness: { scope: :quiz_id }
  validates :total_attempts, numericality: { greater_than_or_equal_to: 0 }
  validates :unique_users, numericality: { greater_than_or_equal_to: 0 }
  validates :completions, numericality: { greater_than_or_equal_to: 0 }
  validates :perfect_scores, numericality: { greater_than_or_equal_to: 0 }
  validates :failures, numericality: { greater_than_or_equal_to: 0 }

  # Scopes
  scope :for_date, ->(date) { where(metric_date: date) }
  scope :in_date_range, ->(start_date, end_date) { where(metric_date: start_date..end_date) }
  scope :recent, -> { order(metric_date: :desc) }
  scope :for_quiz, ->(quiz_id) { where(quiz_id: quiz_id) }
  scope :current_week, -> { where(metric_date: Date.current.beginning_of_week..Date.current.end_of_week) }
  scope :current_month, -> { where(metric_date: Date.current.beginning_of_month..Date.current.end_of_month) }

  # Class methods for aggregation
  def self.generate_for_quiz_and_date(quiz_id, date)
    reports = QaReport.where(quiz_id: quiz_id)
                      .where("DATE(completed_at) = ?", date)

    metrics = find_or_initialize_by(quiz_id: quiz_id, metric_date: date)

    metrics.update!(
      total_attempts: reports.count,
      unique_users: reports.distinct.count(:user_id),
      completions: reports.where.not(completed_at: nil).count,
      avg_score: reports.average(:score)&.round(1),
      avg_time_seconds: reports.average(:time_taken)&.round,
      perfect_scores: reports.where(score: 100).count,
      failures: reports.where("score < ?", 60).count
    )

    metrics
  end

  # Instance methods
  def completion_rate
    return 0 if total_attempts == 0
    (completions.to_f / total_attempts * 100).round(1)
  end

  def success_rate
    return 0 if completions == 0
    ((completions - failures).to_f / completions * 100).round(1)
  end

  def perfect_score_rate
    return 0 if completions == 0
    (perfect_scores.to_f / completions * 100).round(1)
  end

  def formatted_avg_time
    return "N/A" if avg_time_seconds.nil?
    
    minutes = avg_time_seconds / 60
    seconds = avg_time_seconds % 60
    
    if minutes > 0
      "#{minutes.to_i}m #{seconds.to_i}s"
    else
      "#{seconds.to_i}s"
    end
  end
end