import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class PatientScreen extends StatefulWidget {
  final int patientId;

  PatientScreen({required this.patientId});

  @override
  _PatientScreenState createState() => _PatientScreenState();
}

class _PatientScreenState extends State<PatientScreen> {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();
  bool isRequestingHelp = false;
  bool isNurseResponding = false;

  // Method to toggle the help request
  void toggleHelpRequest() {
    setState(() {
      isRequestingHelp = !isRequestingHelp;
    });

    if (isRequestingHelp) {
      _db
          .child('iot/patient${widget.patientId}/pesan')
          .set('pasien ${widget.patientId} meminta bantuan');
      _db.child('iot/led${widget.patientId}').set(true);
    } else {
      _db.child('iot/patient${widget.patientId}/pesan').set('');
      _db.child('iot/led${widget.patientId}').set(false);
    }
  }

  // Listen to Firebase for nurse response
  @override
  void initState() {
    super.initState();
    _db.child('iot/patient${widget.patientId}/pesan').onValue.listen((event) {
      final message = event.snapshot.value as String? ?? '';
      if (message == 'sudah ditangani') {
        setState(() {
          isNurseResponding = true;
          isRequestingHelp = false;
        });
        Future.delayed(const Duration(seconds: 5), () {
          setState(() {
            isNurseResponding = false;
          });
          _db.child('iot/patient${widget.patientId}/pesan').set('');
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Patient ${widget.patientId} Profile',
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.white,
            fontSize: 22,
            fontFamily: 'Poppins',
          ),
        ),
        backgroundColor: Colors.blueAccent.shade700,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFB3E5FC), Color(0xFFE1BEE7)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              width: 360,
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.person,
                        size: 32,
                        color: Colors.blueAccent.shade700,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Patient ${widget.patientId}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Text(
                    isRequestingHelp
                        ? 'Requesting Help'
                        : 'Not Requesting Help',
                    style: TextStyle(
                      fontSize: 16,
                      color: isRequestingHelp
                          ? Colors.redAccent
                          : Colors.grey.shade600,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 20),
                  AnimatedScaleButton(
                    onPressed: isNurseResponding ? () {} : toggleHelpRequest,
                    child: ElevatedButton.icon(
                      onPressed: isNurseResponding ? null : toggleHelpRequest,
                      icon: Icon(
                        isRequestingHelp ? Icons.cancel : Icons.help,
                        size: 20,
                        color: Colors.white,
                      ),
                      label: Text(
                        isRequestingHelp ? 'Cancel Request' : 'Request Help',
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isRequestingHelp
                            ? Colors.redAccent
                            : Colors.blueAccent.shade700,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 25, vertical: 14),
                        elevation: 4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  if (!isRequestingHelp && !isNurseResponding)
                    Text(
                      'Nurse will arrive if request is accepted.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        fontFamily: 'Poppins',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  if (isNurseResponding)
                    Text(
                      'Nurse is on the way!',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Custom widget for button with scale animation
class AnimatedScaleButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Widget child;

  const AnimatedScaleButton({required this.onPressed, required this.child});

  @override
  _AnimatedScaleButtonState createState() => _AnimatedScaleButtonState();
}

class _AnimatedScaleButtonState extends State<AnimatedScaleButton>
    with SingleTickerProviderStateMixin {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          _scale = 0.95;
        });
      },
      onTapUp: (_) {
        setState(() {
          _scale = 1.0;
        });
        widget.onPressed();
      },
      onTapCancel: () {
        setState(() {
          _scale = 1.0;
        });
      },
      child: Transform.scale(
        scale: _scale,
        child: widget.child,
      ),
    );
  }
}
