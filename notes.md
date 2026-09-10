# Godot 4 Mobile Portrait Editor - Mimari & Notlar

## 1. Mimari Kararlar
- **Katmanlama:** `EditorPlugin` tabanlı hafif enjeksiyon yöntemi, motoru yeniden derleme zorunluluğunu ortadan kaldırarak mevcut tüm Godot 4 Android APK sürümleriyle anında uyumluluk sağlar.
- **DPI & Touch Target Standardı:** Tüm butonlar mobil erişilebilirlik gereksinimlerine uygun olarak 44-48dp dokunma alanına sabitlenmiştir.
- **Kayan Panel (Bottom Sheet) Mantığı:** `PanelContainer` + `Tween` animasyonu ile pürüzsüz 60 FPS geçişler sağlanır. Çift tıklama / sürükleme hareketleri (gestures) desteklenir.

## 2. Dizin Yapısı
- `addons/mobile_portrait_editor/`: Godot eklenti çekirdeği
  - `mobile_portrait_plugin.gd`: Ana editör eklentisi ve yaşam döngüsü
  - `bottom_nav_bar.gd`: Alt gezinme çubuğu
  - `bottom_sheet_modal.gd`: Kayan alt modal çekmece
  - `mobile_touch_toolbar.gd`: Hızlı erişim araç çubuğu
- `engine/`: C++ motor yamaları ve SCons/NDK referansları
- `.github/workflows/`: GitHub Actions bulut derleme pipeline'ı
