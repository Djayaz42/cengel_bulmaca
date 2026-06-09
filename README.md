# Çengel Bulmaca Flutter Uygulaması

## Proje Yapısı

```
lib/
├── main.dart                    # Uygulama giriş noktası
├── models/
│   └── puzzle_model.dart        # Veri modelleri
├── providers/
│   └── game_provider.dart       # Oyun state yönetimi
├── screens/
│   ├── chapters_screen.dart     # Bölüm listesi
│   ├── game_screen.dart         # Oyun ekranı
│   └── completion_screen.dart   # Tamamlama ekranı
├── widgets/
│   ├── crossword_grid.dart      # Izgara widget
│   ├── grid_cell_widget.dart    # Tekil hücre widget
│   └── turkish_keyboard.dart   # Türkçe klavye
└── utils/
    └── app_theme.dart           # Renkler ve tema

assets/
└── puzzles/
    └── bolum_1.json             # Örnek bulmaca verisi
```

## Kurulum

```bash
flutter pub get
flutter run
```

## JSON Veri Formatı

Her bölüm `assets/puzzles/bolum_X.json` dosyasında tanımlanır.

### Hücre Tipleri

| Tip | Açıklama |
|-----|----------|
| `question` | Turkuaz soru hücresi, `question_text_right` ve/veya `question_text_down` içerir |
| `answer` | Beyaz cevap hücresi, kullanıcı harf girer |
| `black` | Dolu kara hücre |
| `image` | Resim hücresi, `span_rows` ve `span_cols` ile boyut belirlenir |

### Kelime Yönleri

- `"direction": "right"` → soldan sağa
- `"direction": "down"` → yukarıdan aşağıya

### Resim Hücresi Örneği

```json
{
  "row": 3,
  "col": 4,
  "type": "image",
  "image_asset": "assets/images/logo.png",
  "span_rows": 2,
  "span_cols": 2,
  "image_caption": "Logo"
}
```

## Yeni Bölüm Eklemek

1. `assets/puzzles/bolum_X.json` dosyası oluştur
2. `pubspec.yaml` → `assets` kısmı otomatik tanır (`assets/puzzles/` klasörü dahil)
3. `chapters_screen.dart` içindeki `_chapters` listesine yeni `ChapterModel` ekle

## İlerleyen Aşamalar

- [ ] API entegrasyonu (bölümleri sunucudan çek)
- [ ] Reklam entegrasyonu
- [ ] Firebase Analytics
- [ ] Bölüm editörü (admin paneli)
- [ ] Çevrimdışı önbellekleme
