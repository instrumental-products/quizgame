class CreateQuizMetricsDaily < ActiveRecord::Migration[8.0]
  def change
    create_table :quiz_metrics_dailies do |t|
      t.integer :quiz_id, null: false
      t.date :metric_date, null: false
      t.integer :total_attempts, default: 0
      t.integer :unique_users, default: 0
      t.integer :completions, default: 0
      t.float :avg_score
      t.float :avg_time_seconds
      t.integer :perfect_scores, default: 0
      t.integer :failures, default: 0

      t.timestamps
    end

    # Indexes for efficient querying
    add_index :quiz_metrics_dailies, :quiz_id
    add_index :quiz_metrics_dailies, :metric_date
    add_index :quiz_metrics_dailies, [:quiz_id, :metric_date], unique: true
  end
end
