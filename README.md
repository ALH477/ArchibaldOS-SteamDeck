# ArchibaldOS Steam Deck Edition

![DeMoD LLC Logo](modules/assets/demod-logo.png)

---

## Overview

**ArchibaldOS Steam Deck Edition** is a **specialized, minimal NixOS distribution** engineered for **real-time audio production** on the **Valve Steam Deck** (LCD and OLED models). It transforms the handheld into a **professional-grade, ultra-low-latency audio workstation** while preserving full gaming capability through **optional Steam Game Mode**.

Built on **Nix flakes** for **declarative, reproducible, and version-controlled configuration**, it follows a **"minimal oligarchy"** philosophy: one elite RT kernel, one low-latency audio stack, one purpose — **zero-glitch audio**.

---

## Key Features

| Category | Feature |
|--------|---------|
| **Real-Time Audio** | 32-sample PipeWire @ 48kHz, RT kernel, `threadirqs`, `isolcpus=1-3`, RTIRQ, DAS watchdog |
| **Audio Stack** | PipeWire (ALSA/JACK/Pulse), `pw-jack` drop-in, 32-bit float, low buffer |
| **Pro Audio Tools** | 30+ curated apps: Audacity, Zrythm, Carla, SuperCollider, CSound, Surge, Helm, Guitarix, Calf, Faust, Dragonfly Reverb |
| **Steam Deck Hardware** | Full APU (Van Gogh/Sephiroth), fan curves, TDP control (`ryzenadj`), touchscreen, controls, speakers, USB audio |
| **Desktop Environment** | KDE Plasma 6 (Wayland), SDDM, auto-login |
| **Installer** | Graphical Calamares with Disko support |
| **Optional Gaming** | Steam Game Mode, Gamescope, MangoHUD, Decky Loader |
| **Branding** | DeMoD LLC Plymouth splash, wallpapers, ASCII art |
| **Build Outputs** | Live ISO, direct NVMe image, dev shell |

---

## Use Cases

### 1. **Portable Music Production & Live Performance**
- **Scenario**: Electronic musician performing at a venue or recording in the field.
- **Workflow**:
  1. Boot from USB live ISO
  2. Connect USB audio interface (class-compliant)
  3. Launch **Zrythm**, **Carla**, or **SuperCollider**
  4. Achieve **<10ms round-trip latency** with 32-sample buffer
- **Benefits**:
  - RT kernel eliminates audio dropouts
  - No bloat — system stays responsive
  - Test setup before installing

### 2. **Game Audio Design & Soundtrack Prototyping**
- **Scenario**: Indie developer composing adaptive music for a game.
- **Workflow**:
  1. Enable `enableSteamUI = true`
  2. Boot into **Steam Game Mode**
  3. Test game with Proton
  4. Switch to **Plasma desktop** → edit in **Carla** or **Faust**
  5. Re-export and re-test
- **Benefits**:
  - Same device for **development + playtesting**
  - PipeWire routes game audio for real-time processing
  - TDP control extends battery life

### 3. **Audio Education & Workshops**
- **Scenario**: Teaching DAW basics, DSP, or generative audio.
- **Workflow**:
  1. Distribute **live USB ISOs**
  2. Students boot instantly into **Plasma + preloaded tools**
  3. Explore **Faust**, **CSound**, or **PureData** without setup
- **Benefits**:
  - **100% reproducible environment**
  - No installation required
  - Branded experience for professional workshops

### 4. **Embedded & Headless Audio Systems**
- **Scenario**: Interactive art installation or kiosk with generative sound.
- **Workflow**:
  1. Flash `deck-image` to internal NVMe
  2. Disable Steam UI
  3. Run **SuperCollider** or **CSound** headless
  4. Control via network or GPIO
- **Benefits**:
  - Watchdog ensures 24/7 stability
  - Low swappiness prevents memory thrashing
  - Declarative config via Nix

---

## System Requirements

