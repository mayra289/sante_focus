import 'package:flutter/material.dart';
import 'acceuil_pat.dart';
import 'medecin/accueil_med.dart';
import 'patient/Creation_compte.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; //l'authentifictaion
import 'medecin/creation_compte_med.dart';

class LoginPage extends StatefulWidget {
  final bool isPatient;
  const LoginPage({super.key, required this.isPatient});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  late AnimationController _animationController;
  late List<Animation<double>> _staggeredAnimations;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    // Création de 6 animations décalées pour un effet fluide
    _staggeredAnimations = List.generate(6, (index) {
      return CurvedAnimation(
        parent: _animationController,
        curve: Interval(
          0.05 + (index * 0.1),
          (0.6 + (index * 0.1)).clamp(0.0, 1.0),
          curve: Curves.easeOutQuart,
        ),
      );
    });

    _animationController.forward();
  }

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  //attend la reponse venant di firebase
  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _identifierController.text.trim(),
          password: _passwordController.text,
        );

        if (!mounted) return;

        if (widget.isPatient) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const PatientDashboard()),
            (route) => false,
          );
        } else {
          //attendre la réponse de l'admi avant de pouvoir se connecter
          // Connexion médecin : vérifier la validation admin
          final doc = await FirebaseFirestore.instance
              .collection('medecins')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .get();
          final valide = doc.data()?['valide'] ?? false;

          if (!mounted) return;

          if (valide == true) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const DoctorDashboard()),
              (route) => false,
            );
          } else {
            await FirebaseAuth.instance
                .signOut(); // on déconnecte, il n'a pas encore accès
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  "Votre compte est en attente de validation par l'administrateur.",
                ),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
      } on FirebaseAuthException catch (e) {
        if (!mounted) return;
        String message;
        switch (e.code) {
          case 'user-not-found':
          case 'wrong-password':
          case 'invalid-credential':
            message = "Email ou mot de passe incorrect";
            break;
          case 'invalid-email':
            message = "Format d'email invalide";
            break;
          default:
            message = e.message ?? "Erreur de connexion";
        }
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isPatient = widget.isPatient;
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: isDark ? Colors.blue.shade300 : Colors.blueAccent,
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.center, // Centrage du contenu de la colonne
            children: [
              // 1. LOGOS AVEC ANIMATION
              _buildAnimatedItem(
                0,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset(
                      'assets/logo_ispm.png',
                      height: 45,
                      fit: BoxFit.contain,
                      errorBuilder: (c, e, s) =>
                          const Icon(Icons.school, color: Colors.blueAccent),
                    ),
                    Image.asset(
                      'assets/received_1527607458340717.jpeg',
                      height: 45,
                      fit: BoxFit.contain,
                      errorBuilder: (c, e, s) => const Icon(
                        Icons.health_and_safety,
                        color: Colors.blueAccent,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // 2. AVATAR ET TITRE CENTRÉS
              _buildAnimatedItem(
                1,
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.blueAccent.withOpacity(0.2),
                          width: 2,
                        ),
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          isPatient
                              ? 'assets/pat.webp'
                              : 'assets/med-profil.jpg',
                          height: 100, // Légèrement plus grand pour le centrage
                          width: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            isPatient
                                ? Icons.person_pin_circle_rounded
                                : Icons.medical_services_rounded,
                            size: 80,
                            color: Colors.blueAccent,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    Text(
                      isPatient ? "Connexion Patient" : "Espace Médecin",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      isPatient
                          ? "Accédez à votre espace santé sécurisé."
                          : "Connectez-vous à votre interface professionnelle.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // 3. CHAMPS DE SAISIE
              _buildAnimatedItem(
                2,
                _buildTextField(
                  controller: _identifierController,
                  label: isPatient
                      ? "Email ou téléphone"
                      : "Identifiant professionnel",
                  icon: Icons.alternate_email_rounded,
                ),
              ),
              const SizedBox(height: 20),
              _buildAnimatedItem(
                3,
                _buildPasswordField(
                  controller: _passwordController,
                  label: "Mot de passe",
                  obscure: _obscurePassword,
                  onToggle: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),

              const SizedBox(height: 12),

              _buildAnimatedItem(
                4,
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text(
                      "Mot de passe oublié ?",
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // 4. BOUTONS
              _buildAnimatedItem(
                5,
                Column(
                  children: [
                    _buildSubmitButton(),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isPatient
                              ? "Nouveau sur SanteFocus ?"
                              : "Nouveau médecin ?",
                          style: const TextStyle(color: Colors.grey),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => isPatient
                                    ? const RegistrationPage()
                                    : const RegistrationMedecinPage(),
                              ),
                            );
                          },
                          child: Text(
                            "Créer un compte",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? Colors.blue.shade300
                                  : Colors.blueAccent,
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
      ),
    );
  }

  Widget _buildAnimatedItem(int index, Widget child) {
    return AnimatedBuilder(
      animation: _staggeredAnimations[index],
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - _staggeredAnimations[index].value)),
          child: Opacity(
            opacity: _staggeredAnimations[index].value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextFormField(
      controller: controller,
      style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Theme.of(context).textTheme.bodySmall?.color,
        ),
        prefixIcon: Icon(icon, color: Colors.blueAccent.withOpacity(0.7)),
        filled: true,
        fillColor: Theme.of(context).cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.blueAccent, width: 1.5),
        ),
      ),
      validator: (v) => (v == null || v.isEmpty) ? "Ce champ est requis" : null,
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Theme.of(context).textTheme.bodySmall?.color,
        ),
        prefixIcon: const Icon(
          Icons.lock_outline_rounded,
          color: Colors.blueAccent,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off : Icons.visibility,
            size: 20,
          ),
          onPressed: onToggle,
        ),
        filled: true,
        fillColor: Theme.of(context).cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.blueAccent, width: 1.5),
        ),
      ),
      validator: (v) =>
          (v == null || v.length < 6) ? "Minimum 6 caractères" : null,
    );
  }

  Widget _buildSubmitButton() {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color primaryColor = isDark ? Colors.blue.shade700 : Colors.blueAccent;

    return Container(
      width: double.infinity,
      height: 58,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: LinearGradient(
          colors: [primaryColor, const Color(0xFF1E88E5)],
        ),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                "SE CONNECTER",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  letterSpacing: 1.1,
                ),
              ),
      ),
    );
  }
}
