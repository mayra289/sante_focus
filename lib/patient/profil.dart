import 'package:flutter/material.dart';
//pour la connection à la base
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();

  // Contrôleurs pour les informations personnelles
  final _nameController = TextEditingController(text: "Patient SanteFocus");
  final _emailController = TextEditingController(
    text: "patient@santefocus.com",
  );
  final _phoneController = TextEditingController(text: "+221 77 123 45 67");
  final _addressController = TextEditingController(text: "Dakar, Sénégal");
  final _birthDateController = TextEditingController(text: "12/10/1995");
  final _genderController = TextEditingController(text: "Masculin");

  // Contact d'urgence
  final _emergencyNameController = TextEditingController(text: "Marie Fall");
  final _emergencyPhoneController = TextEditingController(
    text: "+221 70 987 65 43",
  );

  // Contrôleurs pour la sécurité
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isEditing = false;
  bool _twoFactorEnabled = false;
  bool _showPasswordUpdate = false;
  bool _isLoading = true;

  //changer les vraie données
  @override
  void initState() {
    super.initState();
    _chargerProfil();
  }

  Future<void> _chargerProfil() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final doc = await FirebaseFirestore.instance
        .collection('patients')
        .doc(uid)
        .get();

    if (doc.exists) {
      final data = doc.data()!;
      _nameController.text = data['nom'] ?? '';
      _emailController.text = data['email'] ?? '';
      _phoneController.text = data['telephone'] ?? '';
      _addressController.text = data['localisation'] ?? '';
      _birthDateController.text = data['dateNaissance'] ?? '';
      _genderController.text = data['genre'] ?? '';
      _emergencyNameController.text = data['contactUrgenceNom'] ?? '';
      _emergencyPhoneController.text = data['contactUrgenceTelephone'] ?? '';
    }

    if (mounted) setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _birthDateController.dispose();
    _genderController.dispose();
    _emergencyNameController.dispose();
    _emergencyPhoneController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  //pour vraiment rcrire dans firestore
  Future<void> _saveProfile() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    try {
      await FirebaseFirestore.instance.collection('patients').doc(uid).update({
        'nom': _nameController.text.trim(),
        'telephone': _phoneController.text.trim(),
        'localisation': _addressController.text.trim(),
        'dateNaissance': _birthDateController.text.trim(),
        'genre': _genderController.text.trim(),
        'contactUrgenceNom': _emergencyNameController.text.trim(),
        'contactUrgenceTelephone': _emergencyPhoneController.text.trim(),
        // on ne touche pas à 'email' ici : le changer nécessite une procédure Firebase Auth séparée
      });

      setState(() => _isEditing = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil mis à jour avec succès !'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _updatePassword() async {
    if (_oldPasswordController.text.isEmpty ||
        _newPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez remplir les champs de mot de passe'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Les nouveaux mots de passe ne correspondent pas'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser!;
      // Firebase exige une ré-authentification récente avant de changer le mot de passe
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: _oldPasswordController.text,
      );
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(_newPasswordController.text);

      setState(() => _showPasswordUpdate = false);
      _oldPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mot de passe actualisé avec succès !'),
          backgroundColor: Colors.blue,
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.code == 'wrong-password'
                ? "Ancien mot de passe incorrect"
                : e.message ?? "Erreur",
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _forgotPassword() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Un lien de réinitialisation a été envoyé à votre email'),
        backgroundColor: Color(0xFF0D47A1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color primaryColor = isDark
        ? Colors.blue.shade300
        : const Color(0xFF0D47A1);

    // AFFICHAGE PENDANT LE CHARGEMENT
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          "Mon Profil",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0.5,
        foregroundColor: primaryColor,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (_isEditing) {
                _saveProfile();
              } else {
                setState(() => _isEditing = true);
              }
            },
            child: Text(
              _isEditing ? "VALIDER" : "MODIFIER",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        physics: const BouncingScrollPhysics(),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTopLogos(),
              const SizedBox(height: 10),
              _buildAvatarSection(context),
              const SizedBox(height: 30),

              _buildSectionTitle(
                context,
                "Informations Personnelles",
                Icons.person_outline,
              ),
              _buildCard(context, [
                _buildField(
                  context,
                  "Nom Complet",
                  _nameController,
                  Icons.badge_outlined,
                ),
                _buildField(
                  context,
                  "Email",
                  _emailController,
                  Icons.email_outlined,
                ),
                _buildField(
                  context,
                  "Téléphone",
                  _phoneController,
                  Icons.phone_outlined,
                ),
                _buildField(
                  context,
                  "Localisation",
                  _addressController,
                  Icons.location_on_outlined,
                ),
                Row(
                  children: [
                    Expanded(
                      child: _buildField(
                        context,
                        "Date de naissance",
                        _birthDateController,
                        Icons.cake_outlined,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildField(
                        context,
                        "Sexe",
                        _genderController,
                        Icons.transgender_rounded,
                      ),
                    ),
                  ],
                ),
              ]),

              const SizedBox(height: 25),

              _buildSectionTitle(
                context,
                "Contact d'Urgence",
                Icons.contact_phone_outlined,
              ),
              _buildCard(context, [
                _buildField(
                  context,
                  "Nom du contact",
                  _emergencyNameController,
                  Icons.person_add_alt,
                ),
                _buildField(
                  context,
                  "Téléphone d'urgence",
                  _emergencyPhoneController,
                  Icons.phone_callback,
                ),
              ]),

              const SizedBox(height: 25),

              _buildSectionTitle(
                context,
                "Espace Sécurité",
                Icons.lock_outline,
              ),
              _buildSecurityCard(context),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopLogos() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset(
            'assets/logo_ispm.png',
            height: 40,
            errorBuilder: (c, e, s) =>
                const Icon(Icons.school, color: Colors.grey),
          ),
          Image.asset(
            'assets/received_1527607458340717.jpeg',
            height: 40,
            errorBuilder: (c, e, s) =>
                const Icon(Icons.health_and_safety, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarSection(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color primaryColor = isDark
        ? Colors.blue.shade300
        : const Color(0xFF0D47A1);

    return Center(
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Theme.of(context).cardColor, width: 4),
              boxShadow: [
                BoxShadow(
                  color: isDark ? Colors.black26 : Colors.black12,
                  blurRadius: 8,
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 50,
              backgroundColor: isDark
                  ? Colors.blueGrey.shade800
                  : Colors.blue.shade50,
              child: Icon(Icons.person, size: 60, color: primaryColor),
            ),
          ),
          if (_isEditing)
            CircleAvatar(
              radius: 16,
              backgroundColor: primaryColor,
              child: const Icon(
                Icons.camera_alt,
                size: 16,
                color: Colors.white,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, IconData icon) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color primaryColor = isDark
        ? Colors.blue.shade300
        : const Color(0xFF0D47A1);

    return Padding(
      padding: const EdgeInsets.only(left: 5, bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 20, color: primaryColor),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context, List<Widget> children) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildField(
    BuildContext context,
    String label,
    TextEditingController controller,
    IconData icon,
  ) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color primaryColor = isDark
        ? Colors.blue.shade300
        : const Color(0xFF0D47A1);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        enabled: _isEditing,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 13, color: Colors.grey),
          prefixIcon: Icon(icon, color: primaryColor, size: 20),
          isDense: true,
          filled: !_isEditing,
          fillColor: _isEditing
              ? Colors.transparent
              : (isDark ? Colors.blueGrey.shade900 : Colors.grey.shade50),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
            ),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: isDark ? Colors.blueGrey.shade800 : Colors.grey.shade100,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSecurityCard(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color primaryColor = isDark
        ? Colors.blue.shade300
        : const Color(0xFF0D47A1);

    return _buildCard(context, [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Double Authentification",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          Switch.adaptive(
            value: _twoFactorEnabled,
            onChanged: (val) => setState(() => _twoFactorEnabled = val),
            activeColor: primaryColor,
          ),
        ],
      ),
      Divider(height: 30, color: Colors.grey.withOpacity(0.2)),
      if (!_showPasswordUpdate)
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => setState(() => _showPasswordUpdate = true),
            icon: const Icon(Icons.password_rounded, size: 18),
            label: const Text("CHANGER LE MOT DE PASSE"),
            style: OutlinedButton.styleFrom(
              foregroundColor: primaryColor,
              side: BorderSide(color: primaryColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        )
      else
        Column(
          children: [
            _buildPasswordField(
              context,
              "Mot de passe actuel",
              _oldPasswordController,
              _obscureOld,
              () => setState(() => _obscureOld = !_obscureOld),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _forgotPassword,
                child: Text(
                  "Mot de passe oublié ?",
                  style: TextStyle(fontSize: 12, color: primaryColor),
                ),
              ),
            ),
            const SizedBox(height: 5),
            _buildPasswordField(
              context,
              "Nouveau mot de passe",
              _newPasswordController,
              _obscureNew,
              () => setState(() => _obscureNew = !_obscureNew),
            ),
            const SizedBox(height: 12),
            _buildPasswordField(
              context,
              "Confirmer nouveau mot de passe",
              _confirmPasswordController,
              _obscureConfirm,
              () => setState(() => _obscureConfirm = !_obscureConfirm),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => setState(() {
                      _showPasswordUpdate = false;
                      _oldPasswordController.clear();
                      _newPasswordController.clear();
                      _confirmPasswordController.clear();
                    }),
                    child: const Text(
                      "ANNULER",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _updatePassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      "ACTUALISER",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
    ]);
  }

  Widget _buildPasswordField(
    BuildContext context,
    String label,
    TextEditingController controller,
    bool obscure,
    VoidCallback onToggle,
  ) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      style: TextStyle(
        fontSize: 14,
        color: Theme.of(context).textTheme.bodyLarge?.color,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 13, color: Colors.grey),
        prefixIcon: const Icon(Icons.lock_outline, size: 20),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off : Icons.visibility,
            size: 18,
          ),
          onPressed: onToggle,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
          ),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        isDense: true,
      ),
    );
  }
}
