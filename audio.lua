SOUND_hitmarker = love.audio.newSource("resources/audio/hitmarker.mp3", "static")
SOUND_intervention = love.audio.newSource("resources/audio/intervention.mp3", "static")
SOUND_airhorn = love.audio.newSource("resources/audio/airhorn.wav", "static")

SOUND_omg = love.audio.newSource("resources/audio/oh_my_god.wav", "static")

SOUND_omfg = love.audio.newSource("resources/audio/omfg.wav", "static")

SOUND_dota = love.audio.newSource("resources/audio/dota.wav", "static")
SOUND_camera = love.audio.newSource("resources/audio/camera.wav", "static")
SOUND_triple = love.audio.newSource("resources/audio/triple.wav", "static")

MUSIC_violin = love.audio.newSource("resources/audio/violin.wav")
MUSIC_sandstorm = love.audio.newSource("resources/audio/sandstorm.mp3")
MUSIC_weed = love.audio.newSource("resources/audio/weed.wav")

MUSIC_sandstorm:setLooping(true)

ONE_ROW_AUDIO = {SOUND_omg}
TWO_ROW_AUDIO = {SOUND_omfg, SOUND_dota}
THREE_ROW_AUDIO = {SOUND_camera}