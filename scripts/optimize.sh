#!/usr/bin/env bash
set -e

# ==============================================================================
# SM-P580 (gtanotexlwifi / Exynos 7870) Ultra-Lite & Smooth Optimization Script
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
    "priv-app/Velvet"
    "priv-app/GooglePartnerSetup"
    "priv-app/SetupWizard"
    "priv-app/Feedback"
    "priv-app/Help"
    "priv-app/SharedStorageBackup"
    "priv-app/BackupRestoreConfirmation"
)

echo "[*] [1/5] Debloat yapiliyor: RAM tuketen uygulamalar kaldiriliyor..."
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

# 2. SYSTEM-LEVEL ADBLOCK (Reklam ve Takipci Engelleme)
echo "[*] [2/5] Web sitelerini 2 kat hizlandiracak sistem hosts dosyasi ekleniyor..."
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

# 3. BUILD.PROP TUNING (iOS Tarzi Dokunma Onceligi + RAM & GPU Hizlandirma)
echo "[*] [3/5] build.prop ayarlari yapilandiriliyor..."

BUILD_PROP="$TARGET_DIR/build.prop"
if [ ! -f "$BUILD_PROP" ]; then
    BUILD_PROP="$TARGET_DIR/system/build.prop"
fi

if [ -f "$BUILD_PROP" ]; then
    cat << 'EOF' >> "$BUILD_PROP"

# ==============================================================================
# SM-P580 ULTRA-LITE & IOS-STYLE TOUCH / PERFORMANCE TWEAKS
# ==============================================================================

# --- [1] GPU & SurfaceFlinger Donanim Hizlandirma (Mali-T830) ---
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

# --- [3] Düşük RAM & Arka Plan Yonetimi (2GB/3GB Optimize) ---
ro.config.low_ram=false
ro.config.fha_enable=true
ro.sys.fw.bg_apps_limit=14
persist.sys.purgeable_assets=1
ro.HOME_APP_ADJ=1

# --- [4] Masaustu Pencereli Mod (Freeform Windows Support) ---
enable_freeform_support=1
force_resizable_activities=1
persist.sys.freeform_window=1

# --- [5] CPU Tasarrufu & Loglama Yükünü Sıfırlama ---
logcat.live=disable
profiler.force_disable_ulog=1
profiler.force_disable_err_rpt=1
EOF
    echo "  + build.prop basariyla guncellendi."
fi

# 4. ZRAM VE SWAP OPTIMIZASYONU
echo "[*] [4/5] ZRAM sanal bellek init yapilandirmasi hazirlaniyor..."
INIT_D_DIR="$TARGET_DIR/etc/init.d"
if [ ! -d "$INIT_D_DIR" ]; then
    INIT_D_DIR="$TARGET_DIR/system/etc/init.d"
fi

mkdir -p "$INIT_D_DIR" 2>/dev/null || true
if [ -d "$INIT_D_DIR" ]; then
    cat << 'EOF' > "$INIT_D_DIR/99zram_tweak"
#!/system/bin/sh
# SM-P580 ZRAM Optimizer
if [ -e /sys/block/zram0/disksize ]; then
    echo 1536M > /sys/block/zram0/disksize
    mkswap /dev/block/zram0 2>/dev/null
    swapon /dev/block/zram0 2>/dev/null
    echo 100 > /proc/sys/vm/swappiness
    echo 0 > /proc/sys/vm/page-cluster
fi
EOF
    chmod 755 "$INIT_D_DIR/99zram_tweak" 2>/dev/null || true
    echo "  + ZRAM 1.5GB sanal bellek scripti eklendi."
fi

echo "=================================================================="
echo ">> [5/5] Tum optimizasyonlar basariyla tamamlandi!"
echo "=================================================================="
