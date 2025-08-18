class Question < ApplicationRecord
  # Associations
  belongs_to :quiz
  has_many :question_analytics, class_name: "QuestionAnalytics", dependent: :destroy

  # Validations
  validates :content, presence: true
  validates :quiz_id, presence: true
  validates :points, numericality: { greater_than_or_equal_to: 0 }

  # Scopes
  scope :by_type, ->(type) { where(question_type: type) }
  scope :with_options, -> { where.not(options: nil) }

  # Methods
  def multiple_choice?
    question_type == "multiple_choice"
  end

  def true_false?
    question_type == "true_false"
  end

  def short_answer?
    question_type == "short_answer"
  end

  def difficulty_score
    analytics = question_analytics.first
    analytics&.difficulty_score || 0
  end

  def success_rate
    analytics = question_analytics.first
    return 0 unless analytics && analytics.times_answered > 0
    
    (analytics.times_correct.to_f / analytics.times_answered * 100).round(1)
  end
end