| Component | Minimum | Recommended |
|---------|---------|-------------|
| **Device** | Steam Deck (LCD/OLED) | OLED with 16GB RAM |
| **CPU** | AMD Van Gogh/Sephiroth | — |
| **RAM** | 4GB | 8GB+ for heavy DAWs |
| **Storage** | 64GB NVMe or microSD | **256GB+ NVMe (recommended)** |
| **Audio Interface** | USB class-compliant | Low-latency (Focusrite, etc.) |

> **Note on microSD Boot**:  
> **Booting ArchibaldOS from a microSD card is fully supported and viable**, especially for non-destructive testing or portable setups. **All performance and latency benchmarks were conducted on high-speed microSD cards** (A2-rated, 100MB/s+ sustained) to prove the system's optimization prowess.  
>  
> **However, internal NVMe is strongly recommended** for production use due to:
> - **Faster boot times** (~8s vs ~25s)
> - **Lower I/O latency** under heavy DAW load
> - **Better thermal performance** (no SD card heat buildup)
> - **Reliability** in long sessions

---

## Installation Guide

### **Option 1: Live USB (Recommended)**
```bash
# Build ISO
nix build .#deck-iso

# Flash to USB
sudo dd if=result/iso/*.iso of=/dev/sdX bs=4M status=progress && sync
```

**Boot Instructions**:
1. Insert USB
2. Hold **Volume Down + Power** → Boot Manager
3. Select USB drive
4. Live Plasma session starts (auto-login as `nixos`)
5. Launch **Calamares** from desktop
6. Partition (EFI + root + swap), set password, install
7. Reboot → done

### **Option 2: Direct NVMe Flash (Replaces SteamOS)**
```bash
nix build .#deck-image
# Flash result/sd-image/*.img.gz with Balena Etcher or dd
```

> **Warning**: This **erases SteamOS**. Backup first.

### **Option 3: microSD Card Installation (Viable, Not Recommended for Production)**
- Use Calamares to install to **formatted microSD** (`/dev/mmcblk0`)
- **Performance**: Excellent for testing; **NVMe preferred** for final deployment

---

## Dual-Boot with SteamOS (Advanced)

**ArchibaldOS + SteamOS dual-boot** allows you to keep Valve's official **SteamOS** (for seamless Game Mode and updates) alongside **ArchibaldOS** (for ultra-low-latency RT audio production). Both OSes share the **internal NVMe** and **microSD card** for games/music libraries, with **systemd-boot** handling selection at startup.

### **Key Benefits**
| Feature | Benefit |
|---------|---------|
| **Shared Games** | Proton libraries on SteamOS `/home` accessible from ArchibaldOS |
| **RT Audio + Gaming** | ArchibaldOS for DAWs (32-sample latency); SteamOS for AAA titles |
| **microSD Sharing** | BTRFS-formatted card mounts automatically in both OSes |
| **Boot Selection** | Hold **Vol+** for menu; auto-default to SteamOS |
| **Updates Safe** | SteamOS A/B partitions untouched; ArchibaldOS declarative rebuilds |

**Warning**: Partitioning can cause data loss—**backup everything**. SteamOS updates may require boot repair (rare with systemd-boot).

### **Prerequisites**
| Item | Details |
|------|---------|
| **Backup** | Clone NVMe: `nix build .#deck-image` on another machine + `dd` to external SSD |
| **USB Drive** | 32GB+ for ArchibaldOS ISO |
| **microSD** | 256GB+ (BTRFS recommended for compression/sharing) |
| **External Display** | HDMI/USB-C dock **required** for partitioning (Deck screen limited) |
| **Keyboard** | USB for chroot/setup |

### **Step-by-Step Guide**

#### **1. Build & Boot ArchibaldOS Live ISO**
```bash
# On build machine
git clone <your-archibaldos-repo>
cd archibaldos-deck
nix build .#deck-iso
sudo dd if=result/iso/*.iso of=/dev/sdX bs=4M status=progress && sync
```
- Insert USB, hold **Vol- + Power** → Boot menu → Select USB
- Live Plasma boots (auto-login `nixos`). Connect external display/keyboard.

