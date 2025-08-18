class QaReport < ApplicationRecord
  # Associations
  belongs_to :quiz
  belongs_to :user

  # Validations
  validates :quiz_id, presence: true
  validates :user_id, presence: true
  validates :score, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  validates :total_questions, presence: true, numericality: { greater_than: 0 }
  validates :correct_answers, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :completed_at, presence: true
  validates :time_taken, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  # Custom validation for correct_answers <= total_questions
  validate :correct_answers_cannot_exceed_total_questions

  # Scopes
  scope :by_quiz, ->(quiz_id) { where(quiz_id: quiz_id) }
  scope :by_user, ->(user_id) { where(user_id: user_id) }
  scope :recent, -> { order(completed_at: :desc) }
  scope :in_date_range, ->(start_date, end_date) { where(completed_at: start_date..end_date) }
  scope :high_performers, -> { where("score >= ?", 80) }
  scope :low_performers, -> { where("score < ?", 60) }
  scope :completed_today, -> { where("DATE(completed_at) = ?", Date.current) }
  scope :completed_this_week, -> { where(completed_at: Date.current.beginning_of_week..Date.current.end_of_week) }
  scope :completed_this_month, -> { where(completed_at: Date.current.beginning_of_month..Date.current.end_of_month) }

  # Score calculation methods
  def percentage
    return 0.0 if total_questions.nil? || total_questions == 0
    (correct_answers.to_f / total_questions.to_f * 100).round(1)
  end

  def grade_letter
    return "F" if score.nil?
    
    case score
    when 90..100
      "A"
    when 80..89
      "B"
    when 70..79
      "C"
    when 60..69
      "D"
    else
      "F"
    end
  end

  # Time formatting helpers
  def human_readable_time
    return "N/A" if time_taken.nil?
    
    hours = time_taken / 3600
    minutes = (time_taken % 3600) / 60
    seconds = time_taken % 60
    
    if hours > 0
      "#{hours}h #{minutes}m #{seconds}s"
    elsif minutes > 0
      "#{minutes}m #{seconds}s"
    else
      "#{seconds}s"
    end
  end

  def average_time_per_question
    return 0 if total_questions.nil? || total_questions == 0 || time_taken.nil?
    (time_taken.to_f / total_questions).round(1)
  end

  # Analytics methods
  def passed?
    score >= 60
  end

  def perfect_score?
    score == 100
  end

  def completion_rate
    return 0.0 if total_questions.nil? || total_questions == 0
    ((correct_answers.to_f / total_questions.to_f) * 100).round(2)
  end

  private

  def correct_answers_cannot_exceed_total_questions
    if correct_answers.present? && total_questions.present? && correct_answers > total_questions
      errors.add(:correct_answers, "can't be greater than total questions")
    end
  end
end