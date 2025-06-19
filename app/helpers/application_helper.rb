module ApplicationHelper
	def resource_name
    :user
  end

  def resource
    @resource ||= User.new
  end

  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end

  def programs
    {
      "photoshop" => "photoshop_icon.svg",
      "lightroom" => "lightroom_icon.svg",
      "after_effects" => "after_effects_icon.svg",
      "illustrator" => "illustrator_icon.svg",
      "premiere_pro" => "premiere_icon.svg",
      "after_effects" => "after_effects_icon.svg",
      "blender" => "blender_icon.svg",
      "affinity_photo" => "affinity_photo_icon.svg",
      "capture_one" => "capture_one_icon.svg",
      "maya" => "maya_icon.svg",
      "cinema_4d" => "cinema_4d_icon.svg",
      "3ds_max" => "3ds_max_icon.svg",
      "zbrush" => "zbrush_icon.svg"
    }.freeze
  end

  def platforms
    {
      "windows" => "windows_icon.svg",
      "mac" => "mac_icon.svg"
    }.freeze
  end

  def human_readable_program(program)
    program_mappings = {
      "photoshop" => "Photoshop",
      "lightroom" => "Lightroom",
      "after_effects" => "After Effects",
      "illustrator" => "Illustrator",
      "premiere_pro" => "Premiere Pro",
      "blender" => "Blender",
      "affinity_photo" => "Affinity Photo",
      "capture_one" => "Capture One",
      "maya" => "Maya",
      "cinema_4d" => "Cinema 4D",
      "3ds_max" => "3ds Max",
      "zbrush" => "ZBrush"
    }.freeze
    
    program_mappings[program] || program.gsub('_', ' ').titleize
  end
end
