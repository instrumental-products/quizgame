# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_08_18_235749) do
  create_table "dashboard_caches", force: :cascade do |t|
    t.string "cache_key", null: false
    t.string "cache_type", null: false
    t.json "cache_data"
    t.datetime "expires_at"
    t.integer "entity_id"
    t.string "entity_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cache_key"], name: "index_dashboard_caches_on_cache_key", unique: true
    t.index ["cache_type"], name: "index_dashboard_caches_on_cache_type"
    t.index ["entity_type", "entity_id"], name: "index_dashboard_caches_on_entity_type_and_entity_id"
    t.index ["expires_at"], name: "index_dashboard_caches_on_expires_at"
  end

  create_table "qa_reports", force: :cascade do |t|
    t.integer "quiz_id", null: false
    t.integer "user_id", null: false
    t.integer "score", null: false
    t.integer "total_questions", null: false
    t.integer "correct_answers", null: false
    t.integer "time_taken"
    t.datetime "completed_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["completed_at"], name: "index_qa_reports_on_completed_at"
    t.index ["quiz_id", "completed_at"], name: "index_qa_reports_on_quiz_id_and_completed_at"
    t.index ["quiz_id", "user_id"], name: "index_qa_reports_on_quiz_id_and_user_id"
    t.index ["quiz_id"], name: "index_qa_reports_on_quiz_id"
    t.index ["user_id", "completed_at"], name: "index_qa_reports_on_user_id_and_completed_at"
    t.index ["user_id"], name: "index_qa_reports_on_user_id"
  end

  create_table "question_analytics", force: :cascade do |t|
    t.integer "question_id", null: false
    t.integer "quiz_id", null: false
    t.integer "times_shown", default: 0
    t.integer "times_answered", default: 0
    t.integer "times_correct", default: 0
    t.integer "times_skipped", default: 0
    t.float "avg_time_seconds"
    t.float "difficulty_score"
    t.datetime "last_updated"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["difficulty_score"], name: "index_question_analytics_on_difficulty_score"
    t.index ["question_id", "quiz_id"], name: "index_question_analytics_on_question_id_and_quiz_id", unique: true
    t.index ["question_id"], name: "index_question_analytics_on_question_id"
    t.index ["quiz_id"], name: "index_question_analytics_on_quiz_id"
  end

  create_table "questions", force: :cascade do |t|
    t.integer "quiz_id", null: false
    t.text "content", null: false
    t.string "question_type"
    t.json "options"
    t.string "correct_answer"
    t.integer "points", default: 1
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["quiz_id"], name: "index_questions_on_quiz_id"
  end

  create_table "quiz_metrics_dailies", force: :cascade do |t|
    t.integer "quiz_id", null: false
    t.date "metric_date", null: false
    t.integer "total_attempts", default: 0
    t.integer "unique_users", default: 0
    t.integer "completions", default: 0
    t.float "avg_score"
    t.float "avg_time_seconds"
    t.integer "perfect_scores", default: 0
    t.integer "failures", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["metric_date"], name: "index_quiz_metrics_dailies_on_metric_date"
    t.index ["quiz_id", "metric_date"], name: "index_quiz_metrics_dailies_on_quiz_id_and_metric_date", unique: true
    t.index ["quiz_id"], name: "index_quiz_metrics_dailies_on_quiz_id"
  end

  create_table "quizzes", force: :cascade do |t|
    t.string "title", null: false
    t.text "description"
    t.string "category"
    t.integer "difficulty_level"
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_quizzes_on_active"
    t.index ["category"], name: "index_quizzes_on_category"
  end

  create_table "user_metrics_dailies", force: :cascade do |t|
    t.integer "user_id", null: false
    t.date "metric_date", null: false
    t.integer "quizzes_taken", default: 0
    t.integer "quizzes_completed", default: 0
    t.float "avg_score"
    t.integer "total_time_seconds", default: 0
    t.integer "perfect_scores", default: 0
    t.integer "questions_answered", default: 0
    t.integer "correct_answers", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["metric_date"], name: "index_user_metrics_dailies_on_metric_date"
    t.index ["user_id", "metric_date"], name: "index_user_metrics_dailies_on_user_id_and_metric_date", unique: true
    t.index ["user_id"], name: "index_user_metrics_dailies_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.string "role", default: "user"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "password_digest"
    t.index ["email"], name: "index_users_on_email", unique: true
  end
end
