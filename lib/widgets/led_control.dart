import 'package:flutter/material.dart';
import '../colors.dart';

class LedControl extends StatelessWidget {
  final Function(String) onControlLED;
  final Function(String) onSendMessage;

  const LedControl(
      {Key? key, required this.onControlLED, required this.onSendMessage})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final messageController = TextEditingController();

    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
            color: AppColors.secondaryColor,
            borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => onControlLED('on'),
                  child: Text('Allumer LED'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8))),
                ),
                ElevatedButton(
                  onPressed: () => onControlLED('off'),
                  child: Text('Éteindre LED'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8))),
                ),
              ],
            ),
            SizedBox(height: 20),
            TextField(
              controller: messageController,
              decoration: InputDecoration(
                  labelText: 'Entrez un message',
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.primaryColor)),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.accentColor))),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => onSendMessage(messageController.text),
              child: Text('Envoyer Message'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentColor), // Couleur du bouton
            ),
          ],
        ),
      ),
    );
  }
}
