require "application_system_test_case"

class EffectsTest < ApplicationSystemTestCase
  setup do
    @effect = effects(:one)
  end

  test "visiting the index" do
    visit effects_url
    assert_selector "h1", text: "Effects"
  end

  test "should create effect" do
    visit effects_url
    click_on "New effect"

    fill_in "Description", with: @effect.description
    fill_in "Devices", with: @effect.devices
    fill_in "Img", with: @effect.img
    check "Is secure" if @effect.is_secure
    fill_in "Link to", with: @effect.link_to
    fill_in "Manual", with: @effect.manual
    fill_in "Name", with: @effect.name
    fill_in "Speed", with: @effect.speed
    fill_in "User", with: @effect.user_id
    click_on "Create Effect"

    assert_text "Effect was successfully created"
    click_on "Back"
  end

  test "should update Effect" do
    visit effect_url(@effect)
    click_on "Edit this effect", match: :first

    fill_in "Description", with: @effect.description
    fill_in "Devices", with: @effect.devices
    fill_in "Img", with: @effect.img
    check "Is secure" if @effect.is_secure
    fill_in "Link to", with: @effect.link_to
    fill_in "Manual", with: @effect.manual
    fill_in "Name", with: @effect.name
    fill_in "Speed", with: @effect.speed
    fill_in "User", with: @effect.user_id
    click_on "Update Effect"

    assert_text "Effect was successfully updated"
    click_on "Back"
  end

  test "should destroy Effect" do
    visit effect_url(@effect)
    click_on "Destroy this effect", match: :first

    assert_text "Effect was successfully destroyed"
  end
end
