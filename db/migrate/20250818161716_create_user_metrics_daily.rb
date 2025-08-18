class CreateUserMetricsDaily < ActiveRecord::Migration[8.0]
  def change
    create_table :user_metrics_dailies do |t|
      t.integer :user_id, null: false
      t.date :metric_date, null: false
      t.integer :quizzes_taken, default: 0
      t.integer :quizzes_completed, default: 0
      t.float :avg_score
      t.integer :total_time_seconds, default: 0
      t.integer :perfect_scores, default: 0
      t.integer :questions_answered, default: 0
      t.integer :correct_answers, default: 0

      t.timestamps
    end

    # Indexes for efficient querying
    add_index :user_metrics_dailies, :user_id
    add_index :user_metrics_dailies, :metric_date
    add_index :user_metrics_dailies, [:user_id, :metric_date], unique: true
  end
end
