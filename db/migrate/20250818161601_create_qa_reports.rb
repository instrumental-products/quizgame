class CreateQaReports < ActiveRecord::Migration[8.0]
  def change
    create_table :qa_reports do |t|
      t.integer :quiz_id, null: false
      t.integer :user_id, null: false
      t.integer :score, null: false
      t.integer :total_questions, null: false
      t.integer :correct_answers, null: false
      t.integer :time_taken
      t.datetime :completed_at, null: false

      t.timestamps
    end

    # Add indexes for performance optimization
    add_index :qa_reports, :quiz_id
    add_index :qa_reports, :user_id
    add_index :qa_reports, :completed_at
    add_index :qa_reports, [:quiz_id, :user_id]
    add_index :qa_reports, [:quiz_id, :completed_at]
    add_index :qa_reports, [:user_id, :completed_at]
  end
end
