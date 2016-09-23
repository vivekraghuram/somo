FactoryGirl.define do
  question_111 = { :questionType => "short_answer", :questionIndex => 0, :_key => 0, :text => "1-1:1 Subq", :options => nil, :qname => "Question 1-1:1" }
  option_1 = { :value => "Op 1", :conditional => true, :questions => [question_111] }

  option_2 = { :value => "Op 2", :conditional => false, :questions => [] }

  question_13211 = { :questionType => "short_answer", :questionIndex => 0, :_key => 0, :text => "1-3:2-1:1 Why?", :options => nil, :qname => "Question 1-3:2-1:1"}
  question_13221 = { :questionType => "short_answer", :questionIndex => 0, :_key => 0, :text => "1-3:2-2:1 Why not?", :options => nil, :qname => "Question 1-3:2-2:1"}
  yes_option = { :value => "Yes", :conditional => true, :questions => [ question_13211 ] }
  no_option = { :value => "No", :conditional => true, :questions => [ question_13221 ] }
  question_131 = { :questionType => "short_answer", :questionIndex => 0, :_key => 0, :text => "1-3:1 Subq", :options => nil, :qname => "Question 1-3:1" }
  question_132 = { :questionType => "conditional", :questionIndex => 1, :_key => 1, :text => "1-3:2 Subq", :options => [ yes_option, no_option], :qname => "Question 1-3:2" }
  checkbox_op_1 = { :value => "Op 1" }
  checkbox_op_2 = { :value => "Op 2" }
  question_133 = { :questionType => "checkbox", :questionIndex => 2, :_key => 2, :text => "1-3:3 Subq", :options => [ checkbox_op_1, checkbox_op_2 ], :qname => "Question 1-3:3" }
  option_3 = { :value => "Op 3", :conditional => true, :questions => [question_131, question_132, question_133] }

  question_1 = { :questionType => "conditional", :questionIndex => 0, :_key => 0, :text => "First", :options => [ option_1 , option_2, option_3 ], :qname => "Question 1" }
  question_2 = { :questionType => "short_answer", :questionIndex => 1, :_key => 1, :text => "Second", :options => nil, :qname => "Question 2"}

  form_json = { :name => "Title", :intro => "Desc.", :questions => [ question_1, question_2 ] }

  factory :form do |f|
    f.name           "Tester Form"
    f.intro          "This is a tester form."
    f.created_at     { DateTime.now }
    f.updated_at     { DateTime.now }
    f.first_question  0
    f.json           form_json
  end
end
