// import 'package:flutter/widgets.dart';

// import 'package:flutter_easyloading/flutter_easyloading.dart';
// import 'package:get/get_navigation/src/root/get_material_app.dart';
// import 'package:sizer/sizer.dart';

// import 'package:stay_connected/routes/app_pages.dart';

// void main() async {
// //  Get.lazyPut<SocketService>(() => SocketService(), fenix: true);
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Sizer(
//       builder: (context, orientation, deviceType) => MediaQuery(
//         data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
//         child: GetMaterialApp(
//           debugShowCheckedModeBanner: false,
//           // theme: ThemeLight().theme,
//           builder: EasyLoading.init(),
//           initialRoute: AppPages.INITIAL,
//           getPages: AppPages.routes,
//         ),
//       ),
//     );
//   }
// }
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:convert' show ascii;
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';

/// --- WAV helper (wrap PCM16LE into a minimal WAV file) ---
Uint8List pcm16ToWav(
  Uint8List pcmBytes, {
  int sampleRate = 48000, // Lyria outputs 48kHz
  int channels = 2,
}) {
  final byteRate = sampleRate * channels * 2;
  final blockAlign = channels * 2;
  final dataLength = pcmBytes.length;
  final fileLength = 36 + dataLength;

  final header = BytesBuilder();
  header.add(ascii.encode('RIFF'));
  header.add(_intToBytes(fileLength, 4));
  header.add(ascii.encode('WAVE'));
  header.add(ascii.encode('fmt '));
  header.add(_intToBytes(16, 4)); // fmt chunk size
  header.add(_intToBytes(1, 2)); // PCM format
  header.add(_intToBytes(channels, 2));
  header.add(_intToBytes(sampleRate, 4));
  header.add(_intToBytes(byteRate, 4));
  header.add(_intToBytes(blockAlign, 2));
  header.add(_intToBytes(16, 2)); // bits per sample
  header.add(ascii.encode('data'));
  header.add(_intToBytes(dataLength, 4));
  header.add(pcmBytes);

  return header.toBytes();
}

Uint8List _intToBytes(int value, int byteCount) {
  final b = ByteData(byteCount);
  if (byteCount == 2) {
    b.setInt16(0, value, Endian.little);
  } else {
    b.setInt32(0, value, Endian.little);
  }
  return b.buffer.asUint8List();
}

/// --- Lyria (WebSocket) + Playback Service ---
class LyriaRealtimeService {
  final String apiKey;
  final AudioPlayer player = AudioPlayer();
  IOWebSocketChannel? _channel;

  final ConcatenatingAudioSource _concat = ConcatenatingAudioSource(
    children: [],
  );
  List<int> _pendingPcm = [];
  int _segmentIndex = 0;
  bool _isConnected = false;
  bool _setupComplete = false; // Added missing variable
  String? _tempDir;

  // Lyria specs: 48kHz, 2 channels, 16-bit
  final int sampleRate = 48000;
  final int channels = 2;
  final int _bytesPerSample = 2;
  final double secondsPerSegment = 2.0; // Longer segments for better stability

  LyriaRealtimeService({required this.apiKey});

  int get _segmentSizeBytes =>
      (sampleRate * channels * _bytesPerSample * secondsPerSegment).toInt();

  Future<void> connect() async {
    try {
      // Get temporary directory
      final tempDirectory = await getTemporaryDirectory();
      _tempDir = tempDirectory.path;
      
      // Clear any existing temp files
      await _clearTempFiles();

      final url = Uri.parse(
        'wss://generativelanguage.googleapis.com/ws/google.ai.generativelanguage.v1alpha.GenerativeService.BidiGenerateMusic',
      );

      debugPrint('🔄 Connecting to: $url');
      
      _channel = IOWebSocketChannel.connect(
        url,
        headers: {
          'x-goog-api-key': "AIzaSyDIH-7Fp4Do6zP2lMX4YDbgCEcigFYbAuc",
          'Content-Type': 'application/json',
        },
      );

      await player.setAudioSource(_concat);

      _channel!.stream.listen(
        (message) async {
          try {
            if (message is String) {
              debugPrint('⬅️ Received: ${message.length > 200 ? '${message.substring(0, 200)}...' : message}');
              await _handleMessage(message);
            }
          } catch (e, st) {
            debugPrint('❌ Error processing message: $e\n$st');
          }
        },
        onError: (err) {
          debugPrint('❌ WebSocket error: $err');
          _isConnected = false;
        },
        onDone: () {
          debugPrint('🔌 WebSocket closed by server');
          _isConnected = false;
        },
        cancelOnError: false,
      );

      // Wait a moment for connection to establish
      await Future.delayed(const Duration(milliseconds: 200));
      
      // Send setup message
      await _sendSetupSequence();
      _isConnected = true;
      
      debugPrint('✅ Connected successfully!');
    } catch (e, st) {
      debugPrint('❌ Connection failed: $e\n$st');
      _isConnected = false;
      rethrow;
    }
  }

  // Added missing testBasicConnection method
  Future<void> testBasicConnection() async {
    try {
      debugPrint('🧪 Testing basic connection with API key...');
      
      final url = Uri.parse(
        'wss://generativelanguage.googleapis.com/ws/google.ai.generativelanguage.v1alpha.GenerativeService.BidiGenerateMusic',
      );

      final testChannel = IOWebSocketChannel.connect(
        url,
        headers: {
          'x-goog-api-key': apiKey,
          'Content-Type': 'application/json',
        },
      );

      bool connectionSuccessful = false;
      
      // Listen for any response to confirm connection
      testChannel.stream.listen(
        (message) {
          debugPrint('✅ Test connection successful - received response');
          connectionSuccessful = true;
        },
        onError: (err) {
          debugPrint('❌ Test connection failed: $err');
        },
        onDone: () {
          debugPrint('🔌 Test connection closed');
        },
      );

      // Send a simple setup message to test
      testChannel.sink.add(jsonEncode({
        'setup': {
          'model': 'models/lyria-realtime-exp',
        },
      }));

      // Wait for response
      await Future.delayed(const Duration(seconds: 3));
      
      // Close test connection
      await testChannel.sink.close();
      
      if (connectionSuccessful) {
        debugPrint('✅ API key appears to be valid');
      } else {
        debugPrint('⚠️ No response received - check API key and permissions');
      }
      
    } catch (e, st) {
      debugPrint('❌ Test connection error: $e\n$st');
    }
  }

  Future<void> _handleMessage(String message) async {
    final decoded = jsonDecode(message);
    
    // Handle setup acknowledgment
    if (decoded.containsKey('setupComplete')) {
      debugPrint('✅ Setup acknowledged by server');
      _setupComplete = true;
      return;
    }
    
    // Handle audio chunks
    final serverContent = decoded['serverContent'];
    if (serverContent != null) {
      final audioChunks = serverContent['audioChunks'];
      if (audioChunks != null && audioChunks is List) {
        for (var chunk in audioChunks) {
          final base64Data = chunk['data'];
          if (base64Data != null && base64Data is String) {
            try {
              final pcmBytes = base64Decode(base64Data);
              _pendingPcm.addAll(pcmBytes);
              debugPrint('🎵 Received ${pcmBytes.length} bytes of audio data');
            } catch (e) {
              debugPrint('❌ Failed to decode audio data: $e');
            }
          }
        }
        
        // Process complete segments
        while (_pendingPcm.length >= _segmentSizeBytes) {
          final segmentPcm = Uint8List.fromList(
            _pendingPcm.sublist(0, _segmentSizeBytes),
          );
          _pendingPcm = _pendingPcm.sublist(_segmentSizeBytes);
          await _createAndQueueSegment(segmentPcm);
        }
      }
    }
    
    // Handle errors
    if (decoded.containsKey('error')) {
      debugPrint('❌ Server error: ${decoded['error']}');
    }
  }

  Future<void> _sendSetupSequence() async {
    // 1. Send setup
    _sendJson({
      'setup': {
        'model': 'models/lyria-realtime-exp',
      },
    });
    
    await Future.delayed(const Duration(milliseconds: 300));
    
    // 2. Send initial configuration and prompts
    _sendJson({
      'clientContent': {
        'musicGenerationConfig': {
          'bpm': 120,
          'temperature': 1.1,
          'guidance': 4.0,
          'density': 0.7,
          'brightness': 0.5,
        },
        'setWeightedPrompts': {
          'weightedPrompts': [
            {'text': 'Piano', 'weight': 1.5},
            {'text': 'Ambient', 'weight': 1.0},
            {'text': 'Peaceful', 'weight': 0.8},
          ],
        },
      },
    });
    
    await Future.delayed(const Duration(milliseconds: 300));
    
    // 3. Start playback
    _sendJson({
      'clientContent': {
        'playbackControl': {
          'action': 'PLAY',
        },
      },
    });
  }

  Future<void> _createAndQueueSegment(Uint8List pcmSegment) async {
    try {
      final wav = pcm16ToWav(
        pcmSegment,
        sampleRate: sampleRate,
        channels: channels,
      );
      
      final fileName = 'lyria_segment_${_segmentIndex++}.wav';
      final filePath = '$_tempDir/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(wav, flush: true);

      final src = AudioSource.uri(Uri.file(filePath));
      await _concat.add(src);

      if (!player.playing) {
        await player.play();
      }
      
      debugPrint('🎶 Queued segment: $fileName (${wav.length} bytes)');
      
      // Clean up old files to prevent storage buildup
      _cleanupOldSegments();
    } catch (e, st) {
      debugPrint('❌ Error queueing segment: $e\n$st');
    }
  }

  void _cleanupOldSegments() {
    // Keep only recent segments to prevent storage issues
    if (_concat.length > 10) {
      try {
        _concat.removeAt(0);
      } catch (e) {
        debugPrint('⚠️ Warning: Could not remove old segment: $e');
      }
    }
  }

  Future<void> _clearTempFiles() async {
    try {
      final tempDir = Directory(_tempDir!);
      if (await tempDir.exists()) {
        await for (final file in tempDir.list()) {
          if (file.path.contains('lyria_segment_')) {
            await file.delete();
          }
        }
      }
    } catch (e) {
      debugPrint('⚠️ Could not clear temp files: $e');
    }
  }

  void _sendJson(Map<String, dynamic> json) {
    if (_channel == null || !_isConnected) {
      debugPrint('⚠️ Cannot send message: not connected');
      return;
    }
    
    try {
      final txt = jsonEncode(json);
      _channel!.sink.add(txt);
      debugPrint('➡️ Sent: ${txt.length > 200 ? '${txt.substring(0, 200)}...' : txt}');
    } catch (e) {
      debugPrint('❌ Failed to send message: $e');
    }
  }

  // Public methods for controlling music generation
  void updatePrompts(List<Map<String, dynamic>> prompts) {
    _sendJson({
      'client_content': {
        'weighted_prompts': prompts,
      },
    });
  }

  void updateConfig({
    int? bpm,
    double? temperature,
    double? guidance,
    double? density,
    double? brightness,
  }) {
    final config = <String, dynamic>{};
    if (bpm != null) config['bpm'] = bpm;
    if (temperature != null) config['temperature'] = temperature;
    if (guidance != null) config['guidance'] = guidance;
    if (density != null) config['density'] = density;
    if (brightness != null) config['brightness'] = brightness;

    _sendJson({
      'music_generation_config': config,
    });
    
    // Reset context for major changes like BPM
    if (bpm != null) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _sendJson({
          'playback_control': 'RESET_CONTEXT',
        });
      });
    }
  }

  void play() {
    _sendJson({
      'playback_control': 'PLAY',
    });
  }

  void pause() {
    _sendJson({
      'playback_control': 'PAUSE',
    });
  }

  void stop() {
    _sendJson({
      'playback_control': 'STOP',
    });
  }

  bool get isConnected => _isConnected;

  Future<void> close() async {
    try {
      _isConnected = false;
      _setupComplete = false;
      await player.stop();
      await player.dispose();
      await _channel?.sink.close();
      await _clearTempFiles();
    } catch (e) {
      debugPrint('⚠️ Error during cleanup: $e');
    }
  }
}

