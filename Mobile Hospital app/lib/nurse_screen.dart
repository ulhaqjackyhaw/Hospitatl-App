import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class NurseScreen extends StatefulWidget {
  @override
  _NurseScreenState createState() => _NurseScreenState();
}

class _NurseScreenState extends State<NurseScreen> {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  void acknowledgePatientRequest(int patientId) {
    _db.child('iot/patient$patientId/pesan').set('sudah ditangani');
    _db.child('iot/led$patientId').set(false);
  }

  void refreshData() {
    setState(() {}); // Rebuild UI
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Nurse Dashboard',
          style: TextStyle(
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildPatientCard(
                context,
                patientId: 1,
                messageStream: _db.child('iot/patient1/pesan').onValue,
                countStream: _db.child('iot/patient1/count').onValue,
                onAcknowledge: () => acknowledgePatientRequest(1),
              ),
              const SizedBox(height: 30),
              _buildPatientCard(
                context,
                patientId: 2,
                messageStream: _db.child('iot/patient2/pesan').onValue,
                countStream: _db.child('iot/patient2/count').onValue,
                onAcknowledge: () => acknowledgePatientRequest(2),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: refreshData,
        backgroundColor: Colors.blueAccent.shade700,
        child: const Icon(Icons.refresh, color: Colors.white),
        elevation: 4,
        tooltip: 'Refresh Data',
      ),
    );
  }

  Widget _buildPatientCard(
    BuildContext context, {
    required int patientId,
    required Stream<DatabaseEvent> messageStream,
    required Stream<DatabaseEvent> countStream,
    required VoidCallback onAcknowledge,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        width: 360,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: StreamBuilder<DatabaseEvent>(
          stream: messageStream,
          builder: (context, snapshot) {
            String message = 'Loading...';
            if (snapshot.connectionState == ConnectionState.active) {
              message = (snapshot.data?.snapshot.value ?? 'No Request') as String;
            }

            return StreamBuilder<DatabaseEvent>(
              stream: countStream,
              builder: (context, countSnapshot) {
                int count = 0;
                if (countSnapshot.connectionState == ConnectionState.active) {
                  final value = countSnapshot.data?.snapshot.value;
                  count = (value is int) ? value : 0;
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.person,
                            size: 32, color: Colors.blueAccent.shade700),
                        const SizedBox(width: 12),
                        Text(
                          'Patient $patientId',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Poppins',
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Status: $message',
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Poppins',
                        color: message == 'No Request'
                            ? Colors.grey.shade600
                            : Colors.redAccent,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Total Requests: $count',
                      style: const TextStyle(
                        fontSize: 15,
                        fontFamily: 'Poppins',
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerRight,
                      child: AnimatedScaleButton(
                        onPressed: onAcknowledge,
                        child: ElevatedButton.icon(
                          onPressed: onAcknowledge,
                          icon: const Icon(Icons.check_circle,
                              size: 20, color: Colors.white),
                          label: const Text(
                            'Acknowledge',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent.shade700,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            elevation: 4,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

// Custom widget for animated button tap
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
