require "test_helper"

class SubCollectionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @sub_collection = sub_collections(:one)
  end

  test "should get index" do
    get sub_collections_url
    assert_response :success
  end

  test "should get new" do
    get new_sub_collection_url
    assert_response :success
  end

  test "should create sub_collection" do
    assert_difference("SubCollection.count") do
      post sub_collections_url, params: { sub_collection: { collection_id: @sub_collection.collection_id, user_id: @sub_collection.user_id } }
    end

    assert_redirected_to sub_collection_url(SubCollection.last)
  end

  test "should show sub_collection" do
    get sub_collection_url(@sub_collection)
    assert_response :success
  end

  test "should get edit" do
    get edit_sub_collection_url(@sub_collection)
    assert_response :success
  end

  test "should update sub_collection" do
    patch sub_collection_url(@sub_collection), params: { sub_collection: { collection_id: @sub_collection.collection_id, user_id: @sub_collection.user_id } }
    assert_redirected_to sub_collection_url(@sub_collection)
  end

  test "should destroy sub_collection" do
    assert_difference("SubCollection.count", -1) do
      delete sub_collection_url(@sub_collection)
    end

    assert_redirected_to sub_collections_url
  end
end
