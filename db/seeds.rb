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
  
    user = User.find_or_create_by!(username: "test_user", email: "test@example.com", password: "password")
  
    questions_data.each do |question_data|
      Question.create!(
        title: question_data['title'],
        media: question_data['media'],
        description: question_data['description'],
        user_id: user.id
      )
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
      speed: user_data['speed'],
      is_admin: user_data['is_admin'],
      avatar: user_data['avatar'],
      email: user_data['email'],
      password: user_data['password']
    )
  end
end

create_users


seed