import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyPage extends StatelessWidget {
  const EmergencyPage({super.key});

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      debugPrint('Impossible de lancer l\'appel vers $phoneNumber');
    }
  }

  void _showFirstAidDetails(BuildContext context, String title, String desc, IconData icon, Color color, List<String> steps) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 25),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(icon, color: color, size: 30),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Theme.of(context).textTheme.bodyLarge?.color),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Text(
              desc,
              style: TextStyle(fontSize: 15, color: Theme.of(context).textTheme.bodySmall?.color, fontStyle: FontStyle.italic),
            ),
            const Divider(height: 40),
            Text(
              "Étapes à suivre immédiatement :",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color),
            ),
            const SizedBox(height: 15),
            Expanded(
              child: ListView.builder(
                itemCount: steps.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: color,
                          child: Text(
                            "${index + 1}",
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Text(
                            steps[index],
                            style: TextStyle(fontSize: 15, height: 1.4, color: Theme.of(context).textTheme.bodyMedium?.color),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.05),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.red.withOpacity(0.1)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.red),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Si l'état ne s'améliore pas, appelez immédiatement le 112.",
                      style: TextStyle(color: Colors.red, fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildEmergencyHeader(),
                  const SizedBox(height: 35),
                  
                  _buildSectionHeader(context, "Numéros d'Urgence", "Appel immédiat en un clic"),
                  const SizedBox(height: 20),
                  _buildModernContactGrid(context),

                  const SizedBox(height: 40),
                  
                  _buildSectionHeader(context, "Gestes qui Sauvent", "Guide interactif de premier secours"),
                  const SizedBox(height: 20),
                  _buildModernFirstAidList(context),

                  const SizedBox(height: 40),
                  _buildSurvivalGuideBox(context),
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
      backgroundColor: Theme.of(context).cardColor,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: const Text(
          "URGENCES",
          style: TextStyle(
            color: Color(0xFFD32F2F),
            fontWeight: FontWeight.w900,
            fontSize: 16,
            letterSpacing: 2,
          ),
        ),
        background: Container(color: Theme.of(context).cardColor),
      ),
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircleAvatar(
          backgroundColor: Colors.red.withOpacity(0.1),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.red, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
    );
  }

  Widget _buildEmergencyHeader() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        gradient: const LinearGradient(
          colors: [Color(0xFFD32F2F), Color(0xFFB71C1C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 25),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.flash_on_rounded, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 12),
          const Text(
            "ALERTE SOS",
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 1),
          ),
          const SizedBox(height: 6),
          const Text(
            "En cas de danger vital immédiat",
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 20),
          Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            child: InkWell(
              onTap: () => _makePhoneCall("112"),
              borderRadius: BorderRadius.circular(15),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.call, color: Color(0xFFD32F2F), size: 20),
                    SizedBox(width: 10),
                    Text(
                      "APPEL 112",
                      style: TextStyle(color: Color(0xFFD32F2F), fontWeight: FontWeight.w900, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Theme.of(context).textTheme.bodyLarge?.color),
        ),
        const SizedBox(height: 4),
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: TextStyle(fontSize: 14, color: Theme.of(context).textTheme.bodySmall?.color),
        ),
      ],
    );
  }

  Widget _buildModernContactGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      childAspectRatio: 1.3,
      children: [
        _buildContactCard(context, "SAMU", "15", Icons.medical_services_rounded, Colors.red),
        _buildContactCard(context, "POLICE", "17", Icons.local_police_rounded, Colors.blue),
        _buildContactCard(context, "POMPIERS", "18", Icons.local_fire_department_rounded, Colors.orange),
        _buildContactCard(context, "TOXIQUE", "0140054848", Icons.biotech_rounded, Colors.purple),
      ],
    );
  }

  Widget _buildContactCard(BuildContext context, String label, String number, IconData icon, Color color) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(color: isDark ? Colors.black26 : color.withOpacity(0.08), blurRadius: 15, offset: const Offset(0, 5)),
        ],
        border: Border.all(color: color.withOpacity(0.1), width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _makePhoneCall(number),
          borderRadius: BorderRadius.circular(25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(label, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: color)),
              Text(number, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernFirstAidList(BuildContext context) {
    return Column(
      children: [
        _buildFirstAidTile(context, "Arrêt Cardiaque", "Massage cardiaque & Défibrillateur", Icons.favorite_rounded, Colors.red, ["Vérifiez si la victime respire encore.", "Appelez immédiatement les secours (112/15).", "Placez vos mains au centre de la poitrine.", "Effectuez 100 à 120 compressions par minute.", "Utilisez un défibrillateur (DAE) si disponible."]),
        _buildFirstAidTile(context, "Étouffement", "Manœuvre de Heimlich", Icons.air_rounded, Colors.orange, ["Donnez 5 claques vigoureuses dans le dos.", "Si l'objet ne sort pas, passez aux compressions abdominales.", "Placez-vous derrière la victime et inclinez-la vers l'avant.", "Effectuez 5 tractions fortes vers l'arrière et le haut.", "Répétez jusqu'à l'expulsion de l'objet."]),
        _buildFirstAidTile(context, "Hémorragie", "Compression forte & Garrot", Icons.water_drop_rounded, Colors.redAccent, ["Allongez la victime pour éviter l'évanouissement.", "Appuyez fortement sur la plaie avec un linge propre.", "Si le saignement persiste, posez un garrot au-dessus de la plaie.", "Notez l'heure de pose du garrot.", "Couvrez la victime en attendant les secours."]),
        _buildFirstAidTile(context, "Brûlures Grave", "Arroser à l'eau tempérée", Icons.whatshot_rounded, Colors.deepOrange, ["Arrosez la zone brûlée à l'eau courante (15°C) pendant 15 min.", "Ne retirez pas les vêtements collés à la peau.", "Retirez les bijoux (bagues, montres) avant le gonflement.", "Couvrez avec un linge propre et sec.", "Ne percez jamais les cloques."]),
        _buildFirstAidTile(context, "Inconscience", "Position Latérale de Sécurité", Icons.hotel_rounded, Colors.blueGrey, ["Vérifiez la respiration en écoutant l'air sortir du nez.", "Basculez doucement la tête en arrière pour dégager les voies.", "Mettez la victime sur le côté (Position Latérale de Sécurité).", "Couvrez la victime.", "Surveillez sa respiration jusqu'à l'arrivée des secours."]),
      ],
    );
  }

  Widget _buildFirstAidTile(BuildContext context, String title, String desc, IconData icon, Color color, List<String> steps) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(color: isDark ? Colors.black26 : Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showFirstAidDetails(context, title, desc, icon, color, steps),
          borderRadius: BorderRadius.circular(25),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Theme.of(context).textTheme.bodyLarge?.color)),
                      const SizedBox(height: 4),
                      Text(desc, style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 13)),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, color: isDark ? Colors.grey.shade700 : Colors.grey.shade300, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSurvivalGuideBox(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: isDark ? Colors.black : const Color(0xFF263238),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(Icons.lightbulb_rounded, color: Colors.yellow, size: 30),
              SizedBox(width: 15),
              Text("GUIDE DE SURVIE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            "Gardez votre calme. Précisez l'adresse, la nature de l'accident et le nombre de victimes. Ne raccrochez jamais sans l'accord du régulateur.",
            style: TextStyle(color: Colors.grey.shade400, height: 1.5, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
