# Legacy NVIDIA GPU Setup

wired-dots v1.0.0-rc1 does not automatically install drivers for legacy NVIDIA
GPU generations (Maxwell, Pascal, Fermi, Kepler). These require AUR packages
that take significant time to build.

## Supported Automatically

- Turing (RTX 20xx) and newer → `nvidia-open` + `nvidia-utils`

## Manual Setup Required

### Maxwell / Pascal (GTX 900–10xx series)

```bash
yay -S nvidia-470xx-dkms nvidia-470xx-utils nvidia-470xx-settings
```

### Fermi / Kepler (GTX 400–700 series)

```bash
yay -S nvidia-390xx-dkms nvidia-390xx-utils nvidia-390xx-settings
```

After installing, add these kernel params to your bootloader:
```
nvidia_drm.modeset=1
```

Then rebuild initramfs: `sudo mkinitcpio -P`
