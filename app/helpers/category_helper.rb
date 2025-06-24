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

  def category_images(category)
    case category
    when "photoProcessing"
      ["imageCategory2.png", "imageCategory3.png", "imageCategory1.png", "imageCategory4.png"]
    when "videoProcessing"
      ["imageCategory7.png", "imageCategory8.png", "imageCategory9.png", "imageCategory10.png"]
    when "3dGrafics"
      ["imageCategory11.png", "imageCategory12.png", "imageCategory13.png", "imageCategory14.png"]
    when "motion"
      ["imageCategory15.png", "imageCategory16.png", "imageCategory17.png", "imageCategory18.png"]
    when "animation"
      ["imageCategory19.png", "imageCategory20.png", "imageCategory21.png", "imageCategory22.png"]
    when "illustration"
      ["imageCategory23.png", "imageCategory24.png", "imageCategory25.png", "imageCategory26.png"]
    when "uiux"
      ["imageCategory27.png", "imageCategory28.png", "imageCategory29.png", "imageCategory30.png"]
    when "vfx"
      ["imageCategory31.png", "imageCategory32.png", "imageCategory33.png", "imageCategory34.png"]
    when "gamedev"
      ["imageCategory35.png", "imageCategory36.png", "imageCategory37.png", "imageCategory38.png"]
    when "arvr"
      ["imageCategory39.png", "imageCategory40.png", "imageCategory41.png", "imageCategory42.png"]
    else
      # Для неизвестных категорий используем базовый набор
      ["imageCategory2.png", "imageCategory3.png", "imageCategory1.png", "imageCategory4.png"]
    end
  end
end
