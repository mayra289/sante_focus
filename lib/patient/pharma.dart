import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PharmacyPage extends StatefulWidget {
  const PharmacyPage({super.key});

  @override
  State<PharmacyPage> createState() => _PharmacyPageState();
}

class _PharmacyPageState extends State<PharmacyPage> {
  final PageController _pageController = PageController(viewportFraction: 0.85);
  bool _isLoading = true;

  List<Map<String, dynamic>> _dutyPharmacies = [];
  List<Map<String, dynamic>> _nearbyPharmacies = [];

  @override
  void initState() {
    super.initState();
    _chargerPharmacies();
  }

  Future<void> _chargerPharmacies() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('pharmacies')
        .get();
    final toutes = snapshot.docs.map((d) {
      final data = d.data();
      return {
        'name': data['name'] ?? 'Pharmacie',
        'address': data['address'] ?? 'Adresse non renseignée',
        'distance': data['distance'] ?? '--',
        'phone': data['phone'] ?? '',
        'isOpen': data['isOpen'] ?? true,
        'deGarde': data['deGarde'] ?? false,
      };
    }).toList();

    _dutyPharmacies = toutes.where((p) => p['deGarde'] == true).toList();
    _nearbyPharmacies = toutes;

    if (mounted) setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  Future<void> _openMap(String address) async {
    final Uri googleMapsUri = Uri.parse(
      "https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address + ', Antananarivo')}",
    );
    if (await canLaunchUrl(googleMapsUri)) {
      await launchUrl(googleMapsUri, mode: LaunchMode.externalApplication);
    }
  }

