require 'json'

def seed
    reset_db
    create_questions
    create_users
end

def reset_db
    Rake::Task['db:drop'].invoke
    Rake::Task['db:create'].invoke
    Rake::Task['db:migrate'].invoke
end

def create_questions
  file = File.read(Rails.root.join('app/views/questions', 'data.json'))
  questions_data = JSON.parse(file)

  comments_data = JSON.parse(File.read(Rails.root.join('app/views/questions', 'comments.json')))
  
  user = User.find_or_create_by!(username: "test_user", email: "test@example.com", password: "password")

  questions_data.each do |question_data|
    question = Question.create!(
      title: question_data['title'],
      media: question_data['media'],
      description: question_data['description'],
      user_id: user.id
    )

    5.times do |i|
      Comment.create!(
        body: comments_data[i % comments_data.length]['body'],
        commentable: question
      )
    end
  end
end

def create_users
  file = File.read('app/views/users/users.json')
  users = JSON.parse(file)

  users.each do |user_data|
    User.create!(
      username: user_data['username'],
      bio: user_data['bio'],
      contact: user_data['contact'],
      portfolio: user_data['portfolio'],
      is_admin: user_data['is_admin'],
      avatar: user_data['avatar'],
      email: user_data['email'],
      password: user_data['password']
    )
  end
end

create_users


seed