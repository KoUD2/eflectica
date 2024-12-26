require "application_system_test_case"

class NewsFeedsTest < ApplicationSystemTestCase
  setup do
    @news_feed = news_feeds(:one)
  end

  test "visiting the index" do
    visit news_feeds_url
    assert_selector "h1", text: "News feeds"
  end

  test "should create news feed" do
    visit news_feeds_url
    click_on "New news feed"

    fill_in "Collection", with: @news_feed.collection_id
    fill_in "Effect", with: @news_feed.effect_id
    fill_in "User", with: @news_feed.user_id
    click_on "Create News feed"

    assert_text "News feed was successfully created"
    click_on "Back"
  end

  test "should update News feed" do
    visit news_feed_url(@news_feed)
    click_on "Edit this news feed", match: :first

    fill_in "Collection", with: @news_feed.collection_id
    fill_in "Effect", with: @news_feed.effect_id
    fill_in "User", with: @news_feed.user_id
    click_on "Update News feed"

    assert_text "News feed was successfully updated"
    click_on "Back"
  end

  test "should destroy News feed" do
    visit news_feed_url(@news_feed)
    click_on "Destroy this news feed", match: :first

    assert_text "News feed was successfully destroyed"
  end
end
