require "test_helper"

class QaReportTest < ActiveSupport::TestCase
  fixtures :users, :quizzes
  # Validation tests
  test "should not save qa_report without quiz_id" do
    report = QaReport.new(
      user_id: 1,
      score: 85,
      total_questions: 10,
      correct_answers: 8,
      time_taken: 300,
      completed_at: Time.current
    )
    assert_not report.save, "Saved the qa_report without a quiz_id"
  end

  test "should not save qa_report without user_id" do
    report = QaReport.new(
      quiz_id: 1,
      score: 85,
      total_questions: 10,
      correct_answers: 8,
      time_taken: 300,
      completed_at: Time.current
    )
    assert_not report.save, "Saved the qa_report without a user_id"
  end

  test "should not save qa_report without score" do
    report = QaReport.new(
      quiz_id: 1,
      user_id: 1,
      total_questions: 10,
      correct_answers: 8,
      time_taken: 300,
      completed_at: Time.current
    )
    assert_not report.save, "Saved the qa_report without a score"
  end

  test "should not save qa_report without total_questions" do
    report = QaReport.new(
      quiz_id: 1,
      user_id: 1,
      score: 85,
      correct_answers: 8,
      time_taken: 300,
      completed_at: Time.current
    )
    assert_not report.save, "Saved the qa_report without total_questions"
  end

  test "should not save qa_report without correct_answers" do
    report = QaReport.new(
      quiz_id: 1,
      user_id: 1,
      score: 85,
      total_questions: 10,
      time_taken: 300,
      completed_at: Time.current
    )
    assert_not report.save, "Saved the qa_report without correct_answers"
  end

  test "should not save qa_report without completed_at" do
    report = QaReport.new(
      quiz_id: 1,
      user_id: 1,
      score: 85,
      total_questions: 10,
      correct_answers: 8,
      time_taken: 300
    )
    assert_not report.save, "Saved the qa_report without completed_at"
  end

  test "score should be between 0 and 100" do
    report = QaReport.new(
      quiz_id: 1,
      user_id: 1,
      score: 150,
      total_questions: 10,
      correct_answers: 8,
      time_taken: 300,
      completed_at: Time.current
    )
    assert_not report.save, "Saved the qa_report with score > 100"

    report.score = -10
    assert_not report.save, "Saved the qa_report with negative score"

    report.score = 85
    assert report.save, "Could not save valid qa_report"
  end

  test "total_questions should be positive" do
    report = QaReport.new(
      quiz_id: 1,
      user_id: 1,
      score: 85,
      total_questions: 0,
      correct_answers: 8,
      time_taken: 300,
      completed_at: Time.current
    )
    assert_not report.save, "Saved the qa_report with 0 total_questions"

    report.total_questions = -5
    assert_not report.save, "Saved the qa_report with negative total_questions"
  end

  test "correct_answers should be non-negative and <= total_questions" do
    report = QaReport.new(
      quiz_id: 1,
      user_id: 1,
      score: 85,
      total_questions: 10,
      correct_answers: 15,
      time_taken: 300,
      completed_at: Time.current
    )
    assert_not report.save, "Saved the qa_report with correct_answers > total_questions"

    report.correct_answers = -1
    assert_not report.save, "Saved the qa_report with negative correct_answers"
  end

  test "time_taken should be positive" do
    report = QaReport.new(
      quiz_id: 1,
      user_id: 1,
      score: 85,
      total_questions: 10,
      correct_answers: 8,
      time_taken: -10,
      completed_at: Time.current
    )
    assert_not report.save, "Saved the qa_report with negative time_taken"
  end

  # Association tests (will need Quiz and User models)
  test "should belong to quiz" do
    report = QaReport.new
    assert_respond_to report, :quiz
  end

  test "should belong to user" do
    report = QaReport.new
    assert_respond_to report, :user
  end

  # Score calculation methods tests
  test "percentage method should calculate correct percentage" do
    report = QaReport.new(
      correct_answers: 8,
      total_questions: 10
    )
    assert_equal 80.0, report.percentage
  end

  test "percentage method should handle zero total_questions" do
    report = QaReport.new(
      correct_answers: 0,
      total_questions: 0
    )
    assert_equal 0.0, report.percentage
  end

  test "grade_letter method should return correct letter grade" do
    report = QaReport.new(score: 95)
    assert_equal "A", report.grade_letter

    report.score = 85
    assert_equal "B", report.grade_letter

    report.score = 75
    assert_equal "C", report.grade_letter

    report.score = 65
    assert_equal "D", report.grade_letter

    report.score = 55
    assert_equal "F", report.grade_letter
  end

  # Time formatting helpers tests
  test "human_readable_time should format time correctly" do
    report = QaReport.new(time_taken: 65)
    assert_equal "1m 5s", report.human_readable_time

    report.time_taken = 3665
    assert_equal "1h 1m 5s", report.human_readable_time

    report.time_taken = 30
    assert_equal "30s", report.human_readable_time

    report.time_taken = 3600
    assert_equal "1h 0m 0s", report.human_readable_time
  end

  # Scope tests
  test "by_quiz scope should filter by quiz_id" do
    # This will be tested with fixtures or factories
    skip "Requires fixtures or factories to be set up"
  end

  test "by_user scope should filter by user_id" do
    skip "Requires fixtures or factories to be set up"
  end

  test "recent scope should order by completed_at desc" do
    skip "Requires fixtures or factories to be set up"
  end

  test "in_date_range scope should filter by date range" do
    skip "Requires fixtures or factories to be set up"
  end

  test "high_performers scope should filter scores >= 80" do
    skip "Requires fixtures or factories to be set up"
  end

  test "low_performers scope should filter scores < 60" do
    skip "Requires fixtures or factories to be set up"
  end
end