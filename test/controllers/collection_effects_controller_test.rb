require "test_helper"

class CollectionEffectsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @collection_effect = collection_effects(:one)
  end

  test "should get index" do
    get collection_effects_url
    assert_response :success
  end

  test "should get new" do
    get new_collection_effect_url
    assert_response :success
  end

  test "should create collection_effect" do
    assert_difference("CollectionEffect.count") do
      post collection_effects_url, params: { collection_effect: { collection_id: @collection_effect.collection_id, effect_id: @collection_effect.effect_id } }
    end

    assert_redirected_to collection_effect_url(CollectionEffect.last)
  end

  test "should show collection_effect" do
    get collection_effect_url(@collection_effect)
    assert_response :success
  end

  test "should get edit" do
    get edit_collection_effect_url(@collection_effect)
    assert_response :success
  end

  test "should update collection_effect" do
    patch collection_effect_url(@collection_effect), params: { collection_effect: { collection_id: @collection_effect.collection_id, effect_id: @collection_effect.effect_id } }
    assert_redirected_to collection_effect_url(@collection_effect)
  end

  test "should destroy collection_effect" do
    assert_difference("CollectionEffect.count", -1) do
      delete collection_effect_url(@collection_effect)
    end

    assert_redirected_to collection_effects_url
  end
end
