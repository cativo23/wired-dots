-- wired-dots — NVIDIA-specific Hyprland settings (Lua port of nvidia.conf)
-- Deployed by 04b_gpu_nvidia.sh. dofile'd with pcall guard in hyprland.lua
-- (equivalent of the old "hyprlang noerror true" source guard) since this
-- file only exists on NVIDIA machines.
-- Based on: https://wiki.hyprland.org/Nvidia/

hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
hl.env("NVD_BACKEND", "direct")
hl.env("GBM_BACKEND", "nvidia-drm")

-- render:explicit_sync / render:explicit_sync_kms from the original
-- nvidia.conf DO NOT EXIST in this Hyprland build (verified against
-- /usr/bin/Hyprland's own string table — neither key appears at all,
-- under any section). Explicit sync is presumably automatic/no longer
-- user-configurable as of this version. Dropped rather than guessed at;
-- the upstream nvidia.conf should get the same fix.
hl.config({
    cursor = {
        no_hardware_cursors = true,
    },
})
