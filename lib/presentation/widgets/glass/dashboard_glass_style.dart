/// Preset visual untuk [GlassCard] pada panel dashboard (kartu besar + quick action).
///
/// Batas yang **di-enforce** [GlassCard]: `blurSigma` 20–30, `borderWidth` 1–3,
/// `overlayTopOpacity` / `overlayBottomOpacity` ≤ 0.06. Di dalam paint,
/// alpha border di-clamp **0.08–0.28** (nilai di bawah/atas itu dipotong).
abstract final class DashboardGlassStyle {
  /// **Kabur backdrop** (sigma blur). Min **20**: kaca lebih jernih, konten di belakang
  /// lebih terbaca. Max **30** ([GlassCard]): frosting paling kuat, lebih “es”.
  static const double blurSigma = 14;

  /// **Ketebalan garis tepi** kaca (px). Min **1**: subtle. Max **3**: rim tegas,
  /// tombol/kartu lebih jelas terpisah dari latar.
  static const double borderWidth = 1.4;

  /// **Opasitas warna putih** pada border (0–1). Di [GlassCard] saat digambar
  /// di-clamp **0.08–0.28**: min → tepi hampir tidak keliatan; max → bingkai
  /// putih paling kuat yang diizinkan (lebih dari 0.28 tidak membuat garis lebih pekat).
  static const double borderOpacity = 0.16;

  /// **Lapisan frosted bagian atas** gradient (≤ **0.06** di [GlassCard]). Min (~0):
  /// hampir transparan. Max (**0.06**): highlight “kaca” paling allowed — kartu terlihat
  /// lebih mati / kontras di atas isi di belakangnya.
  static const double overlayTopOpacity = 0.022;

  /// **Lapisan bawah** gradient (≤ **0.06**). Min: gradient datar. Lebih tinggi:
  /// alas kartu sedikit lebih berisi; gabung dengan [overlayTopOpacity] bentuk depth vertikal.
  static const double overlayBottomOpacity = 0.008;

  /// **Bayangan** di bawah kartu (alpha hitam pada `BoxShadow` di [GlassCard]). Min (~0):
  /// kartu hampir menempel datar. Lebih tinggi: lebih mengambang / terpisah dari background
  /// (terlalu tinggi bisa berat secara visual).
  static const double shadowOpacity = 0.015;

  // --- Quick Actions: kaca bulat di atas panel glass ---------------------------------

  /// Blur ikon (sama aturan **20–30** seperti [blurSigma]). Min 20: ikon relatif tajam
  /// di atas panel; max 30: ikon lebih menyatu seperti frosted.
  static const double quickActionIconBlurSigma = 12;

  /// Border lingkaran quick action. **1–3** px; lebih tebal → kontrol lebih “button”.
  static const double quickActionIconBorderWidth = 1.6;

  /// Opacity border ikon (sama clamp **0.08–0.28** di paint). Atas skala yang di-clamp
  /// → tepi bulat paling terlihat vs panel induk.
  static const double quickActionIconBorderOpacity = 0.18;

  /// Frost atas tombol bulat (≤ **0.06**). Dekati max agar chip kontras di atas glass induk.
  static const double quickActionIconOverlayTop = 0.02;

  /// Frost bawah tombol bulat (≤ **0.06**).
  static const double quickActionIconOverlayBottom = 0.008;

  /// Bayangan tombol bulat. Rendah → ringan di atas panel; naikkan jika perlu “mengambang”
  /// lebih jelas dari kartu induk.
  static const double quickActionIconShadowOpacity = 0.01;
}
