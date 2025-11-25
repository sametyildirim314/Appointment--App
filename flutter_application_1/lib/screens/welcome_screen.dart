import 'package:flutter/material.dart';
import 'customer_login_screen.dart';
import 'business_login_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isMobile = size.width < 900;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 105, 114, 124),
      body: Stack(
        children: [
          _buildBackgroundGradients(),
          _buildBlurredDecorations(),
          SafeArea(
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 24 : 48,
                  vertical: isMobile ? 32 : 48,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: isMobile
                      ? _buildStackedLayout(context)
                      : _buildSplitLayout(context),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStackedLayout(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildHeroSection(),
        const SizedBox(height: 32),
        _buildGlassPanel(
          child: Column(
            children: [
              _buildLoginButtons(context),
              const SizedBox(height: 24),
              _buildHighlights(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSplitLayout(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _buildHeroSection()),
        const SizedBox(width: 32),
        Expanded(
          child: _buildGlassPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLoginButtons(context),
                const SizedBox(height: 32),
                _buildHighlights(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF8B5CF6).withOpacity(0.35),
                blurRadius: 26,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: const Icon(
            Icons.content_cut,
            color: Color.fromARGB(255, 88, 73, 73),
            size: 36,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Kuaför Randevu Sistemi',
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.w800,
            color: Color.fromARGB(255, 226, 229, 232),
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Modern salonlar için güvenilir randevu & operasyon platformu',
          style: TextStyle(fontSize: 18, color: Colors.white.withOpacity(0.8)),
        ),
        const SizedBox(height: 32),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _buildHeroChip('Gerçek zamanlı randevu yönetimi'),
            _buildHeroChip('Çoklu işletme ve ekip desteği'),
            _buildHeroChip('Finansal öngörüler ve raporlar'),
          ],
        ),
      ],
    );
  }

  Widget _buildHeroChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 92, 65, 65).withOpacity(0.12),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle,
            color: Colors.white.withOpacity(0.8),
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassPanel({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 30,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildLoginButtons(BuildContext context) {
    return Column(
      children: [
        _buildCTAButton(
          title: 'Müşteri Girişi',
          description: 'Hizmet seç, uygun saat bul, randevularını takip et.',
          icon: Icons.person_outline,
          accentColor: const Color(0xFF38BDF8),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CustomerLoginScreen()),
          ),
        ),
        const SizedBox(height: 20),
        _buildCTAButton(
          title: 'İşletme Girişi',
          description: 'Takvimini doldur, ekiplerini yönet, gelirini artır.',
          icon: Icons.storefront_outlined,
          accentColor: const Color(0xFFA855F7),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const BusinessLoginScreen()),
          ),
        ),
      ],
    );
  }

  Widget _buildCTAButton({
    required String title,
    required String description,
    required IconData icon,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.08),
              Colors.white.withOpacity(0.03),
            ],
          ),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: accentColor.withOpacity(0.18),
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.white.withOpacity(0.4)),
          ],
        ),
      ),
    );
  }

  Widget _buildHighlights() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Neden Kuaför Randevu?',
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildHighlightTile(
                icon: Icons.lock_outline,
                title: 'Güvenli Altyapı',
                desc: 'JWT destekli çok katmanlı koruma ve şifreli oturum.',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildHighlightTile(
                icon: Icons.bolt,
                title: 'Hızlı Yönetim',
                desc: 'Tek ekrandan çalışan, hizmet ve randevu kontrolü.',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHighlightTile({
    required IconData icon,
    required String title,
    required String desc,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white.withOpacity(0.05),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundGradients() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF3B486B), // koyu mavi-gri
            Color(0xFF5A678A), // modern soft koyu mavi
            Color(0xFF232B3E), // profesyonel koyu gri-mavi
          ],
        ),
      ),
    );
  }

  Widget _buildBlurredDecorations() {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: -80,
            left: -40,
            child: _buildBlurCircle(const Color(0xFF7C3AED)),
          ),
          Positioned(
            bottom: -60,
            right: -30,
            child: _buildBlurCircle(const Color(0xFF2563EB)),
          ),
        ],
      ),
    );
  }

  Widget _buildBlurCircle(Color color) {
    return Container(
      width: 220,
      height: 220,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.35),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.5),
            blurRadius: 90,
            spreadRadius: 40,
          ),
        ],
      ),
    );
  }
}
