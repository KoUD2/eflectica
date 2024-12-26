require "test_helper"

class NewsFeedsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @news_feed = news_feeds(:one)
  end

  test "should get index" do
    get news_feeds_url
    assert_response :success
  end

  test "should get new" do
    get new_news_feed_url
    assert_response :success
  end

  test "should create news_feed" do
    assert_difference("NewsFeed.count") do
      post news_feeds_url, params: { news_feed: { collection_id: @news_feed.collection_id, effect_id: @news_feed.effect_id, user_id: @news_feed.user_id } }
    end

    assert_redirected_to news_feed_url(NewsFeed.last)
  end

  test "should show news_feed" do
    get news_feed_url(@news_feed)
    assert_response :success
  end

  test "should get edit" do
    get edit_news_feed_url(@news_feed)
    assert_response :success
  end

  test "should update news_feed" do
    patch news_feed_url(@news_feed), params: { news_feed: { collection_id: @news_feed.collection_id, effect_id: @news_feed.effect_id, user_id: @news_feed.user_id } }
    assert_redirected_to news_feed_url(@news_feed)
  end

  test "should destroy news_feed" do
    assert_difference("NewsFeed.count", -1) do
      delete news_feed_url(@news_feed)
    end

    assert_redirected_to news_feeds_url
  end
end
