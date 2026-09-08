import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dobController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // State variables
  String? _selectedGender;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _agreeToTerms = false;
  bool _isLoading = false;

  // Animation variables
  late AnimationController _animationController;
  late List<Animation<double>> _listAnimations;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _listAnimations = List.generate(5, (index) {
      return CurvedAnimation(
        parent: _animationController,
        curve: Interval(index * 0.1, 0.6 + (index * 0.1), curve: Curves.easeOut),
      );
    });

    _animationController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // Retour au calendrier simple
  Future<void> _selectDateSimple(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Colors.white,
              onSurface: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        String day = picked.day.toString().padLeft(2, '0');
        String month = picked.month.toString().padLeft(2, '0');
        _dobController.text = "$day/$month/${picked.year}";
      });
    }
  }

  Future<void> _handleRegistration() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedGender == null) {
        _showSnackBar('Veuillez sélectionner votre genre');
        return;
      }
      if (!_agreeToTerms) {
        _showSnackBar('Veuillez accepter les conditions');
        return;
      }

      setState(() => _isLoading = true);

      try {
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        await FirebaseFirestore.instance.collection('patients').doc(userCredential.user!.uid).set({
          'uid': userCredential.user!.uid,
          'nom': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'telephone': _phoneController.text.trim(),
          'genre': _selectedGender,
          'dateNaissance': _dobController.text,
          'type': 'patient',
          'createdAt': FieldValue.serverTimestamp(),
        });

        if (!mounted) return;
        _showSnackBar('Compte créé avec succès !');
        Navigator.pop(context);
      } on FirebaseAuthException catch (e) {
        if (!mounted) return;
        _showSnackBar(e.message ?? "Une erreur est survenue");
      } catch (e) {
        if (!mounted) return;
        _showSnackBar("Erreur technique. Réessayez plus tard.");
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.primary),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeTransition(
                    opacity: _listAnimations[0],
                    child: SlideTransition(
                      position: Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(_listAnimations[0]),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Créer un compte", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
                          const SizedBox(height: 8),
                          Text("Rejoignez SanteFocus pour gérer votre santé en toute simplicité.", style: TextStyle(fontSize: 16, color: Theme.of(context).textTheme.bodySmall?.color)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  _buildAnimatedGroup(1, "Informations Personnelles", [
                    _buildTextField(_nameController, "Nom complet", Icons.person_outline),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _buildGenderDropdown()),
                        const SizedBox(width: 16),
                        Expanded(child: _buildDateTextField()),
                      ],
                    ),
                  ]),

                  const SizedBox(height: 24),

                  _buildAnimatedGroup(2, "Coordonnées", [
                    _buildTextField(_emailController, "Email", Icons.email_outlined, keyboardType: TextInputType.emailAddress),
                    const SizedBox(height: 16),
                    _buildTextField(_phoneController, "Téléphone", Icons.phone_outlined, keyboardType: TextInputType.phone),
                  ]),

                  const SizedBox(height: 24),

                  _buildAnimatedGroup(3, "Sécurité", [
                    _buildPasswordField(_passwordController, "Mot de passe", _obscurePassword, () => setState(() => _obscurePassword = !_obscurePassword)),
                    const SizedBox(height: 16),
                    _buildPasswordField(_confirmPasswordController, "Confirmation", _obscureConfirm, () => setState(() => _obscureConfirm = !_obscureConfirm), isConfirm: true),
                  ]),

                  const SizedBox(height: 32),

                  FadeTransition(
                    opacity: _listAnimations[4],
                    child: Column(
                      children: [
                        _buildTermsCheckbox(),
                        const SizedBox(height: 30),
                        _buildSubmitButton(),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Déjà un compte ?", style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color)),
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text("Se connecter", style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildAnimatedGroup(int index, String title, List<Widget> children) {
    return FadeTransition(
      opacity: _listAnimations[index],
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(_listAnimations[index]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary, letterSpacing: 1.1)),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {TextInputType? keyboardType}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: TextInputAction.next,
      style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color),
        prefixIcon: Icon(icon, color: Theme.of(context).colorScheme.primary.withOpacity(0.7)),
        filled: true,
        fillColor: Theme.of(context).cardColor,
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.5)),
      ),
      validator: (v) => (v == null || v.isEmpty) ? "Ce champ est requis" : null,
    );
  }

  Widget _buildGenderDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedGender,
      dropdownColor: Theme.of(context).cardColor,
      style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
      decoration: InputDecoration(
        labelText: "Genre",
        labelStyle: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color),
        prefixIcon: Icon(Icons.wc, color: Theme.of(context).colorScheme.primary, size: 20),
        filled: true,
        fillColor: Theme.of(context).cardColor,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
      items: ["Masculin", "Féminin"].map((v) => DropdownMenuItem(value: v, child: Text(v, style: const TextStyle(fontSize: 14)))).toList(),
      onChanged: (v) => setState(() => _selectedGender = v),
      validator: (v) => v == null ? "Requis" : null,
    );
  }

  Widget _buildDateTextField() {
    return TextFormField(
      controller: _dobController,
      readOnly: true,
      style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
      decoration: InputDecoration(
        labelText: "Naissance",
        labelStyle: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color),
        prefixIcon: Icon(Icons.calendar_month_outlined, color: Theme.of(context).colorScheme.primary, size: 20),
        filled: true,
        fillColor: Theme.of(context).cardColor,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
      onTap: () => _selectDateSimple(context),
      validator: (v) => (v == null || v.isEmpty) ? "Requis" : null,
    );
  }

  Widget _buildPasswordField(TextEditingController controller, String label, bool obscure, VoidCallback onToggle, {bool isConfirm = false}) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color),
        prefixIcon: Icon(Icons.lock_outline, color: Theme.of(context).colorScheme.primary),
        suffixIcon: IconButton(icon: Icon(obscure ? Icons.visibility_off : Icons.visibility, size: 20), onPressed: onToggle),
        filled: true,
        fillColor: Theme.of(context).cardColor,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.5)),
      ),
      validator: (v) {
        if (v == null || v.length < 6) return "Min. 6 caractères";
        if (isConfirm && v != _passwordController.text) return "Mots de passe différents";
        return null;
      },
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      children: [
        Checkbox(
          value: _agreeToTerms,
          activeColor: Theme.of(context).colorScheme.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          onChanged: (v) => setState(() => _agreeToTerms = v!),
        ),
        Expanded(
          child: Text(
            "J'accepte les conditions d'utilisation et la politique de confidentialité.",
            style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 58,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: LinearGradient(colors: [Theme.of(context).colorScheme.primary, const Color(0xFF1E88E5)]),
        boxShadow: [
          BoxShadow(color: Theme.of(context).colorScheme.primary.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6)),
        ],
      ),
      child: ElevatedButton(
        onPressed: _handleRegistration,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        child: const Text("CRÉER MON COMPTE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.1)),
      ),
    );
  }
}