#### **2. Resize SteamOS Home Partition (Critical)**
```bash
# In live Plasma terminal
sudo steamos-readonly disable  # Unlock SteamOS (temporary)
lsblk  # Confirm /dev/nvme0n1p6 = Home (ext4)

# Install tools
sudo pacman -Syu gparted btrfs-progs

# Launch GParted (graphical)
sudo gparted /dev/nvme0n1

# Resize: Right-click p6 (Home) → Resize/Move → Shrink 100-200GB free space
# Apply → Close
```
- **Unmount if needed**: Right-click → Unmount
- **Safe shrink**: Leave ~300GB for SteamOS games; free ~150GB for ArchibaldOS
- Reboot to SteamOS (USB out, power cycle) → Verify SteamOS boots + games intact.

#### **3. Partition Free Space for ArchibaldOS**
Reboot to **ArchibaldOS USB**:
```bash
# Use Calamares (Graphical Installer) or manual:
sudo fdisk /dev/nvme0n1
# n (new) → p (primary) → Defaults for ESP extension (reuse SteamOS ESP!)
# +512M (ESP if needed, but reuse p1), +8G (swap), Remaining (root ext4)

# Format (share ESP!)
sudo mkfs.fat -F32 /dev/nvme0n1pX  # ESP (reuse p1!)
sudo mkswap /dev/nvme0n1pY
sudo mkfs.ext4 -L archibald /dev/nvme0n1pZ  # Root

# Mount & Install
sudo mount /dev/nvme0n1pZ /mnt
sudo mkdir -p /mnt/boot /mnt/home
sudo mount /dev/nvme0n1p1 /mnt/boot  # Shared ESP!
sudo swapon /dev/nvme0n1pY
```
- Run **Calamares**: Select free space → EFI + root + swap → Install.

#### **4. Chroot & Configure Dual-Boot**
```bash
# In live terminal post-partition
nixos-generate-config --root /mnt
# Edit /mnt/etc/nixos/hardware-configuration.nix: boot.loader.systemd-boot.enable = true;

# Mount binds
mount --types proc /proc /mnt/proc
mount --rbind /sys /mnt/sys
mount --rbind /set /mnt/set
mount --rbind /dev /mnt/dev
mount --rbind /run /mnt/run

chroot /mnt /run/current-system/sw/bin/bash
```
**In chroot**:
```bash
# Install bootloader (shares ESP with SteamOS)
bootctl --path=/boot install

# Add SteamOS entry (label from blkid)
cat >> /etc/nixos/configuration.nix <<EOF
boot.loader.entries."SteamOS" = {
  device = "/dev/nvme0n1p1";  # Shared ESP
  parameters = [ "root=UUID=STEAMOS_ROOT_UUID ro" ];  # From blkid /dev/nvme0n1p4 or p5
};
EOF

# Enable RT audio + Deck hardware
nixos-rebuild switch --flake .#archibaldOS-deck
exit  # Exit chroot
```
**blkid for SteamOS UUID**:
```bash
blkid | grep root  # Note active root (A/B)
```

#### **5. Format microSD for Sharing (BTRFS)**
- Insert microSD in live → GParted → Create single BTRFS partition → Label "GAMES"
```bash
sudo mkfs.btrfs -f -L GAMES /dev/mmcblk0p1
sudo mount /dev/mmcblk0p1 /mnt/sd
sudo btrfs subvolume create /mnt/sd/@games
sudo umount /mnt/sd
```
- Auto-mounts in both OSes (`/run/media/deck/GAMES`).

#### **6. Boot & Test**
- Reboot (USB out) → **systemd-boot menu** (auto 5s timeout to SteamOS)
- Hold **Vol+** for manual selection
- In ArchibaldOS: Verify RT audio (`qjackctl`), TDP (`ryzenadj`), games from shared `/run/media/deck/GAMES`

### **Post-Setup**
| Task | Command |
|------|---------|
| **SteamOS Default** | Edit `/boot/loader/loader.conf`: `default SteamOS` |
| **Shared Library** | Steam → Settings → Storage → Add `/run/media/deck/GAMES` |
| **Repair Boot** | Boot USB → `bootctl --path=/boot install` |
| **SteamOS Update** | Auto-safe; re-chroot if bootloader conflicts |
| **Toggle Modes** | ArchibaldOS: `archibaldOS.enableSteamUI = true;` → rebuild |

