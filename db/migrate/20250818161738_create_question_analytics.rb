class CreateQuestionAnalytics < ActiveRecord::Migration[8.0]
  def change
    create_table :question_analytics do |t|
      t.integer :question_id, null: false
      t.integer :quiz_id, null: false
      t.integer :times_shown, default: 0
      t.integer :times_answered, default: 0
      t.integer :times_correct, default: 0
      t.integer :times_skipped, default: 0
      t.float :avg_time_seconds
      t.float :difficulty_score
      t.datetime :last_updated

      t.timestamps
    end

    # Indexes for efficient querying
    add_index :question_analytics, :question_id
    add_index :question_analytics, :quiz_id
    add_index :question_analytics, [:question_id, :quiz_id], unique: true
    add_index :question_analytics, :difficulty_score
  end
end
