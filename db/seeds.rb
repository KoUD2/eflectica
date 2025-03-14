require 'json'

def seed
    reset_db
    create_users(10)
    create_effects(30)
    create_questions(30)
    create_favorites(20)
    create_collections(15)
    create_subscriptions(15)
end

def reset_db
    Rake::Task['db:drop'].invoke
    Rake::Task['db:create'].invoke
    Rake::Task['db:migrate'].invoke
end

def upload_random_image
  uploader = EffectImageUploader.new(Effect.new, :img)
  uploader.cache!(File.open(Dir.glob(File.join(Rails.root, 'public/autoupload/effect', '*')).sample))
  uploader
end

def create_users(quantity)
  file = File.read('db/users.json')
  users_data = JSON.parse(file)

  quantity.times do |i|
    user_data = users_data.sample

    new_username = "#{user_data['username']}_#{i + 1}"
    new_email = "#{user_data['email']}#{i + 1}"

    user = User.create!(
      username: new_username,
      bio: user_data['bio'],
      contact: user_data['contact'],
      portfolio: user_data['portfolio'],
      is_admin: get_random_bool,
      avatar: user_data['avatar'],
      email: new_email,
      password: user_data['password']
    )

    puts "User created with username #{new_username} with jti #{user.jti }"
  end
end

def get_random_bool
  [true, false].sample
end

def create_effects(quantity)
  file = File.read('db/effects.json')
  effects_data = JSON.parse(file)
  comments_data = JSON.parse(File.read('db/comments.json'))

  available_effects = effects_data.sample(quantity)
  users = User.all

  if users.empty?
    puts "No users available to associate with effects. Aborting creation."
    return
  end

  all_categories = ["Анимация", "VFX", "3D-графика", "Обработка видео"]
  all_tasks = ["Ретушь", "Рендеринг", "Монтаж", "Коррекция цвета"]

  quantity.times do |i|
    effect_data = available_effects[i % available_effects.length]

    effect = Effect.create!(
      name: "#{effect_data['Name']}_#{i + 1}",
      img: upload_random_image,
      description: effect_data['Description'],
      speed: effect_data['Speed'],
      platform: effect_data['Platform'],
      programs: effect_data['Programs'],
      manual: effect_data['Manual'],
      link_to: effect_data['Link_to'],
      is_secure: effect_data['Is_secure'],
      program_version: effect_data['Program version'],
      user: users.sample
    )

    effect.category_list = all_categories.sample(rand(1..2))
    effect.task_list = all_tasks.sample(rand(1..2))
    effect.save

    if effect.persisted?
      rating_value = rand(1..5)
      Rating.create!(
        number: rating_value,
        ratingable: effect,
        user_id: users.sample.id
      )

      before_img = upload_random_image
      after_img = upload_random_image

      Image.create!(
        file: before_img,
        image_type: "before",
        imageable: effect
      )

      Image.create!(
        file: after_img,
        image_type: "after",
        imageable: effect
      )

      comments = []
      5.times do |j|
        comment = Comment.create!(
          body: comments_data[j % comments_data.length]['body'],
          user_id: users.sample.id,
          commentable: effect
        )
        comments << comment.body
      end

      puts "Effect #{effect.name} created with rating #{rating_value}, categories: #{effect.category_list.join(', ')}, tasks: #{effect.task_list.join(', ')}"
    end
  end
end

def create_questions(quantity)
  file = File.read('db/questions.json')
  questions_data = JSON.parse(file)

  comments_data = JSON.parse(File.read('db/comments.json'))
  users = User.all

  all_categories = ["Анимация", "VFX", "3D-графика", "Обработка видео"]
  all_tasks = ["Ретушь", "Рендеринг", "Монтаж", "Коррекция цвета"]

  puts "Всего пользователей: #{User.count}"
  puts "Существующие теги: #{ActsAsTaggableOn::Tag.pluck(:name).inspect}"

  quantity.times do |i|
    user = users.sample
    puts "Выбран пользователь: #{user&.id}, существует ли он? #{User.exists?(user&.id)}"

    question_data = questions_data.sample

    categories = all_categories.sample(rand(1..2))
    tasks = all_tasks.sample(rand(1..2))

    categories.each { |cat| ActsAsTaggableOn::Tag.find_or_create_by!(name: cat) }
    tasks.each { |task| ActsAsTaggableOn::Tag.find_or_create_by!(name: task) }

    puts "Категории для вопроса: #{categories.inspect}"
    puts "Задачи для вопроса: #{tasks.inspect}"

    question = Question.new(
      title: "#{question_data['title']}_#{i + 1}",
      description: question_data['description'],
      platform: question_data['platform'],
      programs: question_data['programs'],
      link_to: question_data['link_to'],
      user_id: user&.id
    )

    puts "Создаём вопрос: #{question.inspect}"

    categories.each do |cat|
      ActsAsTaggableOn::Tag.find_or_create_by!(name: cat)
    end

    tasks.each do |task|
      ActsAsTaggableOn::Tag.find_or_create_by!(name: task)
    end

    question.category_list = categories
    question.task_list = tasks

    unless question.valid?
      puts "Ошибка валидации: #{question.errors.full_messages.join(', ')}"
      next
    end

    if question.save
      puts "Вопрос сохранён!"
    else
      puts "Ошибка при сохранении: #{question.errors.full_messages.join(', ')}"
    end

    before_img = upload_random_image
    after_img = upload_random_image
    description_img = upload_random_image

    puts "before_img: #{before_img}, after_img: #{after_img}, description_img: #{description_img}"

    Image.create!(
      file: before_img,
      image_type: "before",
      imageable: question
    )

    Image.create!(
      file: after_img,
      image_type: "after",
      imageable: question
    )

    Image.create!(
      file: description_img,
      image_type: "description",
      imageable: question
    )

    rand(1..5).times do
      Comment.create!(
        body: comments_data.sample['body'],
        user_id: users.sample.id,
        commentable: question
      )
    end

    puts "Created images and comments"
  end
end


def create_favorites(quantity)
  users = User.all
  effects = Effect.all

  quantity.times do |i|
    Favorite.create!(
      user: users.sample,
      effect: effects.sample
    )
    puts "Favorite ##{i + 1} created!"
  end
end

def create_collections(quantity)
  users = User.all
  effects = Effect.all
  statuses = ['public', 'private']

  if users.empty? || effects.empty?
    puts "No users or effects available to create collections. Aborting creation."
    return
  end

  quantity.times do |i|
    begin
      collection = Collection.create!(
        name: "Collection #{Faker::Lorem.word}_#{i + 1}",
        description: Faker::Lorem.sentence,
        user: users.sample,
        status: statuses.sample
      )

      collection.save!

      effects.sample(10).each do |effect|
        CollectionEffect.create!(
          collection_id: collection.id,
          effect_id: effect.id
        )
      end

      puts "Collection #{collection.name} created with 10 effects!"
    rescue ActiveRecord::RecordInvalid => e
      puts "Error creating collection ##{i + 1}: #{e.message}"
      e.record.errors.full_messages.each { |msg| puts "  - #{msg}" }
    rescue StandardError => e
      puts "Unexpected error creating collection ##{i + 1}: #{e.message}"
    end
  end
end

def create_subscriptions(quantity)
  users = User.all
  effects = Effect.all
  public_collections = Collection.where(status: 'public')

  return if public_collections.empty?

  first_user = users.first

  quantity.times do |i|
    NewsFeed.create!(
      user: first_user,
      effect: effects.sample,
      collection: public_collections.sample
    )
    puts "Subscription ##{i + 1} created for user #{first_user.username}!"
  end
end

seed