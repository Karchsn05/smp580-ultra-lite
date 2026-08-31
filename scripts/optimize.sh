#!/usr/bin/env bash
set -e

# ==============================================================================
# SM-P580 (gtanotexlwifi / Exynos 7870) Ultra-Lite & iOS-Tuned Optimization Core
# ==============================================================================

TARGET_DIR="$1"

if [ -z "$TARGET_DIR" ] || [ ! -d "$TARGET_DIR" ]; then
    echo "[!] Hata: Hedef dizin belirtilmedi veya bulunamadi!"
    exit 1
fi

echo "=================================================================="
echo ">> SM-P580 'iOS-Tuned Ultra-Lite' Optimizasyon Islemleri Basliyor..."
echo ">> Hedef Dizin: $TARGET_DIR"
echo "=================================================================="

# 1. DEBLOAT (Gereksiz, RAM sömüren arka plan servislerini ve uygulamalari temizleme)
DEBLOAT_LIST=(
    "app/GoogleFeedback"
    "app/Gmail2"
    "app/Maps"
    "app/YouTube"
    "app/Music2"
    "app/Videos"
    "app/Chrome"
    "app/PrintSpooler"
    "app/Stk"
    "app/PacProcessor"
    "app/WAPPushManager"
    "app/GalaxyPencil"
    "app/BasicDreams"
    "app/LiveWallpapersPicker"
    "app/Trebuchet"
    "priv-app/TrebuchetQuickStep"
    "priv-app/Velvet"
    "priv-app/GooglePartnerSetup"
    "priv-app/SetupWizard"
    "priv-app/Feedback"
    "priv-app/Help"
    "priv-app/SharedStorageBackup"
    "priv-app/BackupRestoreConfirmation"
)

echo "[*] [1/6] Debloat yapiliyor: RAM tuketen uygulamalar kaldiriliyor..."
for item in "${DEBLOAT_LIST[@]}"; do
    if [ -d "$TARGET_DIR/$item" ]; then
        echo "  - Silindi: $item"
        rm -rf "$TARGET_DIR/$item"
    fi
    if [ -d "$TARGET_DIR/system/$item" ]; then
        echo "  - Silindi: system/$item"
        rm -rf "$TARGET_DIR/system/$item"
    fi
done

# 2. MICROG PRIVAPP PERMISSIONS (Imza Sahteleme & Tam Yetkilendirme)
echo "[*] [2/6] microG privapp-permissions XML dosyalari olusturuluyor..."
PERM_DIR="$TARGET_DIR/etc/permissions"
if [ ! -d "$PERM_DIR" ]; then
    PERM_DIR="$TARGET_DIR/system/etc/permissions"
fi
mkdir -p "$PERM_DIR" 2>/dev/null || true

cat << 'EOF' > "$PERM_DIR/privapp-permissions-com.google.android.gms.xml"
<?xml version="1.0" encoding="utf-8"?>
<permissions>
    <privapp-permissions package="com.google.android.gms">
        <permission name="android.permission.FAKE_PACKAGE_SIGNATURE"/>
        <permission name="android.permission.WRITE_SECURE_SETTINGS"/>
        <permission name="android.permission.INSTALL_LOCATION_PROVIDER"/>
        <permission name="android.permission.UPDATE_APP_OPS_STATS"/>
        <permission name="android.permission.UPDATE_DEVICE_STATS"/>
        <permission name="android.permission.PACKAGE_USAGE_STATS"/>
        <permission name="android.permission.ACCESS_COARSE_LOCATION"/>
        <permission name="android.permission.ACCESS_FINE_LOCATION"/>
        <permission name="android.permission.ACCESS_BACKGROUND_LOCATION"/>
        <permission name="android.permission.CHANGE_DEVICE_IDLE_TEMP_WHITELIST"/>
    </privapp-permissions>
</permissions>
EOF

cat << 'EOF' > "$PERM_DIR/privapp-permissions-com.android.vending.xml"
<?xml version="1.0" encoding="utf-8"?>
<permissions>
    <privapp-permissions package="com.android.vending">
        <permission name="android.permission.FAKE_PACKAGE_SIGNATURE"/>
        <permission name="android.permission.INSTALL_PACKAGES"/>
        <permission name="android.permission.DELETE_PACKAGES"/>
    </privapp-permissions>
</permissions>
EOF

# 3. SYSTEM-LEVEL ADBLOCK (Reklam ve Takipci Engelleme)
echo "[*] [3/6] Web sitelerini 2 kat hizlandiracak sistem hosts dosyasi ekleniyor..."
HOSTS_PATH="$TARGET_DIR/etc/hosts"
if [ ! -f "$HOSTS_PATH" ]; then
    HOSTS_PATH="$TARGET_DIR/system/etc/hosts"
fi

if [ -d "$(dirname "$HOSTS_PATH")" ]; then
    cat << 'EOF' > "$HOSTS_PATH"
127.0.0.1 localhost
::1 localhost
0.0.0.0 ads.google.com
0.0.0.0 pagead2.googlesyndication.com
0.0.0.0 adservice.google.com
0.0.0.0 doubleclick.net
0.0.0.0 googleads.g.doubleclick.net
0.0.0.0 analytics.google.com
0.0.0.0 app-measurement.com
0.0.0.0 telemetry.samsung.com
EOF
    echo "  + hosts dosyasina hafif reklam engelleyici eklendi."
