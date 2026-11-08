-- ============================================
-- ATAJOS DE TECLADO
-- ============================================

local mod = "SUPER"
local function k(keys) return mod .. " + " .. keys end

-- ------------------- Sistema -------------------
hl.bind(k("SHIFT + M"), hl.dsp.exit())
hl.bind(k("W"),         hl.dsp.window.float({ action = "toggle" }))
hl.bind(k("Q"),         hl.dsp.window.close())
hl.bind(k("F"),         hl.dsp.window.fullscreen({ mode = "fullscreen" }))

-- ------------------- Lanzadores -------------------
hl.bind(k("Return"), hl.dsp.exec_cmd("alacritty"))
hl.bind(k("D"),      hl.dsp.exec_cmd("wofi --show drun"))
hl.bind(k("V"),      hl.dsp.exec_cmd("cliphist list | wofi --dmenu | cliphist decode | wl-copy"))
hl.bind(k("C"),      hl.dsp.exec_cmd("kitty --title claude-code -e ~/.local/bin/claude"))

-- ------------------- Scratchpad -------------------
hl.bind(k("space"),         hl.dsp.exec_cmd("~/.config/hypr/toggle-scratch.sh"))
hl.bind(k("SHIFT + space"), hl.dsp.window.move({ workspace = "special:scratch", follow = false }))

-- ------------------- Workspaces -------------------
for i = 1, 8 do
    hl.bind(k(tostring(i)),            hl.dsp.focus({ workspace = i }))
    -- Mover ventana a workspace (y seguirla)
    hl.bind(k("SHIFT + " .. i),        hl.dsp.window.move({ workspace = i, follow = true }))
end

hl.bind(k("right"), hl.dsp.focus({ workspace = "e+1" }))
hl.bind(k("left"),  hl.dsp.focus({ workspace = "e-1" }))

-- ------------------- Movimiento de ventanas -------------------
hl.bind(k("mouse:272"), hl.dsp.window.drag(),   { mouse = true })
hl.bind(k("mouse:273"), hl.dsp.window.resize(), { mouse = true })

-- ------------------- Multimedia -------------------
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("pamixer -i 5"))
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("pamixer -d 5"))
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("pamixer -t"))
hl.bind("XF86AudioPlay",        hl.dsp.exec_cmd("playerctl play-pause"))
hl.bind("XF86AudioPause",       hl.dsp.exec_cmd("playerctl play-pause"))
hl.bind("XF86AudioNext",        hl.dsp.exec_cmd("playerctl next"))
hl.bind("XF86AudioPrev",        hl.dsp.exec_cmd("playerctl previous"))

-- Brillo
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl set +5%"))
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 5%-"))

-- Screenshots
hl.bind(k("P"), hl.dsp.exec_cmd("flameshot gui"))

-- ------------------- Presentación / Proyector -------------------
-- Espejo en cualquier monitor externo (detecta nombre, usa modo nativo y pausa hypridle)
-- El espejo se activa solo al conectar (auto-mirror-projector.sh) y sobrevive a un reload
hl.bind(k("ALT + P"), hl.dsp.exec_cmd("~/.config/hypr/scripts/mirror-manual.sh"))

-- Volver al modo extendido normal
hl.bind(k("ALT + O"), hl.dsp.exec_cmd("~/.config/hypr/scripts/extend-manual.sh"))
