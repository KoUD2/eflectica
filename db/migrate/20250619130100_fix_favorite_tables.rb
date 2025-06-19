class FixFavoriteTables < ActiveRecord::Migration[7.2]
  def up
    # Создаем таблицу favorite_links только если она не существует
    unless table_exists?(:favorite_links)
      create_table :favorite_links do |t|
        t.references :user, null: false, foreign_key: true
        t.string :name, null: false
        t.text :notes
        t.string :url, null: false

        t.timestamps
      end
    end

    # Проверяем, что все нужные колонки есть в favorite_images
    if table_exists?(:favorite_images)
      # Добавляем недостающие колонки, если их нет
      unless column_exists?(:favorite_images, :title)
        add_column :favorite_images, :title, :string, null: false
      end
      unless column_exists?(:favorite_images, :notes)
        add_column :favorite_images, :notes, :text
      end
      unless column_exists?(:favorite_images, :image_file_name)
        add_column :favorite_images, :image_file_name, :string
      end
      unless column_exists?(:favorite_images, :image_content_type)
        add_column :favorite_images, :image_content_type, :string
      end
      unless column_exists?(:favorite_images, :image_file_size)
        add_column :favorite_images, :image_file_size, :integer
      end
      unless column_exists?(:favorite_images, :image_updated_at)
        add_column :favorite_images, :image_updated_at, :datetime
      end
    end
  end

  def down
    drop_table :favorite_links if table_exists?(:favorite_links)
    # Не удаляем favorite_images, так как она может использоваться
  end
end 