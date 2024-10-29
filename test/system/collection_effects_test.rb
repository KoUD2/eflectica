require "application_system_test_case"

class CollectionEffectsTest < ApplicationSystemTestCase
  setup do
    @collection_effect = collection_effects(:one)
  end

  test "visiting the index" do
    visit collection_effects_url
    assert_selector "h1", text: "Collection effects"
  end

  test "should create collection effect" do
    visit collection_effects_url
    click_on "New collection effect"

    fill_in "Collection", with: @collection_effect.collection_id
    fill_in "Effect", with: @collection_effect.effect_id
    click_on "Create Collection effect"

    assert_text "Collection effect was successfully created"
    click_on "Back"
  end

  test "should update Collection effect" do
    visit collection_effect_url(@collection_effect)
    click_on "Edit this collection effect", match: :first

    fill_in "Collection", with: @collection_effect.collection_id
    fill_in "Effect", with: @collection_effect.effect_id
    click_on "Update Collection effect"

    assert_text "Collection effect was successfully updated"
    click_on "Back"
  end

  test "should destroy Collection effect" do
    visit collection_effect_url(@collection_effect)
    click_on "Destroy this collection effect", match: :first

    assert_text "Collection effect was successfully destroyed"
  end
end
