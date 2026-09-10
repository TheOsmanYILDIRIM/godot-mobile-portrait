# Godot 4 Mobile Portrait Editor (Dikey Mobil Editör Sistemi)

Bu proje, Godot 4 editörünü akıllı telefonlar, dikey (portrait) ekranlar ve küçük dokunmatik cihazlar için optimize eden **tek odaklı (single-pane) mobil arayüz sistemi** ve **EditorPlugin** eklentisidir.

---

## 📱 Neden İhtiyaç Duyuldu?

Resmi Godot 4 Android editörü masaüstü arayüzünü (çok sütunlu dock panelleri) doğrudan telefona taşır. Bu durum dikey ekranlarda:
1. Sahne (2D/3D Viewport) alanının neredeyse tamamen kapanmasına,
2. Küçük butonlar (< 24dp) nedeniyle dokunmatik tıklama zorluklarına,
3. Sanal klavye açıldığında kod editörünün kaybolmasına yol açar.

---

## ✨ Özellikler

- **🎨 Tek Odaklı Görünüm (Single-Pane Focus):** Ekranın %85'i her zaman aktif çalışma alanına (2D Sahne, 3D Sahne veya Kod Editörü) ayrılır.
- **📱 Alt Navigasyon Çubuğu (Bottom Navigation Bar):** 
  - `[🎨 2D/3D]` | `[🌳 Sahne]` | `[🔍 Müfettiş]` | `[📂 Dosyalar]` | `[📝 Kod]` | `[🐛 Konsol]`
  - Minimum 48dp dokunmatik hedef standardı.
- **📂 Kayan Alt Çekmece (Draggable Bottom Sheet):**
  - Sahne ağacı, nesne müfettişi ve dosya yöneticisi ekranı bölmek yerine alttan kayarak açılır.
  - Sürükleyerek yarı ekran veya tam ekran yapılabilir ya da aşağı kaydırıp kapatılabilir.
- **⚡ Ergonomik Başparmak Hızlı Butonları (Floating Thumb Toolbar):**
  - Geri Al (Undo), İleri Al (Redo), Sahneyi Oynat, Projeyi Oynat, Durdur.
- **🔄 Otomatik Dikey Algılama:** Ekran en-boy oranı `Yükseklik > Genişlik` olduğunda veya dar ekranda otomatik aktifleşir; masaüstü düzenine tek tıkla geri dönülebilir.

---

## 🚀 Kurulum & Kullanım

### 1. Eklenti (Addon) Olarak Kullanma (En Hızlı Yöntem)
1. `addons/mobile_portrait_editor` klasörünü Godot projenizin `res://addons/` dizinine kopyalayın.
2. Godot Editöründe **Project -> Project Settings -> Plugins** sekmesine gidin.
3. **Mobile Portrait Editor** eklentisini **Enable** yapın.
4. Üst araç çubuğundaki **📱 Dikey Mobil UI** butonuna basarak mobil düzene geçin.

### 2. Bağımsız Android Editör APK'sı Olarak Derleme (CI/CD)
- `.github/workflows/build_android_editor.yml` dosyasını kullanarak GitHub Actions üzerinde otomatik olarak telefonunuza yüklenebilir APK oluşturun.
