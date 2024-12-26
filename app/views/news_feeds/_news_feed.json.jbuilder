json.extract! news_feed, :id, :user_id, :effect_id, :collection_id, :created_at, :updated_at
json.url news_feed_url(news_feed, format: :json)
