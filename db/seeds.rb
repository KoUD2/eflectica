require 'json'

def seed
    reset_db
    create_users(10)
    create_effects(18)
    create_favorites
    create_collections(15)
    create_subscriptions(15)
    create_sub_collections
end

def reset_db
    Rake::Task['db:drop'].invoke
    Rake::Task['db:create'].invoke
    Rake::Task['db:migrate'].invoke
end

def create_sub_collections
  User.all.each do |user|
    available_collections = Collection.where.not(user_id: user.id)
    
    collections_to_subscribe = available_collections.sample([5, available_collections.count].min)
    
    collections_to_subscribe.each do |collection|
      begin
        SubCollection.create!(
          user: user,
          collection: collection
        )
        puts "✅ User #{user.username} subscribed to #{collection.name}"
      rescue ActiveRecord::RecordInvalid => e
        puts "❌ Error creating subscription: #{e.message}"
      end
    end
  end
end

def upload_effect_image(filename)
  uploader = EffectImageUploader.new(Effect.new, :img)
  image_path = Rails.root.join('public/autoupload/effect', filename)
  
  if File.exist?(image_path)
    uploader.cache!(File.open(image_path))
  else
    raise "Missing image for effect: #{filename}"
  end

  uploader
end


def upload_random_image
  uploader = EffectImageUploader.new(Effect.new, :img)
  uploader.cache!(File.open(Dir.glob(File.join(Rails.root, 'public/autoupload/effect', '*')).sample))
  uploader
end

def upload_random_user_avatar
  uploader = UserImageUploader.new(User.new, :avatar)
  uploader.cache!(File.open(Dir.glob(File.join(Rails.root, 'public/autoupload/user', '*')).sample))
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
      avatar: upload_random_user_avatar,
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
  effects_data = JSON.parse(File.read('db/effects.json'))
  comments_data = JSON.parse(File.read('db/comments.json'))
  users = User.all
  return if users.empty?

  all_categories = ["photoProcessing", "3dGrafics", "motion", "illustration", "animation", "uiux", "videoProcessing", "vfx", "gamedev", "arvr"]
  all_tasks = ["portraitRetouching", "colorCorrection", "improvePhotoQuality", "preparationForPrinting", "socialMediaContent", "advertisingProcessing", "stylization", "backgroundEditing", "graphicContent", "setLight", "simulation3d", "atmosphereWeather"]

  effects_data.sample(quantity).each do |effect_data|
    begin
      effect = Effect.new(
        name: effect_data["Name"].to_s,
        user: users.sample,
        img: upload_effect_image(effect_data["image"]),
        description: effect_data["Description"].to_s,
        speed: effect_data["Speed"].to_i,
        platform: effect_data["Platform"].to_s,
        programs: effect_data["Programs"].to_s,
        manual: effect_data["Manual"].to_s,
        link_to: effect_data["Link_to"].presence || "#",
        is_secure: effect_data["Is_secure"],
        program_version: effect_data["Program version"].presence || "1.0"
      )

      effect.category_list = all_categories.sample(1).join(', ')
      effect.task_list = all_tasks.sample(rand(2..3)).join(', ')

      if effect.save!
        puts "✅ Effect ##{effect.id} создан."
        create_dependencies(effect, effect_data, comments_data)
      else
        puts "❌ Ошибки валидации: #{effect.errors.full_messages}"
      end

    rescue => e
      puts "🔥 Критическая ошибка: #{e.message}"
      puts e.backtrace.join("\n")
    end
  end
end


def create_dependencies(effect, effect_data, comments_data)
  users = User.all.to_a
  return puts "⚠️ Недостаточно пользователей для рейтингов" if users.size < 1

  users.sample([users.size, 5].min).each do |user|
    ActiveRecord::Base.transaction do
      begin
        rating = Rating.create!(
          user: user,
          ratingable: effect,
          number: rand(1..5)
        )

        Comment.create!(
          body: comments_data.sample["body"].presence || "Базовый комментарий",
          user: user,
          effect: effect
        )

        puts "✅ Рейтинг #{rating.id} создан для эффекта #{effect.id}"
      
      rescue ActiveRecord::RecordInvalid => e
        puts "❌ Ошибка создания: #{e.record.class} - #{e.record.errors.full_messages}"
      end
    end
  end

  %w[before after].each do |type|
    next unless effect_data["#{type}_image"]
    
    Image.create!(
      imageable: effect,
      image_type: type,
      file: upload_effect_image(effect_data["#{type}_image"])
    )
  rescue => e
    puts "⚠️ Ошибка изображения #{type}: #{e.message}"
  end
end



def create_favorites
  User.find_each do |user|
    effects = Effect.limit(rand(3..7)).order("RANDOM()")
    
    effects.each do |effect|
      begin
        Favorite.create!(
          user: user,
          effect: effect
        )
      rescue ActiveRecord::RecordInvalid => e
        puts "Failed to favorite #{effect.name} for #{user.username}: #{e.message}"
      end
    end
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

      effects.sample(5).each do |effect|
        CollectionEffect.create!(
          collection_id: collection.id,
          effect_id: effect.id
        )
      end

      3.times do |j|
        CollectionImage.create!(
          collection: collection,
          image: Image.create!(
            imageable: collection,
            image_type: 'description',
            file: upload_random_collection_image,
            title: Faker::Lorem.word
          )
        )
      end

      1.times do
        CollectionLink.create!(
          collection: collection,
          link: Link.create!(
            path: 'https://youtu.be/MFdYAsTNuq8?si=ay2jwXgzV8DUvZym',
            title: 'Эффект дрожания'
          )
        )
      end

      puts "Collection #{collection.name} created with:"
      puts "  - 10 effects"
      puts "  - 3 images"
      puts "  - 1 links"

    rescue ActiveRecord::RecordInvalid => e
      puts "Error creating collection ##{i + 1}: #{e.message}"
      e.record.errors.full_messages.each { |msg| puts "  - #{msg}" }
    rescue StandardError => e
      puts "Unexpected error creating collection ##{i + 1}: #{e.message}"
    end
  end
end

def upload_random_collection_image
  uploader = CollectionImageUploader.new(Collection.new)
  uploader.cache!(File.open(Dir.glob(File.join(Rails.root, 'public/autoupload/collections', '*')).sample))
  uploader
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