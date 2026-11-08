-- ============================================
-- VARIABLES DE ENTORNO
-- ============================================

hl.env("XDG_SESSION_TYPE",    "wayland")
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")

-- NVIDIA
hl.env("LIBVA_DRIVER_NAME",         "nvidia")
hl.env("GBM_BACKEND",               "nvidia-drm")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")

-- Kvantum
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
hl.env("QT_STYLE_OVERRIDE",    "kvantum")
