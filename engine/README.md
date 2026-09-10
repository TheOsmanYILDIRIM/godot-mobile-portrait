# Godot 4 Native Engine - Mobile Portrait Subsystem

Bu dizin, Godot 4 kaynak kodunu doğrudan derleyerek Android platformunda yerel dikey düzen (Native Portrait Layout) elde etmek isteyen geliştiriciler için hazırlanan C++ yamalarını (patches) içerir.

## Yamalar (Patches)
- `0001-godot4-mobile-portrait-dock-system.patch`:
  - `editor/gui/editor_dock_manager.cpp`: Dikey ekranlarda dock alanlarının otomatik olarak genişletilebilir alt çekmecelere (bottom sheet tabs) dönüştürülmesi.
  - `editor/editor_node.cpp`: Touch target boyutlarının en az 48dp olarak zorunlu kılınması.
  - `platform/android/os_android.cpp`: Android sanal klavye açıldığında script editörünün otomatik görünür alanda tutulması.

## Derleme Talimatı (GitHub Actions CI/CD)
Android cihaz üzerinde ağır C++ derlemesi yapmamak için, bu depoyu GitHub'a aktarıp `.github/workflows/build_android_editor.yml` aracılığıyla otomatik bulut derlemesi başlatın.