/// --- Flutter UI ---
void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lyria RealTime Player',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  LyriaRealtimeService? _service;
  final TextEditingController _apiController = TextEditingController();
  bool _connected = false;
  bool _isConnecting = false;
  String _status = 'Disconnected';
  
  // Controls for real-time adjustment
  double _bpm = 120;
  double _temperature = 1.1;
  double _guidance = 4.0;
  double _density = 0.7;
  double _brightness = 0.5;

  @override
  void dispose() {
    _service?.close();
    _apiController.dispose();
    super.dispose();
  }

  Future<void> _connect() async {
    final key = _apiController.text.trim();
    if (key.isEmpty) {
      _showSnackBar('Please enter your Gemini API key');
      return;
    }

    setState(() {
      _isConnecting = true;
      _status = 'Connecting...';
    });

    _service = LyriaRealtimeService(apiKey: key);
    
    try {
      await _service!.connect();
      setState(() {
        _connected = true;
        _isConnecting = false;
        _status = 'Connected - Generating music...';
      });
      _showSnackBar('Connected! Music generation started.');
    } catch (e) {
      debugPrint('❌ Connection failed: $e');
      _service?.close();
      _service = null;
      setState(() {
        _connected = false;
        _isConnecting = false;
        _status = 'Connection failed: ${e.toString()}';
      });
      _showSnackBar('Connection failed. Check your API key and internet connection.');
    }
  }

  void _disconnect() {
    _service?.close();
    _service = null;
    setState(() {
      _connected = false;
      _status = 'Disconnected';
    });
  }

  void _testConnection() async {
    final key = _apiController.text.trim();
    if (key.isEmpty) {
      _showSnackBar('Please enter your API key first');
      return;
    }

    setState(() {
      _status = 'Testing connection...';
    });

    final testService = LyriaRealtimeService(apiKey: key);
    await testService.testBasicConnection();
    
    setState(() {
      _status = 'Test completed - check debug logs';
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _updateConfig() {
    _service?.updateConfig(
      bpm: _bpm.round(),
      temperature: _temperature,
      guidance: _guidance,
      density: _density,
      brightness: _brightness,
    );
  }

  void _changePrompts(String genre) {
    final prompts = <String, List<Map<String, dynamic>>>{
      'ambient': [
        {'text': 'Ambient', 'weight': 2.0},
        {'text': 'Ethereal', 'weight': 1.0},
        {'text': 'Peaceful', 'weight': 0.8},
      ],
      'electronic': [
        {'text': 'Electronic', 'weight': 2.0},
        {'text': 'Synthesizer', 'weight': 1.5},
        {'text': 'Upbeat', 'weight': 1.0},
      ],
      'classical': [
        {'text': 'Piano', 'weight': 2.0},
        {'text': 'Classical', 'weight': 1.5},
        {'text': 'Orchestra', 'weight': 1.0},
      ],
      'jazz': [
        {'text': 'Jazz', 'weight': 2.0},
        {'text': 'Saxophone', 'weight': 1.0},
        {'text': 'Smooth', 'weight': 0.8},
      ],
    };
    
    _service?.updatePrompts(prompts[genre] ?? prompts['ambient']!);
    _showSnackBar('Changed to $genre style');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lyria RealTime Music'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // API Key Input
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'API Configuration',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _apiController,
                      decoration: const InputDecoration(
                        labelText: 'Gemini API Key',
                        hintText: 'Enter your API key from Google AI Studio',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.key),
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Status: $_status',
                      style: TextStyle(
                        color: _connected ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Connection Controls
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Connection',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: (_connected || _isConnecting) ? null : _connect,
                            icon: _isConnecting 
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.play_arrow),
                            label: Text(_isConnecting ? 'Connecting...' : 'Connect & Play'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _connected ? _disconnect : null,
                            icon: const Icon(Icons.stop),
                            label: const Text('Disconnect'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade100,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Test Connection Button
                    Center(
                      child: TextButton.icon(
                        onPressed: _testConnection,
                        icon: const Icon(Icons.wifi_protected_setup),
                        label: const Text('Test Connection'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Music Style Selection
            if (_connected) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Music Styles',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          'ambient',
                          'electronic',
                          'classical',
                          'jazz',
                        ].map((style) => ElevatedButton(
                          onPressed: () => _changePrompts(style),
                          child: Text(style.toUpperCase()),
                        )).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Real-time Controls
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Live Controls',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      
                      _buildSlider('BPM', _bpm, 60, 200, (value) {
                        setState(() => _bpm = value);
                      }),
                      
                      _buildSlider('Temperature', _temperature, 0.0, 3.0, (value) {
                        setState(() => _temperature = value);
                      }),
                      
                      _buildSlider('Guidance', _guidance, 0.0, 6.0, (value) {
                        setState(() => _guidance = value);
                      }),
                      
                      _buildSlider('Density', _density, 0.0, 1.0, (value) {
                        setState(() => _density = value);
                      }),
                      
                      _buildSlider('Brightness', _brightness, 0.0, 1.0, (value) {
                        setState(() => _brightness = value);
                      }),
                      
                      const SizedBox(height: 12),
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: _updateConfig,
                          icon: const Icon(Icons.update),
                          label: const Text('Apply Changes'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Playback Controls
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Playback Controls',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () => _service?.play(),
                            icon: const Icon(Icons.play_arrow),
                            label: const Text('Play'),
                          ),
                          ElevatedButton.icon(
                            onPressed: () => _service?.pause(),
                            icon: const Icon(Icons.pause),
                            label: const Text('Pause'),
                          ),
                          ElevatedButton.icon(
                            onPressed: () => _service?.stop(),
                            icon: const Icon(Icons.stop),
                            label: const Text('Stop'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
            
            const SizedBox(height: 24),
            
            // Instructions
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'Instructions',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '1. Get your API key from Google AI Studio\n'
                      '2. Enter the key above and tap "Connect & Play"\n'
                      '3. Wait for music generation to start\n'
                      '4. Use style buttons to change music genre\n'
                      '5. Adjust sliders and tap "Apply Changes" for real-time control',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlider(
    String label,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
            Text(
              value.toStringAsFixed(label == 'BPM' ? 0 : 1),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: label == 'BPM' ? (max - min).round() : 100,
          onChanged: onChanged,
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}