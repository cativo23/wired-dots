-- wired-dots — NVIDIA-specific Hyprland settings (Lua port of nvidia.conf)
-- Deployed by 04b_gpu_nvidia.sh. dofile'd with pcall guard in hyprland.lua
-- (equivalent of the old "hyprlang noerror true" source guard) since this
-- file only exists on NVIDIA machines.
-- Based on: https://wiki.hyprland.org/Nvidia/

hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
hl.env("NVD_BACKEND", "direct")
hl.env("GBM_BACKEND", "nvidia-drm")

hl.config({
    cursor = {
        no_hardware_cursors = true,
    },
    render = {
        explicit_sync     = 2,
        explicit_sync_kms = 2,
    },
})
