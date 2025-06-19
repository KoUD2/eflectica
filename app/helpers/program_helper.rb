module ProgramHelper
  PROGRAM_MAPPINGS = {
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

  PROGRAM_ICONS = {
    "photoshop" => "photoshop_icon.svg",
    "lightroom" => "lightroom_icon.svg",
    "after_effects" => "after_effects_icon.svg",
    "illustrator" => "illustrator_icon.svg",
    "premiere_pro" => "premiere_icon.svg",
    "blender" => "blender_icon.svg",
    "affinity_photo" => "affinity_photo_icon.svg",
    "capture_one" => "capture_one_icon.svg",
    "maya" => "maya_icon.svg",
    "cinema_4d" => "cinema_4d_icon.svg",
    "3ds_max" => "3ds_max_icon.svg",
    "zbrush" => "zbrush_icon.svg"
  }.freeze

  def human_readable_program(program)
    PROGRAM_MAPPINGS[program] || program.gsub('_', ' ').titleize
  end

  def program_icon(program)
    PROGRAM_ICONS[program]
  end
end 