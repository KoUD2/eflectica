require 'json'

def seed
    reset_db
    create_users(10)
    create_effects(30)
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

      comments_data.sample(5).each do |comment_data|
        Comment.create!(
          body: comment_data['body'],
          user_id: users.sample.id,
          effect_id: effect.id
        )
      end

      puts "Effect #{effect.name} created with rating #{rating_value}, categories: #{effect.category_list.join(', ')}, tasks: #{effect.task_list.join(', ')}"
    end
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