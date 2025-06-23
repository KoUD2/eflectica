module ProgramHelper
  PROGRAM_MAPPINGS = {
    "photoshop" => "Photoshop",
    "lightroom" => "Lightroom",
    "after_effects" => "After Effects",
    "premiere_pro" => "Premiere Pro",
    "blender" => "Blender",
    "affinity_photo" => "Affinity Photo",
    "capture_one" => "Capture One",
    "maya" => "Maya",
    "cinema_4d" => "Cinema 4D",
    "3ds_max" => "3ds Max",
    "zbrush" => "ZBrush",
    "unreal" => "Unreal Engine",
    "davinci" => "DaVinci Resolve",
    "substance" => "Substance Painter",
    "protopie" => "ProtoPie",
    "krita" => "Krita",
    "animate" => "Adobe Animate",
    "figma" => "Figma",
    "clip" => "Clip Studio Paint",
    "nuke" => "Nuke",
    "fc" => "Final Cut Pro",
    "procreate" => "Procreate",
    "godot" => "Godot",
    "lens" => "Lens Studio",
    "rive" => "Rive",
    "unity" => "Unity",
    "spark" => "Spark AR",
    "spine" => "Spine",
    "toon" => "Toon Boom Harmony"
  }.freeze

  PROGRAM_ICONS = {
    "photoshop" => "photoshop_icon.svg",
    "lightroom" => "lightroom_icon.svg",
    "after_effects" => "after_effects_icon.svg",
    "premiere_pro" => "premiere_icon.svg",
    "blender" => "blender_icon.svg",
    "affinity_photo" => "affinity_photo_icon.svg",
    "capture_one" => "capture_one_icon.svg",
    "maya" => "maya_icon.svg",
    "cinema_4d" => "cinema_4d_icon.svg",
    "3ds_max" => "3ds_max_icon.svg",
    "zbrush" => "zbrush_icon.svg",
    "unreal" => "unreal_icon.svg",
    "davinci" => "davinci_icon.svg",
    "substance" => "substance_icon.svg",
    "protopie" => "protopie_icon.svg",
    "krita" => "krita_icon.svg",
    "sketch" => "sketch_icon.svg",
    "animate" => "animate_icon.svg",
    "figma" => "figma_icon.svg",
    "clip" => "clip_icon.svg",
    "nuke" => "nuke_icon.svg",
    "fc" => "fc_icon.svg",
    "procreate" => "procreate_icon.svg",
    "godot" => "godot_icon.svg",
    "lens" => "lens_icon.svg",
    "rive" => "rive_icon.svg",
    "unity" => "unity_icon.svg",
    "spark" => "spark_icon.svg",
    "spine" => "spine_icon.svg",
    "toon" => "toon_icon.svg"
  }.freeze

  def human_readable_program(program)
    PROGRAM_MAPPINGS[program] || program.gsub('_', ' ').titleize
  end

  def program_icon(program)
    PROGRAM_ICONS[program]
  end
end 