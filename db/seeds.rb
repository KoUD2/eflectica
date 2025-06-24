require 'json'

def seed
    reset_db
    create_effect_categories
    create_effect_programs
    create_effect_tasks
    create_users(10)
    create_effects(18)
    create_user_preferences
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

def create_effect_categories
  categories = ["photoProcessing", "3dGrafics", "motion", "illustration", "animation", "uiux", "videoProcessing", "vfx", "gamedev", "arvr"]
  
  categories.each do |category_name|
    begin
      EffectCategory.create!(name: category_name)
      puts "✅ Category '#{category_name}' created"
    rescue ActiveRecord::RecordInvalid => e
      puts "❌ Error creating category '#{category_name}': #{e.message}"
    end
  end
end

def create_effect_programs
  programs = ["photoshop", "lightroom", "after_effects", "premiere_pro", "blender", "affinity_photo", "capture_one", "maya", "cinema_4d", "3ds_max", "zbrush", "unreal", "davinci", "substance", "protopie", "krita", "sketch", "animate", "figma", "clip", "nuke", "fc", "procreate", "godot", "lens", "rive", "unity", "spark", "spine", "toon"]
  
  programs.each do |program_name|
    begin
      EffectProgram.create!(name: program_name)
      puts "✅ Program '#{program_name}' created"
    rescue ActiveRecord::RecordInvalid => e
      puts "❌ Error creating program '#{program_name}': #{e.message}"
    end
  end
end

def create_effect_tasks
  tasks = ["portraitRetouching", "colorCorrection", "improvePhotoQuality", "preparationForPrinting", "socialMediaContent", "advertisingProcessing", "stylization", "backgroundEditing", "graphicContent", "setLight", "simulation3d", "atmosphereWeather"]
  
  tasks.each do |task_name|
    begin
      EffectTask.create!(name: task_name)
      puts "✅ Task '#{task_name}' created"
    rescue ActiveRecord::RecordInvalid => e
      puts "❌ Error creating task '#{task_name}': #{e.message}"
    end
  end
end

def create_user_preferences
  User.all.each do |user|
    # Случайный выбор 2-4 категорий для каждого пользователя
    selected_categories = EffectCategory.all.sample(rand(2..4))
    selected_categories.each do |category|
      begin
        UserEffectCategory.create!(user: user, effect_category: category)
        puts "✅ User #{user.username} prefers category '#{category.name}'"
      rescue ActiveRecord::RecordInvalid => e
        puts "❌ Error creating user category preference: #{e.message}"
      end
    end
    
    # Случайный выбор 2-3 программ для каждого пользователя
    selected_programs = EffectProgram.all.sample(rand(2..3))
    selected_programs.each do |program|
      begin
        UserEffectProgram.create!(user: user, effect_program: program)
        puts "✅ User #{user.username} prefers program '#{program.name}'"
      rescue ActiveRecord::RecordInvalid => e
        puts "❌ Error creating user program preference: #{e.message}"
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
  all_programs = ["photoshop", "lightroom", "after_effects", "premiere_pro", "blender", "affinity_photo", "capture_one", "maya", "cinema_4d", "3ds_max", "zbrush", "unreal", "davinci", "substance", "protopie", "krita", "sketch", "animate", "figma", "clip", "nuke", "fc", "procreate", "godot", "lens", "rive", "unity", "spark", "spine", "toon"]

  # Создаем специальный эффект с гифкой и статусом "Одобрено"
  begin
    special_effect = Effect.new(
      name: "GIF Animation Effect",
      user: users.sample,
      img: upload_effect_image("animationMotion.png"),
      description: "Специальный эффект анимации с использованием GIF",
      speed: 9,
      platform: "windows,mac",
      manual: "Руководство по созданию анимационных эффектов",
      link_to: "#",
      is_secure: "Одобрено"
    )

    # Сохраняем старые теги для совместимости
    special_effect.category_list = ["animation", "motion"].join(', ')
    special_effect.task_list = ["graphicContent", "stylization"].join(', ')

    if special_effect.save!
      puts "✅ Специальный GIF эффект ##{special_effect.id} создан с статусом 'Одобрено'."
      
      # Создаем связи с программами через связующую таблицу
      selected_programs = EffectProgram.where(name: ["after_effects", "photoshop"])
      selected_programs.each do |program|
        program_version = "2024.1.0"
        program.update!(version: program_version)
        
        EffectEffectProgram.create!(effect: special_effect, effect_program: program)
        puts "  ✅ Связь с программой '#{program.name}' (версия #{program_version}) создана"
      end
      
      # Создаем связи с категориями
      selected_categories = EffectCategory.where(name: ["animation", "motion"])
      selected_categories.each do |category|
        EffectEffectCategory.create!(effect: special_effect, effect_category: category)
        puts "  ✅ Связь с категорией '#{category.name}' создана"
      end
      
      # Создаем связи с задачами
      selected_tasks = EffectTask.where(name: ["graphicContent", "stylization"])
      selected_tasks.each do |task|
        EffectEffectTask.create!(effect: special_effect, effect_task: task)
        puts "  ✅ Связь с задачей '#{task.name}' создана"
      end
      
      # Передаем данные с гифкой как before_image
      create_dependencies(special_effect, {"before_image" => "gifExample.gif", "after_image" => "gifExample.gif"}, comments_data)
    else
      puts "❌ Ошибки валидации специального эффекта: #{special_effect.errors.full_messages}"
    end

  rescue => e
    puts "🔥 Критическая ошибка при создании специального эффекта: #{e.message}"
    puts e.backtrace.join("\n")
  end

  effects_data.sample(quantity).each do |effect_data|
    begin
      effect = Effect.new(
        name: effect_data["Name"].to_s,
        user: users.sample,
        img: upload_effect_image(effect_data["image"]),
        description: effect_data["Description"].to_s,
        speed: effect_data["Speed"].to_i,
        platform: effect_data["Platform"].to_s,
        manual: effect_data["Manual"].to_s,
        link_to: effect_data["Link_to"].presence || "#",
        is_secure: effect_data["Is_secure"]
      )

      # Сохраняем старые теги для совместимости
      effect.category_list = all_categories.sample(1).join(', ')
      effect.task_list = all_tasks.sample(rand(2..3)).join(', ')

      if effect.save!
        puts "✅ Effect ##{effect.id} создан."
        
        # Создаем связи с программами через связующую таблицу с версиями
        selected_programs = EffectProgram.where(name: all_programs.sample(rand(1..3)))
        selected_programs.each do |program|
          # Обновляем версию программы из JSON данных или используем случайную
          program_version = effect_data["Program version"].presence || effect_data["Program_version"].presence || "#{rand(1..5)}.#{rand(0..9)}.#{rand(0..9)}"
          
          # Обновляем версию программы
          program.update!(version: program_version)
          
          EffectEffectProgram.create!(effect: effect, effect_program: program)
          puts "  ✅ Связь с программой '#{program.name}' (версия #{program_version}) создана"
        end
        
        # Создаем связи с категориями через связующую таблицу
        selected_categories = EffectCategory.where(name: all_categories.sample(rand(1..2)))
        selected_categories.each do |category|
          EffectEffectCategory.create!(effect: effect, effect_category: category)
          puts "  ✅ Связь с категорией '#{category.name}' создана"
        end
        
        # Создаем связи с задачами через связующую таблицу
        selected_tasks = EffectTask.where(name: all_tasks.sample(rand(2..4)))
        selected_tasks.each do |task|
          EffectEffectTask.create!(effect: effect, effect_task: task)
          puts "  ✅ Связь с задачей '#{task.name}' создана"
        end
        
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