import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'login_screen.dart'; // Importe a tela de login

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ícone customizado (substitua por SVG se quiser igual ao print)
            Icon(
              Icons.cloud, // Use um pacote SVG para igual ao print
              size: 120,
              color: Color(0xFF3C6E91),
            ),
            const SizedBox(height: 32),
            const Text(
              'Monitore,\nconfigure e\nacompanhe o\nclima',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 36),
            SizedBox(
              width: 140,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  // Navega para a tela de login ao clicar em Iniciar
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LoginScreen(
                        station: StationData(
                          temperature: 25.4,
                          humidity: 67.0,
                          windSpeed: 12.3,
                          pressure: 1012,
                          rain: 1.5,
                          luminosity: 850,
                          history: {}, // pode deixar vazio por enquanto
                        ),
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF3C6E91),
                  shape: StadiumBorder(),
                  elevation: 0,
                ),
                child: const Text(
                  'Iniciar',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 36),
            // Indicadores de página
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Color(0xFF3C6E91),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Color(0xFF3C6E91).withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