---

## Virtualization: ArchibaldVM (IoMMU Passthrough)

> **Recommended**: For **maximum performance and isolation**, deploy **ArchibaldOS as a VM** using **QEMU/KVM with IoMMU passthrough** on a host running **ArchibaldVM** (a minimal NixOS VM host derived from ArchibaldOS).

### **Why Headless + IoMMU?**
- **Zero overhead**: Full GPU/USB/audio passthrough
- **Isolation**: RT audio unaffected by host
- **Optimized**: Calamares **headless install** mode (no display server) reduces latency

### **Headless Install in Calamares**
1. Boot live ISO
2. At login: Press **Ctrl+Alt+F3** → TTY3
3. Run:
   ```bash
   sudo calamares -D8 --headless
   ```
4. Follow text prompts: Partition, users, install
5. Reboot into **headless RT audio VM**

**ArchibaldVM Host Config** (future release):
```nix
virtualisation.libvirtd.enable = true;
hardware.iommu.enable = true;
boot.kernelParams = [ "amd_iommu=on" ];
```

---

## Post-Install Configuration

Edit `/etc/nixos/flake.nix` or your local config:

```nix
archibaldOS = {
  enableRTAudio = true;   # Default: full RT stack
  enableSteamUI = false;  # Set to true for Game Mode
  enableHeadless = false; # Set to true for max RT (no desktop)
};
```

Apply changes:
```bash
sudo nixos-rebuild switch
```

---

## Usage & Commands

| Task | Command |
|------|---------|
| **Switch to Desktop** | `systemctl --user start plasma-session.target` |
| **Switch to Game Mode** | `systemctl --user start gamescope-session.target` |
| **Set TDP to 15W** | `ryzenadj --tgp=15` |
| **Check RT Priority** | `rtirq status` |
| **Start JACK** | `pw-jack qjackctl` |
| **Test Latency** | Run `/etc/live-audio-test.sh` (if present) |
| **Enable Decky Loader** | `jovian.decky-loader.enable = true;` |

---

## Directory Structure

```
archibaldos-deck/
├── flake.nix                  # Main configuration
├── README.md                  # This file
├── modules/
│   ├── audio.nix              # RT audio stack (optional)
│   ├── desktop.nix            # KDE Plasma 6
│   ├── users.nix              # User accounts
│   ├── branding.nix           # DeMoD LLC branding
│   └── assets/
│       ├── demod-wallpaper.jpg
│       ├── demod-logo.png
│       └── wallpaper.jpg
└── scripts/
    └── live-audio-test.sh     # Optional latency demo
```

---

## Troubleshooting

| Issue | Solution |
|------|----------|
| **High latency** | Check `cat /proc/interrupts` for IRQ conflicts; adjust `isolcpus` |
| **No sound** | `systemctl --user restart pipewire` |
| **Fan too loud** | Jovian auto-controls; override with `ryzenadj` |
| **Build fails** | Ensure `allowUnfree = true` and `permittedInsecurePackages` |
| **Steam UI not starting** | Rebuild with `enableSteamUI = true` |
| **Slow SD boot** | Use NVMe for production; SD only for testing |

---

## Contributing

1. Fork the repository
2. Make changes (focus: RT audio, Deck hardware, minimalism)
3. Submit PR with clear description
4. Include logs if reporting issues

---

## License

```
MIT License
```

**DeMoD LLC Branding Assets** (logos, wallpapers, splash) are **proprietary**.  
Contact [@DeMoDLLC](https://x.com/DeMoDLLC) for commercial licensing.

---

## Credits & Acknowledgments

- **NixOS** – Declarative Linux
- **Musnix** – Real-time audio on Nix
- **Jovian-NixOS** – Steam Deck hardware support
- **Valve** – Steam Deck platform
- **KDE** – Plasma 6 desktop

---

**Built by DeMoD LLC**  
**Version**: NixOS 24.11  
**Updated**: November 2025  
**X**: [@DeMoDLLC](https://x.com/DeMoDLLC)

---

> **ArchibaldOS: Where audio meets precision. On a handheld.**
