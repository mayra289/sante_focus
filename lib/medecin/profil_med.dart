import 'package:flutter/material.dart';

class ProfileMedPage extends StatefulWidget {
  const ProfileMedPage({super.key});

  @override
  State<ProfileMedPage> createState() => _ProfileMedPageState();
}

class _ProfileMedPageState extends State<ProfileMedPage> {
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();

  // Contrôleurs pour les informations professionnelles
  final _nomController = TextEditingController(text: "Dr. Valisoa");
  final _specialiteController = TextEditingController(text: "Médecin Généraliste");
  final _hopitalController = TextEditingController(text: "Clinique SanteFocus");
  final _emailController = TextEditingController(text: "valisoa@santefocus.com");
  final _phoneController = TextEditingController(text: "+221 77 123 45 67");
  final _rppsController = TextEditingController(text: "12345678901");
  final _experienceController = TextEditingController(text: "12 ans");
  final _bioController = TextEditingController(
      text: "Passionnée par la médecine préventive et le suivi digital des patients. Expertise en gestion des maladies chroniques et accompagnement thérapeutique.");

  // Contrôleurs pour la sécurité
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _showPasswordUpdate = false;

  @override
  void dispose() {
    _nomController.dispose();
    _specialiteController.dispose();
    _hopitalController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _rppsController.dispose();
    _experienceController.dispose();
    _bioController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    setState(() => _isEditing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 10),
              Text("Profil mis à jour avec succès"),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildStatsRow(),
                    const SizedBox(height: 25),
                    _buildSectionTitle("Identité Professionnelle", Icons.verified_user_rounded),
                    _buildCard([
                      _buildField("Nom & Prénom", _nomController, Icons.person_outline),
                      _buildField("Spécialité", _specialiteController, Icons.medical_information_outlined),
                      _buildField("Numéro RPPS", _rppsController, Icons.badge_outlined),
                      _buildField("Années d'expérience", _experienceController, Icons.history_edu_outlined),
                    ]),
                    const SizedBox(height: 25),
                    _buildSectionTitle("Établissement & Contact", Icons.business_outlined),
                    _buildCard([
                      _buildField("Lieu d'exercice principal", _hopitalController, Icons.local_hospital_outlined),
                      _buildField("Email Pro", _emailController, Icons.alternate_email_rounded),
                      _buildField("Téléphone Pro", _phoneController, Icons.phone_android_rounded),
                    ]),
                    const SizedBox(height: 25),
                    _buildSectionTitle("À propos", Icons.article_outlined),
                    _buildBioField(),
                    const SizedBox(height: 25),
                    _buildSectionTitle("Sécurité du compte", Icons.shield_outlined),
                    _buildSecurityCard(),
                    const SizedBox(height: 30),
                    _buildLogoutButton(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 240.0,
      floating: false,
      pinned: true,
      backgroundColor: const Color(0xFF0D47A1),
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Text(
          _isEditing ? "Édition du Profil" : "Dr. " + _nomController.text.split(' ').last,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        background: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 46,
                        backgroundColor: Colors.blue.shade50,
                        child: const Icon(Icons.person, size: 60, color: Color(0xFF0D47A1)),
                      ),
                    ),
                    if (_isEditing)
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.orange,
                        child: IconButton(
                          icon: const Icon(Icons.camera_alt, size: 14, color: Colors.white),
                          onPressed: () {},
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, color: Colors.greenAccent, size: 14),
                      SizedBox(width: 4),
                      Text("Médecin Vérifié", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                )
              ],
            ),
            // Logos ISPM et SanteFocus
            Positioned(
              top: 40,
              left: 20,
              right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset('assets/logo_ispm.png', height: 40, errorBuilder: (c, e, s) => const Icon(Icons.school, color: Colors.white)),
                  Image.asset('assets/received_1527607458340717.jpeg', height: 40, errorBuilder: (c, e, s) => const Icon(Icons.health_and_safety, color: Colors.white)),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(_isEditing ? Icons.save_rounded : Icons.edit_rounded),
          onPressed: () {
            if (_isEditing) {
              _saveProfile();
            } else {
              setState(() => _isEditing = true);
            }
          },
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem("1.2k", "Patients", Icons.people_outline),
          Container(width: 1, height: 30, color: Colors.grey.shade200),
          _buildStatItem("4.9", "Note", Icons.star_border_rounded),
          Container(width: 1, height: 30, color: Colors.grey.shade200),
          _buildStatItem("150", "Avis", Icons.chat_bubble_outline_rounded),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF0D47A1)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1))),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(left: 5, bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: const Color(0xFF0D47A1).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, size: 18, color: const Color(0xFF0D47A1)),
          ),
          const SizedBox(width: 10),
          Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildField(String label, TextEditingController controller, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: TextFormField(
        controller: controller,
        enabled: _isEditing,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          prefixIcon: Icon(icon, color: const Color(0xFF0D47A1), size: 20),
          filled: true,
          fillColor: _isEditing ? Colors.transparent : Colors.grey.shade50,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildBioField() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
      ),
      child: TextFormField(
        controller: _bioController,
        enabled: _isEditing,
        maxLines: 4,
        style: const TextStyle(fontSize: 14, height: 1.5, color: Colors.black87),
        decoration: InputDecoration(
          hintText: "Décrivez votre parcours...",
          border: _isEditing ? OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)) : InputBorder.none,
          isDense: true,
        ),
      ),
    );
  }

  Widget _buildSecurityCard() {
    return _buildCard([
      if (!_showPasswordUpdate)
        ListTile(
          leading: const Icon(Icons.lock_reset_rounded, color: Color(0xFF0D47A1)),
          title: const Text("Mot de passe", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          subtitle: const Text("Dernière modification il y a 3 mois", style: TextStyle(fontSize: 12)),
          trailing: TextButton(
            onPressed: () => setState(() => _showPasswordUpdate = true),
            child: const Text("Modifier"),
          ),
        )
      else
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              _buildPasswordField("Mot de passe actuel", _oldPasswordController, _obscureOld, () => setState(() => _obscureOld = !_obscureOld)),
              const SizedBox(height: 10),
              _buildPasswordField("Nouveau mot de passe", _newPasswordController, _obscureNew, () => setState(() => _obscureNew = !_obscureNew)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: () => setState(() => _showPasswordUpdate = false), child: const Text("Annuler")),
                  ElevatedButton(
                    onPressed: () => setState(() => _showPasswordUpdate = false),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D47A1)),
                    child: const Text("Valider", style: TextStyle(color: Colors.white)),
                  ),
                ],
              )
            ],
          ),
        ),
    ]);
  }

  Widget _buildPasswordField(String label, TextEditingController controller, bool obscure, VoidCallback onToggle) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock_outline, size: 18),
        suffixIcon: IconButton(icon: Icon(obscure ? Icons.visibility_off : Icons.visibility, size: 16), onPressed: onToggle),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        isDense: true,
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: TextButton.icon(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("Déconnexion"),
              content: const Text("Voulez-vous vraiment vous déconnecter ?"),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
                TextButton(onPressed: () => Navigator.pop(context), child: const Text("Déconnexion", style: TextStyle(color: Colors.red))),
              ],
            ),
          );
        },
        icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
        label: const Text("SE DÉCONNECTER", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: const BorderSide(color: Colors.redAccent, width: 1)),
        ),
      ),
    );
  }
}
