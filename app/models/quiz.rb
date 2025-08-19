class Quiz < ApplicationRecord
  # Associations
  has_many :qa_reports, dependent: :destroy
  has_many :questions, dependent: :destroy
  has_many :quiz_metrics_dailies, dependent: :destroy
  has_many :question_analytics, class_name: "QuestionAnalytics", dependent: :destroy

  # Validations
  validates :title, presence: true
  validates :difficulty_level, inclusion: { in: 1..5 }, allow_nil: true

  # Scopes
  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }
  scope :by_category, ->(category) { where(category: category) }
  scope :by_difficulty, ->(level) { where(difficulty_level: level) }
  scope :most_popular, -> { joins(:qa_reports).group(:id).order("COUNT(qa_reports.id) DESC") }

  # Methods
  def total_attempts
    qa_reports.count
  end

  def average_score
    qa_reports.average(:score)&.round(1) || 0
  end

  def completion_rate
    return 0 if qa_reports.count == 0
    (qa_reports.where.not(completed_at: nil).count.to_f / qa_reports.count * 100).round(1)
  end

  def unique_participants
    qa_reports.distinct.count(:user_id)
  end

  def difficulty_label
    return "Not Set" if difficulty_level.nil?
    
    case difficulty_level
    when 1 then "Very Easy"
    when 2 then "Easy"
    when 3 then "Medium"
    when 4 then "Hard"
    when 5 then "Very Hard"
    end
  end

  def question_count
    questions.count
  end

  def last_attempted_at
    qa_reports.maximum(:completed_at)
  end
end