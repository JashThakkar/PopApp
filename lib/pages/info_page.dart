import 'package:flutter/material.dart';

class InfoPage extends StatelessWidget {
  const InfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("How to Use This App"),
        backgroundColor: Colors.transparent, // Match app theme
        elevation: 0, // Removes shadow for a clean look

        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context), // Go back to BreathingPage
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 35,
              ),
              const Text(
                "Additional Benefits",
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              const Text(
                "Box breathing helps in:\n\n"
                "✔ Reducing stress and anxiety\n"
                "✔ Improving focus and concentration\n"
                "✔ Lowering heart rate and blood pressure\n"
                "✔ Enhancing overall well-being\n\n"
                "Practice this technique daily for the best results.",
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 30),
              const Text(
                "Box Breathing Guide",
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              const Text(
                "Box breathing is a powerful technique for relaxation and focus. \n\n"
                "It follows these steps:\n\n"
                "🫁 Inhale as bubble grows\n"
                "⏸ Hold as bubble stays the same size\n"
                "🌬 Exhale as the bubble shrinks\n"
                "⏸ Hold as the bubble stays the same\n"
                "Each breath should take 16 seconds: \n\n"
                "4 in ➡️ 4 hold ➡️ 4 out ➡️ 4 hold  ➡️🔄\n\n"
                "Repeat this cycle to calm the mind and body.",
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 30),
              const Text(
                "Logging",
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              const Text(
                "The Logging feature allows a user to reflect on prior breathwork. This is great for setting goals, gaging where you are on your breathwork journy, and having documentation of the breathwork that you have done.\n\n\n",
                style: TextStyle(fontSize: 18),
              )
            ],
          ),
        ),
      ),
    );
  }
}
