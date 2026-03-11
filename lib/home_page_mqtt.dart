import 'package:flutter/material.dart';
import 'flushing_service.dart';
import 'mqtt_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final FlushingService _service = FlushingService();
  late MqttService _mqtt;
  final String mobileClientId = '63654b3c-3aed-4575-bdea-6ae340dd9568';
  final String mobileToken = 'uYFNZRPa6KAnQgS1Uvbp9kJYsQZ2Pk5L';
  final String mobileSecret = 'nFPR4igYpGmYqnwat26TcX9xayv5dBFu';

  late bool isCanFlush;
  late AnimationController _animController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );

    _service.getFlushingStatus().then((status) {
      setState(() {
        isCanFlush = status;
      });
    }).catchError((error) {
      print('Error fetching Flushing status: $error');
    });

    _mqtt = MqttService(
      clientId: mobileClientId,
      token: mobileToken,
      secret: mobileSecret,
      isFlushChanged: (status) {
        setState(() {
          isCanFlush = status;
        });
      },
    );
    _mqtt.connect();
  }

  @override
  void dispose() {
    _animController.dispose();
    _mqtt.disconnect();
    super.dispose();
  }

  Future<void> toggleFlush() async {
    setState(() {
      isCanFlush = false;
    });
    await _service.setFlushingStatus(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            backgroundColor: const Color(0xFF0D1B2A),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E96FC).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFF1E96FC).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.water_drop_rounded,
                      color: Color(0xFF1E96FC),
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'FlushControl',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF0D1B2A), Color(0xFF112240)],
                  ),
                ),
              ),
            ),
          ),
          SliverFillRemaining(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Status Banner
                  _buildStatusBanner(),
                  const SizedBox(height: 24),
                  // Main Flush Card
                  Expanded(child: _buildFlushCard()),
                  const SizedBox(height: 20),
                  // Connection Status
                  _buildConnectionStatus(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isCanFlush
            ? const Color(0xFF0A3D2E)
            : const Color(0xFF2D1B00),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCanFlush
              ? const Color(0xFF00C896).withOpacity(0.4)
              : const Color(0xFFFF9A3C).withOpacity(0.4),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCanFlush
                  ? const Color(0xFF00C896)
                  : const Color(0xFFFF9A3C),
              boxShadow: [
                BoxShadow(
                  color: isCanFlush
                      ? const Color(0xFF00C896).withOpacity(0.6)
                      : const Color(0xFFFF9A3C).withOpacity(0.6),
                  blurRadius: 6,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            isCanFlush ? 'พร้อมใช้งาน' : 'กำลังดำเนินการ...',
            style: TextStyle(
              color: isCanFlush
                  ? const Color(0xFF00C896)
                  : const Color(0xFFFF9A3C),
              fontWeight: FontWeight.w600,
              fontSize: 13,
              letterSpacing: 0.3,
            ),
          ),
          const Spacer(),
          Text(
            isCanFlush ? 'READY' : 'FLUSHING',
            style: TextStyle(
              color: isCanFlush
                  ? const Color(0xFF00C896).withOpacity(0.7)
                  : const Color(0xFFFF9A3C).withOpacity(0.7),
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlushCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF112240), Color(0xFF0D1B2A)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.07),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon Area
          AnimatedBuilder(
            animation: _pulseAnim,
            builder: (context, child) {
              return Transform.scale(
                scale: isCanFlush ? _pulseAnim.value : 1.0,
                child: child,
              );
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer glow ring
                Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        (isCanFlush
                                ? const Color(0xFF1E96FC)
                                : const Color(0xFF475569))
                            .withOpacity(0.15),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                // Inner circle
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCanFlush
                        ? const Color(0xFF1E3A5F)
                        : const Color(0xFF1E2A3A),
                    border: Border.all(
                      color: isCanFlush
                          ? const Color(0xFF1E96FC).withOpacity(0.5)
                          : const Color(0xFF475569).withOpacity(0.3),
                      width: 2,
                    ),
                    boxShadow: isCanFlush
                        ? [
                            BoxShadow(
                              color: const Color(0xFF1E96FC).withOpacity(0.3),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ]
                        : [],
                  ),
                  child: Icon(
                    Icons.water_drop_rounded,
                    size: 64,
                    color: isCanFlush
                        ? const Color(0xFF1E96FC)
                        : const Color(0xFF475569),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Label
          Text(
            isCanFlush ? 'พร้อมกด Flush' : 'กำลัง Flush...',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isCanFlush
                ? 'แตะปุ่มด้านล่างเพื่อเริ่มการ flush'
                : 'กรุณารอสักครู่...',
            style: TextStyle(
              color: Colors.white.withOpacity(0.45),
              fontSize: 13,
              letterSpacing: 0.2,
            ),
          ),

          const SizedBox(height: 36),

          // Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: GestureDetector(
              onTap: isCanFlush ? toggleFlush : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: double.infinity,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: isCanFlush
                      ? const LinearGradient(
                          colors: [Color(0xFF1E96FC), Color(0xFF0A6EBD)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: isCanFlush ? null : const Color(0xFF1E2A3A),
                  boxShadow: isCanFlush
                      ? [
                          BoxShadow(
                            color: const Color(0xFF1E96FC).withOpacity(0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                        ]
                      : [],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isCanFlush
                          ? Icons.play_circle_rounded
                          : Icons.hourglass_top_rounded,
                      color: isCanFlush
                          ? Colors.white
                          : Colors.white.withOpacity(0.3),
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      isCanFlush ? 'Flush Now' : 'Please Wait...',
                      style: TextStyle(
                        color: isCanFlush
                            ? Colors.white
                            : Colors.white.withOpacity(0.3),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
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

  Widget _buildConnectionStatus() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFF00C896),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          'Connected via MQTT',
          style: TextStyle(
            color: Colors.white.withOpacity(0.35),
            fontSize: 12,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}