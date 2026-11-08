-- ============================================
-- REGLAS DE VENTANAS
-- ============================================

-- ----- Zen Browser (workspace inicial en startup.sh) -----
-- idle_inhibit: no bloquear pantalla mientras Zen esté en pantalla completa (videos)
hl.window_rule({ match = { class = "^(zen)$" }, opacity = "0.9", idle_inhibit = "fullscreen" })

-- ----- YouTube Music (workspace inicial en startup.sh) -----
hl.window_rule({ match = { class = "^(com.github.th-ch.youtube-music)$" }, opacity = "0.9" })

-- ----- Discord (workspace inicial en startup.sh) -----
hl.window_rule({ match = { class = "^(discord)$" }, opacity = "0.9" })

-- ----- Scratchpad -----
hl.window_rule({
    match     = { class = "^(scratchpad)$" },
    workspace = "special:scratch silent",
    float     = true,
    size      = { 900, 520 },
    center    = true,
    opacity   = "0.92",
})

-- ----- Dolphin -----
hl.window_rule({ match = { class = "^(dolphin)$" }, decorate = false })

-- pavucontrol (clic derecho en el volumen de waybar): ventana flotante centrada
hl.window_rule({
    match  = { class = "^(org.pulseaudio.pavucontrol)$" },
    float  = true,
    size   = { 900, 600 },
    center = true,
})
