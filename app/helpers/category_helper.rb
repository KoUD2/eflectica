module CategoryHelper
  CATEGORY_MAPPINGS = {
    "photoProcessing" => "Обработка фото",
    "3dGrafics" => "3D-графика",
    "motion" => "Моушен",
    "illustration" => "Иллюстрация",
    "animation" => "Анимация",
    "uiux" => "UI/UX-анимация",
    "videoProcessing" => "Обработка видео",
    "vfx" => "VFX",
    "gamedev" => "Геймдев",
    "arvr" => "AR & VR"
  }.freeze

  def human_readable_category(category)
    CATEGORY_MAPPINGS[category] || category
  end
end
