class CreateQuestions < ActiveRecord::Migration[8.0]
  def change
    create_table :questions do |t|
      t.integer :quiz_id, null: false
      t.text :content, null: false
      t.string :question_type
      t.json :options
      t.string :correct_answer
      t.integer :points, default: 1

      t.timestamps
    end

    add_index :questions, :quiz_id
  end
end
