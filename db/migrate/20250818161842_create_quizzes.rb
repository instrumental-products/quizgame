class CreateQuizzes < ActiveRecord::Migration[8.0]
  def change
    create_table :quizzes do |t|
      t.string :title, null: false
      t.text :description
      t.string :category
      t.integer :difficulty_level
      t.boolean :active, default: true

      t.timestamps
    end

    add_index :quizzes, :category
    add_index :quizzes, :active
  end
end
