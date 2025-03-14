require "test_helper"

class EffectsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @effect = effects(:one)
  end

  test "should get index" do
    get effects_url
    assert_response :success
  end

  test "should get new" do
    get new_effect_url
    assert_response :success
  end

  test "should create effect" do
    assert_difference("Effect.count") do
      post effects_url, params: { effect: { description: @effect.description, platform: @effect.platform, img: @effect.img, is_secure: @effect.is_secure, link_to: @effect.link_to, manual: @effect.manual, name: @effect.name, speed: @effect.speed, user_id: @effect.user_id } }
    end

    assert_redirected_to effect_url(Effect.last)
  end

  test "should show effect" do
    get effect_url(@effect)
    assert_response :success
  end

  test "should get edit" do
    get edit_effect_url(@effect)
    assert_response :success
  end

  test "should update effect" do
    patch effect_url(@effect), params: { effect: { description: @effect.description, platform: @effect.platform, img: @effect.img, is_secure: @effect.is_secure, link_to: @effect.link_to, manual: @effect.manual, name: @effect.name, speed: @effect.speed, user_id: @effect.user_id } }
    assert_redirected_to effect_url(@effect)
  end

  test "should destroy effect" do
    assert_difference("Effect.count", -1) do
      delete effect_url(@effect)
    end

    assert_redirected_to effects_url
  end
end