fi

# 4. BUILD.PROP TUNING (SkiaGL GPU + iOS Dokunma Onceligi + LMKD + Masaustu Modu)
echo "[*] [4/6] build.prop ayarlari yapilandiriliyor..."

BUILD_PROP="$TARGET_DIR/build.prop"
if [ ! -f "$BUILD_PROP" ]; then
    BUILD_PROP="$TARGET_DIR/system/build.prop"
fi

if [ -f "$BUILD_PROP" ]; then
    cat << 'EOF' >> "$BUILD_PROP"

# ==============================================================================
# SM-P580 (Exynos 7870 / Mali-T830) ULTRA-LITE & IOS-TUNED TWEAKS
# ==============================================================================

# --- [1] Mali-T830 SkiaGL & SurfaceFlinger Donanim Hizlandirma ---
debug.hwui.renderer=skiagl
debug.sf.hw=1
debug.egl.hw=1
debug.egl.profiler=0
video.accelerate.hw=1
persist.sys.ui.hw=1
renderthread.priority=1
debug.hwui.render_dirty_regions=false

# --- [2] iOS Benzeri Dokunmatik Tepkiselligi & Akici Kaydirma ---
sys.use_fifo_ui=1
windowsmgr.max_events_per_sec=180
view.touch_slop=2
view.scroll_friction=0.004
persist.sys.scrollingcache=3
touch.pressure.scale=0.001

# --- [3] Düşük RAM, LMKD & Arka Plan Yonetimi (2GB/3GB Optimize) ---
ro.config.low_ram=false
ro.sys.fw.bg_apps_limit=16
persist.sys.purgeable_assets=1
ro.HOME_APP_ADJ=1

# LMKD Klasik Minfree Seviyeleri
ro.lmk.use_minfree_levels=true
ro.lmk.swap_free_low_percentage=10
ro.lmk.thrashing_limit=30
ro.lmk.thrashing_limit_decay=50

# --- [4] Masaustu Pencereli Mod (AOSP Freeform Windows) ---
enable_freeform_support=1
force_resizable_activities=1
persist.sys.freeform_window=1

# --- [5] Animasyon Hızlandırma & CPU Tasarrufu ---
logcat.live=disable
profiler.force_disable_ulog=1
profiler.force_disable_err_rpt=1
EOF
    echo "  + build.prop basariyla guncellendi."
fi

# 5. A2 V30 MICROSD + ZRAM ONCELIKLI CIFT KATMANLI SWAP MIMARISI
echo "[*] [5/6] A2 V30 MicroSD + ZRAM dual-swap init yapilandirmasi hazirlaniyor..."
INIT_D_DIR="$TARGET_DIR/etc/init.d"
if [ ! -d "$INIT_D_DIR" ]; then
    INIT_D_DIR="$TARGET_DIR/system/etc/init.d"
fi

mkdir -p "$INIT_D_DIR" 2>/dev/null || true
if [ -d "$INIT_D_DIR" ]; then
    cat << 'EOF' > "$INIT_D_DIR/99dual_swap"
#!/system/bin/sh
# SM-P580 Dual Layer Memory Architecture:
# Katman 1: ZRAM (LZ4) - Oncelik: 32767 (Yuksek hiz, RAM ici)
# Katman 2: A2 V30 MicroSD Swapfile - Oncelik: 10 (Sadece ZRAM dolunca devreye girer)

# 1. ZRAM Yapilandirmasi
if [ -e /sys/block/zram0/disksize ]; then
    swapoff /dev/block/zram0 2>/dev/null || true
    echo 1536M > /sys/block/zram0/disksize
    mkswap /dev/block/zram0 2>/dev/null
    swapon /dev/block/zram0 -p 32767 2>/dev/null
fi

# 2. A2 MicroSD Kart Swapfile Yapilandirmasi (Varsa)
SD_SWAP="/storage/sdcard1/.swap/swapfile"
if [ -f "$SD_SWAP" ]; then
    chmod 600 "$SD_SWAP"
    swapon "$SD_SWAP" -p 10 2>/dev/null
fi

# 3. Kernel Sysctl Parametreleri (TBW Koruma & Sifir Takilma)
echo 90 > /proc/sys/vm/swappiness
echo 100 > /proc/sys/vm/vfs_cache_pressure
echo 10 > /proc/sys/vm/dirty_ratio
echo 5 > /proc/sys/vm/dirty_background_ratio
echo 0 > /proc/sys/vm/page-cluster

# 4. In-Kernel Minfree Parametreleri (~400MB Bosta RAM Hedefi)
if [ -e /sys/module/lowmemorykiller/parameters/minfree ]; then
    echo "18432,23040,27648,32256,73728,102400" > /sys/module/lowmemorykiller/parameters/minfree
fi
EOF
    chmod 755 "$INIT_D_DIR/99dual_swap" 2>/dev/null || true
    echo "  + ZRAM (prio 32767) ve SD Swap (prio 10) scripti eklendi."
fi

echo "=================================================================="
echo ">> [6/6] Tum optimizasyonlar basariyla tamamlandi!"
echo "=================================================================="
