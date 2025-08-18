class QuestionAnalytics < ApplicationRecord
  # Note: Using singular form as Rails convention even though table name is plural
  self.table_name = "question_analytics"

  # Associations
  belongs_to :question
  belongs_to :quiz

  # Validations
  validates :question_id, presence: true
  validates :quiz_id, presence: true
  validates :question_id, uniqueness: { scope: :quiz_id }
  validates :times_shown, numericality: { greater_than_or_equal_to: 0 }
  validates :times_answered, numericality: { greater_than_or_equal_to: 0 }
  validates :times_correct, numericality: { greater_than_or_equal_to: 0 }
  validates :times_skipped, numericality: { greater_than_or_equal_to: 0 }

  # Custom validations
  validate :answered_cannot_exceed_shown
  validate :correct_cannot_exceed_answered
  validate :skipped_cannot_exceed_shown

  # Scopes
  scope :by_difficulty, -> { order(difficulty_score: :desc) }
  scope :most_difficult, -> { where("difficulty_score > ?", 0.7) }
  scope :easiest, -> { where("difficulty_score < ?", 0.3) }
  scope :most_skipped, -> { order(times_skipped: :desc) }
  scope :recently_updated, -> { order(last_updated: :desc) }
  scope :for_quiz, ->(quiz_id) { where(quiz_id: quiz_id) }

  # Callbacks
  before_save :calculate_difficulty_score
  before_save :set_last_updated

  # Instance methods
  def success_rate
    return 0 if times_answered == 0
    (times_correct.to_f / times_answered * 100).round(1)
  end

  def skip_rate
    return 0 if times_shown == 0
    (times_skipped.to_f / times_shown * 100).round(1)
  end

  def answer_rate
    return 0 if times_shown == 0
    (times_answered.to_f / times_shown * 100).round(1)
  end

  def formatted_avg_time
    return "N/A" if avg_time_seconds.nil?
    
    if avg_time_seconds < 60
      "#{avg_time_seconds.round}s"
    else
      minutes = (avg_time_seconds / 60).to_i
      seconds = (avg_time_seconds % 60).to_i
      "#{minutes}m #{seconds}s"
    end
  end

  # Class method to update analytics for a question
  def self.update_for_answer(question_id, quiz_id, is_correct, time_taken = nil)
    analytics = find_or_initialize_by(question_id: question_id, quiz_id: quiz_id)
    
    analytics.times_shown ||= 0
    analytics.times_answered ||= 0
    analytics.times_correct ||= 0
    analytics.times_shown += 1
    analytics.times_answered += 1
    analytics.times_correct += 1 if is_correct
    
    # Update average time
    if time_taken
      current_total_time = (analytics.avg_time_seconds || 0) * (analytics.times_answered - 1)
      analytics.avg_time_seconds = (current_total_time + time_taken) / analytics.times_answered
    end
    
    analytics.save!
    analytics
  end

  def self.update_for_skip(question_id, quiz_id)
    analytics = find_or_initialize_by(question_id: question_id, quiz_id: quiz_id)
    
    analytics.times_shown ||= 0
    analytics.times_skipped ||= 0
    analytics.times_shown += 1
    analytics.times_skipped += 1
    
    analytics.save!
    analytics
  end

  private

  def calculate_difficulty_score
    return if times_answered == 0
    
    # Difficulty is inverse of success rate (0 = easy, 1 = hard)
    self.difficulty_score = 1 - (times_correct.to_f / times_answered)
  end

  def set_last_updated
    self.last_updated = Time.current
  end

  def answered_cannot_exceed_shown
    if times_answered.present? && times_shown.present? && times_answered > times_shown
      errors.add(:times_answered, "can't be greater than times shown")
    end
  end

  def correct_cannot_exceed_answered
    if times_correct.present? && times_answered.present? && times_correct > times_answered
      errors.add(:times_correct, "can't be greater than times answered")
    end
  end

  def skipped_cannot_exceed_shown
    if times_skipped.present? && times_shown.present? && times_skipped > times_shown
      errors.add(:times_skipped, "can't be greater than times shown")
    end
  end
end