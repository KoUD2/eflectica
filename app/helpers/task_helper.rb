module TaskHelper
  TASK_MAPPINGS = {
    "portraitRetouching" => "Ретушь портрета",
    "colorCorrection" => "Цветокоррекция",
    "improvePhotoQuality" => "Улучшить качество фото",
    "preparationForPrinting" => "Подготовка к печати",
    "socialMediaContent" => "Контент для соцсетей",
    "advertisingProcessing" => "Рекламная обработка",
    "stylization" => "Стилизация",
    "backgroundEditing" => "Редактирование фона",
    "graphicContent" => "Графический контент",
    "setLight" => "Настройка света",
    "simulation3d" => "Симуляция 3D",
    "atmosphereWeather" => "Атмосфера и погода"
  }.freeze

  def human_readable_task(task)
    TASK_MAPPINGS[task] || task
  end
end