  void _navigateToFullList(
    String title,
    List<Map<String, dynamic>> pharmacies,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PharmacyFullListPage(
          title: title,
          pharmacies: pharmacies,
          makePhoneCall: _makePhoneCall,
          openMap: _openMap,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      "Pharmacies de Garde (Antananarivo) 🌙",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? Colors.blue.shade300
                            : const Color(0xFF1A237E),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDutyPharmaciesCarousel(context),
                  const SizedBox(height: 32),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildSectionTitle(
                      context,
                      "Toutes les Pharmacies",
                      () => _navigateToFullList(
                        "Toutes les Pharmacies",
                        _nearbyPharmacies,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildNearbyPharmaciesList(context, limit: 3),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return SliverAppBar(
      expandedHeight: 120.0,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: isDark
          ? Colors.blueGrey.shade900
          : const Color(0xFF0D47A1),
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new,
          color: Colors.white,
          size: 20,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          "Pharmacies Tana",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [Colors.blueGrey.shade900, Colors.black]
                  : [const Color(0xFF0D47A1), const Color(0xFF1976D2)],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(
    BuildContext context,
    String title,
    VoidCallback onTap,
  ) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.blue.shade300 : const Color(0xFF1A237E),
          ),
        ),
        TextButton(
          onPressed: onTap,
          child: Text(
            "Voir plus",
            style: TextStyle(
              color: isDark ? Colors.blue.shade300 : const Color(0xFF0D47A1),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDutyPharmaciesCarousel(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          height: 200,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _dutyPharmacies.length,
            itemBuilder: (context, index) {
              final pharma = _dutyPharmacies[index];
              return _buildCarouselItem(context, pharma);
            },
          ),
        ),
        Positioned(
          left: 5,
          child: _buildNavButton(context, Icons.chevron_left, () {
            _pageController.previousPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }),
        ),
        Positioned(
          right: 5,
          child: _buildNavButton(context, Icons.chevron_right, () {
            _pageController.nextPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }),
        ),
      ],
    );
  }

  Widget _buildNavButton(
    BuildContext context,
    IconData icon,
    VoidCallback onTap,
  ) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? Colors.grey.shade800.withOpacity(0.8)
            : Colors.white.withOpacity(0.8),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(
          icon,
          color: isDark ? Colors.blue.shade300 : const Color(0xFF0D47A1),
          size: 24,
        ),
        onPressed: onTap,
      ),
    );
  }

  Widget _buildCarouselItem(BuildContext context, Map<String, dynamic> pharma) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [Colors.blueGrey.shade900, Colors.blueGrey.shade800]
              : [const Color(0xFF1A237E), const Color(0xFF3949AB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : const Color(0xFF1A237E))
                .withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.nightlight_round, color: Colors.amber, size: 14),
                    SizedBox(width: 4),
                    Text(
                      "GARDE ACTIVE",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              const Icon(Icons.verified, color: Colors.greenAccent, size: 20),
            ],
          ),
          const Spacer(),
          Text(
            pharma['name'],
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            pharma['address'],
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildActionButton(
                Icons.phone,
                "Appeler",
                Colors.greenAccent,
                () => _makePhoneCall(pharma['phone']),
              ),
              const SizedBox(width: 12),
              _buildActionButton(
                Icons.directions,
                "Itinéraire",
                Colors.white,
                () => _openMap(pharma['address']),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNearbyPharmaciesList(BuildContext context, {int? limit}) {
    final list = limit != null
        ? _nearbyPharmacies.take(limit).toList()
        : _nearbyPharmacies;
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final pharma = list[index];
        return _buildPharmacyCard(context, pharma);
      },
    );
  }

  Widget _buildPharmacyCard(BuildContext context, Map<String, dynamic> pharma) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color primaryColor = isDark
        ? Colors.blue.shade300
        : const Color(0xFF0D47A1);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          iconColor: primaryColor,
          collapsedIconColor: Colors.grey,
          leading: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.local_pharmacy_rounded, color: primaryColor),
          ),
          title: Text(
            pharma['name'],
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          subtitle: Row(
            children: [
              Icon(Icons.location_on, size: 12, color: Colors.grey.shade400),
              const SizedBox(width: 4),
              Text(
                pharma['distance'],
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
              ),
              const SizedBox(width: 12),
              if (pharma.containsKey('isOpen'))
                _buildStatusBadge(pharma['isOpen']),
            ],
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                children: [
                  Divider(color: Colors.grey.withOpacity(0.2)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(
                        Icons.map_outlined,
                        size: 18,
                        color: isDark ? Colors.blue.shade300 : Colors.black54,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          pharma['address'],
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.color,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _makePhoneCall(pharma['phone']),
                          icon: const Icon(Icons.phone),
                          label: const Text("Contacter"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _openMap(pharma['address']),
                          icon: const Icon(Icons.directions),
                          label: const Text("Itinéraire"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(bool isOpen) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isOpen
            ? Colors.green.withOpacity(0.1)
            : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        isOpen ? "OUVERT" : "FERMÉ",
        style: TextStyle(
          color: isOpen ? Colors.green : Colors.red,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class PharmacyFullListPage extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> pharmacies;
  final Function(String) makePhoneCall;
  final Function(String) openMap;

  const PharmacyFullListPage({
    super.key,
    required this.title,
    required this.pharmacies,
    required this.makePhoneCall,
    required this.openMap,
  });

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: isDark
            ? Colors.blueGrey.shade900
            : const Color(0xFF0D47A1),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: pharmacies.length,
        itemBuilder: (context, index) {
          final pharma = pharmacies[index];
          return _buildPharmacyCard(context, pharma);
        },
      ),
    );
  }

  Widget _buildPharmacyCard(BuildContext context, Map<String, dynamic> pharma) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color primaryColor = isDark
        ? Colors.blue.shade300
        : const Color(0xFF0D47A1);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ExpansionTile(
        iconColor: primaryColor,
        collapsedIconColor: Colors.grey,
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.local_pharmacy_rounded, color: primaryColor),
        ),
        title: Text(
          pharma['name'],
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        subtitle: Row(
          children: [
            Icon(Icons.location_on, size: 12, color: Colors.grey.shade400),
            const SizedBox(width: 4),
            Text(
              pharma['distance'],
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
            ),
            const SizedBox(width: 12),
            if (pharma.containsKey('isOpen'))
              _buildStatusBadge(pharma['isOpen']),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              children: [
                Divider(color: Colors.grey.withOpacity(0.2)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(
                      Icons.map_outlined,
                      size: 18,
                      color: isDark ? Colors.blue.shade300 : Colors.black54,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        pharma['address'],
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => makePhoneCall(pharma['phone']),
                        icon: const Icon(Icons.phone),
                        label: const Text("Contacter"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => openMap(pharma['address']),
                        icon: const Icon(Icons.directions),
                        label: const Text("Itinéraire"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(bool isOpen) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isOpen
            ? Colors.green.withOpacity(0.1)
            : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        isOpen ? "OUVERT" : "FERMÉ",
        style: TextStyle(
          color: isOpen ? Colors.green : Colors.red,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
