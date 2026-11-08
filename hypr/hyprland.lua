-- ============================================
-- ARCHIVO PRINCIPAL DE HYPRLAND (Lua, 0.57+)
-- Migrado desde hyprland.conf (backup en backup/pre-lua-0.57/)
-- ============================================

-- Importar configuraciones modulares (~/.config/hypr/*.lua)
require("env")
require("monitors")
require("binds")
require("windows-rules")

-- Ejecutar scripts al inicio (equivalente a exec-once)
hl.on("hyprland.start", function()
    hl.exec_cmd("~/.config/hypr/startup.sh")
    -- hl.exec_cmd("~/.config/waybar/scripts/bluetooth-scan-daemon.sh")  -- desactivado: escanear sin parar rompe las conexiones
    hl.exec_cmd("~/.config/hypr/scripts/auto-mirror-projector.sh")
    hl.exec_cmd("udiskie -t")
end)

-- Configuración general
hl.config({
    general = {
        gaps_in          = 5,
        gaps_out         = 20,
        border_size      = 2,
        col = {
            active_border   = "rgba(0055ffff)",
            inactive_border = "rgba(0033aaff)",
        },
        resize_on_border = true,
        layout           = "dwindle",
    },

    input = {
        kb_layout    = "us,latam",
        kb_options   = "grp:alt_shift_toggle",
        follow_mouse = 1,
        touchpad = {
            natural_scroll = false,
        },
    },

    decoration = {
        rounding         = 10,
        active_opacity   = 1.0,
        inactive_opacity = 1.0,

        shadow = {
            enabled      = true,
            range        = 12,
            render_power = 3,
            color        = "rgba(0055ff66)",
        },

        blur = {
            enabled           = true,
            size              = 5,
            passes            = 2,
            new_optimizations = true,
            xray              = false,
        },
    },

    animations = {
        enabled = true,
    },
})

-- Curvas
hl.curve("snappy",   { type = "bezier", points = { {0.25, 1.0}, {0.5, 1.0}  } })
hl.curve("overshot", { type = "bezier", points = { {0.05, 0.9}, {0.1, 1.05} } })
hl.curve("linear",   { type = "bezier", points = { {0.0, 0.0},  {1.0, 1.0}  } })

-- Animaciones
hl.animation({ leaf = "windows",          enabled = true, speed = 4, bezier = "overshot", style = "slide" })
hl.animation({ leaf = "windowsOut",       enabled = true, speed = 3, bezier = "snappy",   style = "popin 80%" })
hl.animation({ leaf = "windowsMove",      enabled = true, speed = 3, bezier = "snappy" })
hl.animation({ leaf = "border",           enabled = true, speed = 6, bezier = "linear" })
hl.animation({ leaf = "fade",             enabled = true, speed = 4, bezier = "snappy" })
hl.animation({ leaf = "workspaces",       enabled = true, speed = 4, bezier = "snappy",   style = "slide" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 4, bezier = "snappy",   style = "slidevert" })
