class User < ApplicationRecord
  # Associations
  has_many :qa_reports, dependent: :destroy
  has_many :user_metrics_dailies, dependent: :destroy

  # Validations
  validates :name, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :role, inclusion: { in: %w[user admin moderator] }

  # Scopes
  scope :admins, -> { where(role: "admin") }
  scope :regular_users, -> { where(role: "user") }

  # Methods
  def admin?
    role == "admin"
  end

  def recent_quiz_scores(limit = 10)
    qa_reports.recent.limit(limit).pluck(:score)
  end

  def average_score
    qa_reports.average(:score)&.round(1) || 0
  end

  def total_quizzes_taken
    qa_reports.count
  end

  def total_perfect_scores
    qa_reports.where(score: 100).count
  end
end