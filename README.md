# SM-P580 Ultra-Lite (iOS-Tuned) Custom ROM Builder 🚀

Samsung Galaxy Tab A 10.1 with S-Pen (**SM-P580 / gtanotexlwifi / Exynos 7870**) için özel olarak tasarlanmış **Ultra Hafif, Yüksek Performanslı ve iOS Düzeyinde Akıcı** Custom ROM derleyici / optimize edici iş akışı.

---

## 🌟 Neler Yapıldı? (Mühendislik Özellikleri)

1. **iOS Tarzı Dokunmatik Tepkiselliği (Low-Latency Touch):**
   - Arayüz render işlemlerine en yüksek CPU önceliği (`sys.use_fifo_ui=1`).
   - 60 FPS kaydırma ve sıfır mikro-takılma (micro-stutter elimination).

2. **Düşük RAM ve Bellek Optimizasyonu (2GB/3GB RAM):**
   - Boşta RAM kullanımını minimuma indiren derin temizlik (Debloat).
   - Arka plan servislerinin CPU tüketmesini engelleyen donma optimizasyonları.
   - **1.5 GB ZRAM (LZ4)** sanal bellek ile kasmayan çoklu sekme performansı.

3. **Masaüstü Pencereli Mod (AOSP Freeform Desktop Mode):**
   - Klavye / fare veya tek tuşla yan yana boyutlandırılabilir pencereler.

4. **Sistem Seviyesinde Reklam & Takipçi Engelleyici (`hosts`):**
   - Web sitelerinin hızlı yüklenmesini sağlayan ağ seviyesinde filtreleme.

---

## 🛠️ Nasıl Çalıştırılır? (GitHub Actions)

1. Bu repoda **Actions** sekmesine tıklayın.
2. Sol taraftan **`SM-P580 Ultra-Lite ROM Builder`** iş akışını seçin.
3. Sağdaki **`Run workflow`** butonuna basarak derlemeyi başlatın.
4. Derleme bittiğinde **Releases** sekmesinden hazır `.zip` dosyasını indirin.

---

## 📱 Yükleme Talimatları (TWRP Recovery)

1. Tabletinizi **TWRP** modunda açın.
2. `Wipe` -> `Advanced Wipe` -> `Dalvik / ART Cache`, `Cache`, `System`, `Data` temizleyin.
3. `Install` menüsünden indirilen `.zip` dosyasını seçip yükleyin.
4. Cihazınızı yeniden başlatın.
