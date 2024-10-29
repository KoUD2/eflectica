require "application_system_test_case"

class SubCollectionsTest < ApplicationSystemTestCase
  setup do
    @sub_collection = sub_collections(:one)
  end

  test "visiting the index" do
    visit sub_collections_url
    assert_selector "h1", text: "Sub collections"
  end

  test "should create sub collection" do
    visit sub_collections_url
    click_on "New sub collection"

    fill_in "Collection", with: @sub_collection.collection_id
    fill_in "User", with: @sub_collection.user_id
    click_on "Create Sub collection"

    assert_text "Sub collection was successfully created"
    click_on "Back"
  end

  test "should update Sub collection" do
    visit sub_collection_url(@sub_collection)
    click_on "Edit this sub collection", match: :first

    fill_in "Collection", with: @sub_collection.collection_id
    fill_in "User", with: @sub_collection.user_id
    click_on "Update Sub collection"

    assert_text "Sub collection was successfully updated"
    click_on "Back"
  end

  test "should destroy Sub collection" do
    visit sub_collection_url(@sub_collection)
    click_on "Destroy this sub collection", match: :first

    assert_text "Sub collection was successfully destroyed"
  end
end
