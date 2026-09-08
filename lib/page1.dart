import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;
import 'login.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _floatingController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  
  late PageController _logoPageController;
  int _currentLogoIndex = 1000; 
  Timer? _logoTimer;
  bool _isLoading = true;

  final List<Widget> _logos = [
    Image.asset(
      'assets/logo_ispm.png',
      height: 120,
      width: 120,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => const Icon(Icons.health_and_safety_rounded, size: 100, color: Color(0xFF2196F3)),
    ),
    Image.asset(
      'assets/received_1527607458340717.jpeg',
      height: 120,
      width: 120,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => const Icon(Icons.medical_services_rounded, size: 100, color: Color(0xFF009688)),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );

    _floatingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _fadeAnimation = CurvedAnimation(parent: _mainController, curve: Curves.easeIn);
    _slideAnimation = Tween<double>(begin: 40, end: 0).animate(
      CurvedAnimation(parent: _mainController, curve: Curves.easeOutQuart),
    );

    _logoPageController = PageController(initialPage: _currentLogoIndex, viewportFraction: 1.0);
    _startLogoCarousel();

    // Simulation d'un chargement initial "Haut de gamme"
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _mainController.forward();
      }
    });
  }

  void _startLogoCarousel() {
    _logoTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_logoPageController.hasClients) {
        _currentLogoIndex++;
        _logoPageController.animateToPage(
          _currentLogoIndex,
          duration: const Duration(milliseconds: 1500),
          curve: Curves.easeInOutQuint,
        );
      }
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    _floatingController.dispose();
    _logoPageController.dispose();
    _logoTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 800),
        child: _isLoading ? _buildLoadingScreen() : _buildMainContent(),
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Center(
      key: const ValueKey('loading'),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Remplacement de l'icône par votre logo d'image
          Image.asset(
            'assets/received_1527607458340717.jpeg',
            height: 100,
            width: 100,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => const Icon(
              Icons.health_and_safety_rounded,
              size: 80,
              color: Color(0xFF1E88E5),
            ),
          ),
          const SizedBox(height: 30),
          // Indicateur de progression moderne
          SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(const Color(0xFF1E88E5).withOpacity(0.5)),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "SanteFocus",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w300,
              letterSpacing: 4,
              color: Colors.blueGrey.shade300,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return Stack(
      key: const ValueKey('content'),
      children: [
        // Premium background elements
        Positioned(
          top: -50,
          left: -50,
          child: _buildBlurCircle(200, Colors.blue.withOpacity(0.05)),
        ),
        Positioned(
          bottom: 100,
          right: -30,
          child: _buildBlurCircle(150, Colors.teal.withOpacity(0.03)),
        ),
        
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Column(
              children: [
                const Spacer(flex: 3),
                
                // Logo Section with enhanced 3D and Float
                AnimatedBuilder(
                  animation: Listenable.merge([_mainController, _floatingController]),
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _slideAnimation.value + (math.sin(_floatingController.value * 2 * math.pi) * 8)),
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: child,
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      SizedBox(
                        height: 180,
                        child: PageView.builder(
                          controller: _logoPageController,
                          onPageChanged: (index) => _currentLogoIndex = index,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            final logoIndex = index % _logos.length;
                            return AnimatedBuilder(
                              animation: _logoPageController,
                              builder: (context, child) {
                                double pageOffset = 0.0;
                                if (_logoPageController.position.haveDimensions) {
                                  pageOffset = _logoPageController.page! - index;
                                }
                                
                                final double rotationY = pageOffset * 1.2;
                                final double translationX = pageOffset * 100;
                                final double scale = (1 - (pageOffset.abs() * 0.2)).clamp(0.0, 1.0);
                                final double opacity = (1 - pageOffset.abs()).clamp(0.0, 1.0);

                                return Transform(
                                  transform: Matrix4.identity()
                                    ..setEntry(3, 2, 0.0015) 
                                    ..translate(translationX, 0, 0)
                                    ..rotateY(rotationY)
                                    ..scale(scale),
                                  alignment: Alignment.center,
                                  child: Opacity(
                                    opacity: opacity,
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                      child: _logos[logoIndex],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Color(0xFF1E88E5), Color(0xFF00ACC1)],
                        ).createShader(bounds),
                        child: const Text(
                          "SanteFocus",
                          style: TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2.0,
                            color: Colors.white, 
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        height: 3,
                        width: 50,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFF2196F3), Colors.transparent]),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 40),
                
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: const Text(
                    "L'excellence médicale au bout de vos doigts.\nUne plateforme pensée pour votre bien-être.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black45,
                      fontWeight: FontWeight.w400,
                      height: 1.6,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                
                const Spacer(flex: 3),
                
                // Professional Navigation
                _buildPremiumButton(
                  context,
                  title: "ESPACE PATIENT",
                  icon: Icons.person_rounded,
                  isPatient: true,
                  colors: [const Color(0xFF1E88E5), const Color(0xFF1565C0)],
                ),
                const SizedBox(height: 18),
                _buildPremiumButton(
                  context,
                  title: "ESPACE MÉDECIN",
                  icon: Icons.medical_services_rounded,
                  isPatient: false,
                  colors: [const Color(0xFF37474F), const Color(0xFF263238)],
                ),
                
                const Spacer(flex: 1),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBlurCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }

  Widget _buildPremiumButton(
    BuildContext context, {
    required String title,
    required IconData icon,
    required bool isPatient,
    required List<Color> colors,
  }) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        width: double.infinity,
        height: 65,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          boxShadow: [
            BoxShadow(
              color: colors.first.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LoginPage(isPatient: isPatient),
                ),
              );
            },
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Icon(icon, color: Colors.white, size: 28),
                  const Spacer(),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white54, size: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
