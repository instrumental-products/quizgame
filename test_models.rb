puts "Testing models..."
u = User.create!(name: "Test User", email: "test@example.com")
q = Quiz.create!(title: "Test Quiz")
r = QaReport.create!(
  quiz: q, 
  user: u, 
  score: 85, 
  total_questions: 10, 
  correct_answers: 8, 
  time_taken: 300, 
  completed_at: Time.current
)
puts "Created QaReport ##{r.id} with score #{r.score}"
puts "Grade: #{r.grade_letter}"
puts "Time: #{r.human_readable_time}"
puts "Percentage: #{r.percentage}%"
puts "All models working correctly!"