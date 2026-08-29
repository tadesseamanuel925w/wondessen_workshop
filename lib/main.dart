import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:video_player/video_player.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const WendesenWorkshopApp());
}

// ---------------- ለማውዝ እና ታች ሁለቱም ስክሮል ማድረጊያ ----------------
class CustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
      };
}

// ---------------- የዳታ አወቃቀር ለሚዲያ ----------------
class MediaItem {
  final XFile file;
  final Uint8List? bytes;
  final bool isVideo;

  MediaItem({required this.file, this.bytes, required this.isVideo});
}

// ---------------- የዳታ ማከማቻ ----------------
class AppData {
  static final List<Map<String, dynamic>> serviceFiles = [];

  static final List<Map<String, dynamic>> financeRecords = [
    {
      'id': '1',
      'title': 'ሆዝ የተቀየረበት',
      'date': '2026-08-14',
      'amount': 2000.0,
      'isIncome': true,
    },
    {
      'id': '2',
      'title': 'ለሆዝ ግዢ',
      'date': '2026-08-14',
      'amount': 1600.0,
      'isIncome': false,
    },
  ];

  static double get totalIncome {
    return financeRecords
        .where((item) => item['isIncome'] == true)
        .fold(0.0, (sum, item) => sum + (item['amount'] as double));
  }

  static double get totalExpense {
    return financeRecords
        .where((item) => item['isIncome'] == false)
        .fold(0.0, (sum, item) => sum + (item['amount'] as double));
  }

  static double get netProfit => totalIncome - totalExpense;
}

class WendesenWorkshopApp extends StatelessWidget {
  const WendesenWorkshopApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      scrollBehavior: CustomScrollBehavior(),
      title: 'ወንደሰን ዎርክሾፕ',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
        primaryColor: const Color(0xFFFFD700),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFFD700),
          secondary: Color(0xFF00E676),
          surface: Color(0xFF1E1E1E),
        ),
      ),
      home: const MainNavigationScreen(),
    );
  }
}

// ---------------- ዋና መነሻ ገጽ (Navigation) ----------------
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({Key? key}) : super(key: key);

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      DashboardScreen(onRefresh: () => setState(() {})),
      RecordsScreen(onRefresh: () => setState(() {})),
      FinanceHistoryScreen(onRefresh: () => setState(() {})),
      const Center(
          child: Text('ቅንብር (Settings)',
              style: TextStyle(color: Colors.white, fontSize: 18))),
    ];

    return Scaffold(
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF121212),
        selectedItemColor: const Color(0xFFFFD700),
        unselectedItemColor: Colors.white54,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.grid_view_rounded), label: 'ዳሽቦርድ'),
          BottomNavigationBarItem(
              icon: Icon(Icons.people_alt_outlined), label: 'ደንበኞች'),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet_outlined), label: 'ገንዘብ'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined), label: 'ቅንብር'),
        ],
      ),
    );
  }
}

// 1. Dashboard Screen
class DashboardScreen extends StatelessWidget {
  final VoidCallback onRefresh;
  const DashboardScreen({Key? key, required this.onRefresh}) : super(key: key);

  void _showIncomeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => CustomFinanceDialog(
        title: 'ገቢ መመዝገቢያ',
        titleColor: const Color(0xFF00E676),
        buttonColor: const Color(0xFFFFD700),
        isIncome: true,
        onSaved: onRefresh,
      ),
    );
  }

  void _showExpenseDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => CustomFinanceDialog(
        title: 'ወጪ መመዝገቢያ',
        titleColor: const Color(0xFFFF4081),
        buttonColor: const Color(0xFFFFD700),
        isIncome: false,
        onSaved: onRefresh,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.flash_on, color: Color(0xFFFFD700), size: 28),
                SizedBox(width: 8),
                Text('ወንደሰን ዎርክሾፕ',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('FINANCE OVERVIEW',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    Text('Dashboard',
                        style: TextStyle(color: Colors.white54, fontSize: 12)),
                  ],
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD700),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AddServiceFileScreen()),
                    );
                    onRefresh();
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('+ አዲስ ፋይል ክፈት',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00BFA5),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('ጠቅላላ ገቢ',
                            style: TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text('Br ${AppData.totalIncome.toStringAsFixed(2)}',
                            style: const TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF4081),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('ጠቅላላ ወጪ',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text('Br ${AppData.totalExpense.toStringAsFixed(2)}',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFD700),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Text('የተጣራ ትርፍ',
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                  const SizedBox(height: 6),
                  Text('Br ${AppData.netProfit.toStringAsFixed(2)}',
                      style: const TextStyle(
                          color: Colors.black,
                          fontSize: 26,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD700),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25)),
                ),
                onPressed: () => _showIncomeDialog(context),
                child: const Text('+ ገቢ መመዝገቢያ',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF4081),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25)),
                ),
                onPressed: () => _showExpenseDialog(context),
                child: const Text('— ወጪ መመዝገቢያ',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 2. አዲስ ፋይል መክፈቻ Screen
class AddServiceFileScreen extends StatefulWidget {
  const AddServiceFileScreen({Key? key}) : super(key: key);

  @override
  State<AddServiceFileScreen> createState() => _AddServiceFileScreenState();
}

class _AddServiceFileScreenState extends State<AddServiceFileScreen> {
  final TextEditingController _carModelController = TextEditingController();
  final TextEditingController _carInfoController = TextEditingController();
  final TextEditingController _workDetailController = TextEditingController();

  final TextEditingController _beforeItemTypeController = TextEditingController();
  final TextEditingController _afterItemTypeController = TextEditingController();
  final TextEditingController _carItemTypeController = TextEditingController();
  final TextEditingController _extraItemTypeController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _activeListeningField = '';

  final List<MediaItem> _beforeMediaList = [];
  final List<MediaItem> _afterMediaList = [];
  final List<MediaItem> _carMediaList = [];
  final List<MediaItem> _extraMediaList = [];

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  void _listenVoice(TextEditingController controller, String fieldName) async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() {
          _isListening = true;
          _activeListeningField = fieldName;
        });
        _speech.listen(onResult: (val) {
          setState(() {
            controller.text = val.recognizedWords;
          });
        });
      }
    } else {
      setState(() {
        _isListening = false;
        _activeListeningField = '';
      });
      _speech.stop();
    }
  }

  void _pickMediaOptions(List<MediaItem> targetList, String category) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF232323),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('ማስገቢያ ይምረጡ ($category)',
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFFD700))),
              const SizedBox(height: 15),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Color(0xFFFFD700)),
                title: const Text('ፎቶ አንሳ (Camera)'),
                onTap: () async {
                  Navigator.pop(context);
                  final media = await _picker.pickImage(source: ImageSource.camera);
                  if (media != null) {
                    final bytes = await media.readAsBytes();
                    setState(() {
                      targetList.add(MediaItem(file: media, bytes: bytes, isVideo: false));
                    });
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.videocam, color: Color(0xFFFFD700)),
                title: const Text('ቪዲዮ ቅረፅ (Video Record)'),
                onTap: () async {
                  Navigator.pop(context);
                  final media = await _picker.pickVideo(source: ImageSource.camera);
                  if (media != null) {
                    final bytes = await media.readAsBytes();
                    setState(() {
                      targetList.add(MediaItem(file: media, bytes: bytes, isVideo: true));
                    });
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Color(0xFFFFD700)),
                title: const Text('ከጋለሪ/ፋይል ምረጥ (Photos & Videos)'),
                onTap: () async {
                  Navigator.pop(context);
                  final List<XFile> mediaList = await _picker.pickMultipleMedia();
                  for (var media in mediaList) {
                    final bytes = await media.readAsBytes();
                    bool isVid = media.name.toLowerCase().endsWith('.mp4') || media.path.toLowerCase().endsWith('.mp4');
                    setState(() {
                      targetList.add(MediaItem(file: media, bytes: bytes, isVideo: isVid));
                    });
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _saveFile() {
    if (_carModelController.text.isEmpty || _carInfoController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('እባክዎ የመኪናውን ዓይነት እና ሰሌዳ/ባለቤት ይሙሉ!')),
      );
      return;
    }

    AppData.serviceFiles.insert(0, {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'carModel': _carModelController.text,
      'carInfo': _carInfoController.text,
      'workDetail': _workDetailController.text,
      'beforeItemType': _beforeItemTypeController.text,
      'afterItemType': _afterItemTypeController.text,
      'carItemType': _carItemTypeController.text,
      'extraItemType': _extraItemTypeController.text,
      'beforeMediaList': List<MediaItem>.from(_beforeMediaList),
      'afterMediaList': List<MediaItem>.from(_afterMediaList),
      'carMediaList': List<MediaItem>.from(_carMediaList),
      'extraMediaList': List<MediaItem>.from(_extraMediaList),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('ፋይሉ በስኬት ተመዝግቧል!')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('አዲስ ፋይል መክፈቻ',
            style: TextStyle(
                color: Color(0xFFFFD700), fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCustomInputBox(
              controller: _carModelController,
              hintText: 'የመኪናው ዓይነት (ለምሳሌ፦ Toyota Vitz)',
              fieldName: 'car_model',
            ),
            const SizedBox(height: 12),
            _buildCustomInputBox(
              controller: _carInfoController,
              hintText: 'የመኪና ሰሌዳ እና ባለቤት ስም',
              fieldName: 'car_info',
            ),
            const SizedBox(height: 12),
            _buildCustomInputBox(
              controller: _workDetailController,
              hintText: 'የተሰራው ስራ ዝርዝር',
              fieldName: 'work_detail',
              maxLines: 3,
            ),
            const SizedBox(height: 25),
            const Text('የፎቶ እና ቪዲዮ ማስረጃዎች',
                style: TextStyle(
                    color: Color(0xFFFFD700),
                    fontWeight: FontWeight.bold,
                    fontSize: 15)),
            const SizedBox(height: 12),
            _buildMediaSection(
              title: '1. ከመሰራቱ በፊት ማስረጃ',
              mediaList: _beforeMediaList,
              onTap: () => _pickMediaOptions(_beforeMediaList, 'ከመሰራቱ በፊት'),
              controller: _beforeItemTypeController,
              hintText: 'የ 1ኛው ዕቃ ዓይነት',
              fieldName: 'before_type',
            ),
            const SizedBox(height: 12),
            _buildMediaSection(
              title: '2. ከተሰራ በኋላ ማስረጃ',
              mediaList: _afterMediaList,
              onTap: () => _pickMediaOptions(_afterMediaList, 'ከተሰራ በኋላ'),
              controller: _afterItemTypeController,
              hintText: 'የ 2ኛው ዕቃ ዓይነት',
              fieldName: 'after_type',
            ),
            const SizedBox(height: 12),
            _buildMediaSection(
              title: '3. የመኪናው አጠቃላይ ፎቶ/ቪዲዮ',
              mediaList: _carMediaList,
              onTap: () => _pickMediaOptions(_carMediaList, 'የመኪናው አጠቃላይ'),
              controller: _carItemTypeController,
              hintText: 'የ 3ኛው ዕቃ ዓይነት',
              fieldName: 'car_type',
            ),
            const SizedBox(height: 12),
            _buildMediaSection(
              title: '4. ተጨማሪ የተለወጠ ዕቃ',
              mediaList: _extraMediaList,
              onTap: () => _pickMediaOptions(_extraMediaList, 'ተጨማሪ ዕቃ'),
              controller: _extraItemTypeController,
              hintText: 'የ 4ኛው ዕቃ ዓይነት',
              fieldName: 'extra_type',
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD700),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25)),
                ),
                onPressed: _saveFile,
                child: const Text('ፋይሉን መዝግብ',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaSection({
    required String title,
    required List<MediaItem> mediaList,
    required VoidCallback onTap,
    required TextEditingController controller,
    required String hintText,
    required String fieldName,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13)),
          const SizedBox(height: 8),
          Row(
            children: [
              InkWell(
                onTap: onTap,
                child: Container(
                  width: 85,
                  height: 75,
                  decoration: BoxDecoration(
                    color: const Color(0xFF262626),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: mediaList.isNotEmpty
                          ? const Color(0xFF00E676)
                          : const Color(0xFFFFD700),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        mediaList.isNotEmpty ? Icons.add_circle : Icons.add_a_photo_outlined,
                        color: mediaList.isNotEmpty ? const Color(0xFF00E676) : const Color(0xFFFFD700),
                        size: 24,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        mediaList.isEmpty ? '+ ጨምር' : '${mediaList.length} ሚዲያዎች',
                        style: TextStyle(
                            color: mediaList.isNotEmpty ? const Color(0xFF00E676) : Colors.white70,
                            fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildCustomInputBox(
                  controller: controller,
                  hintText: hintText,
                  fieldName: fieldName,
                ),
              ),
            ],
          ),
          if (mediaList.isNotEmpty) const SizedBox(height: 10),
          if (mediaList.isNotEmpty)
            SizedBox(
              height: 50,
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                itemCount: mediaList.length,
                itemBuilder: (context, idx) {
                  final item = mediaList[idx];
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    width: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: item.isVideo
                              ? Container(
                                  color: Colors.black87,
                                  child: const Center(
                                      child: Icon(Icons.play_arrow, color: Color(0xFFFFD700), size: 20)),
                                )
                              : (item.bytes != null
                                  ? Image.memory(item.bytes!, fit: BoxFit.cover, width: 50, height: 50)
                                  : Image.file(File(item.file.path), fit: BoxFit.cover, width: 50, height: 50)),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () => setState(() => mediaList.removeAt(idx)),
                            child: Container(
                              color: Colors.black54,
                              child: const Icon(Icons.close, color: Colors.redAccent, size: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCustomInputBox({
    required TextEditingController controller,
    required String hintText,
    required String fieldName,
    int maxLines = 1,
  }) {
    bool isListeningThis = _isListening && _activeListeningField == fieldName;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      child: Stack(
        children: [
          TextField(
            controller: controller,
            maxLines: maxLines,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.only(right: 35, top: 8, bottom: 8),
            ),
          ),
          Positioned(
            right: 0,
            top: 2,
            child: IconButton(
              icon: Icon(
                isListeningThis ? Icons.mic : Icons.mic_none,
                color: isListeningThis
                    ? Colors.redAccent
                    : const Color(0xFFFFD700),
                size: 18,
              ),
              onPressed: () => _listenVoice(controller, fieldName),
            ),
          ),
        ],
      ),
    );
  }
}

// 3. የፋይሎች እና የመኪናዎች ዝርዝር Screen (ተስተካክሏል)
class RecordsScreen extends StatefulWidget {
  final VoidCallback onRefresh;
  const RecordsScreen({Key? key, required this.onRefresh}) : super(key: key);

  @override
  State<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends State<RecordsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  void _deleteFile(String id) {
    setState(() {
      AppData.serviceFiles.removeWhere((file) => file['id'] == id);
    });
    widget.onRefresh();
  }

  void _openMediaViewer(MediaItem mediaItem) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenMediaViewer(mediaItem: mediaItem),
      ),
    );
  }

  Widget _buildMediaCard(String label, MediaItem item, String? itemType) {
    return GestureDetector(
      onTap: () => _openMediaViewer(item),
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        width: 110,
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: const Color(0xFF2B2B2B),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white12),
        ),
        child: Column(
          children: [
            Container(
              height: 70,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black45,
                borderRadius: BorderRadius.circular(6),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: item.isVideo
                    ? const Icon(Icons.play_circle_fill,
                        color: Color(0xFFFFD700), size: 36)
                    : (item.bytes != null
                        ? Image.memory(item.bytes!, fit: BoxFit.cover)
                        : (kIsWeb
                            ? Image.network(item.file.path, fit: BoxFit.cover)
                            : Image.file(File(item.file.path), fit: BoxFit.cover))),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                  color: Color(0xFFFFD700),
                  fontSize: 10,
                  fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (itemType != null && itemType.isNotEmpty)
              Text(
                itemType,
                style: const TextStyle(color: Colors.white70, fontSize: 9),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredFiles = AppData.serviceFiles.where((file) {
      final query = _searchQuery.toLowerCase();
      final model = file['carModel'].toString().toLowerCase();
      final info = file['carInfo'].toString().toLowerCase();
      return model.contains(query) || info.contains(query);
    }).toList();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.flash_on, color: Color(0xFFFFD700), size: 28),
                SizedBox(width: 8),
                Text('ወንደሰን ዎርክሾፕ',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ],
            ),
            const SizedBox(height: 15),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white24),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (val) => setState(() => _searchQuery = val),
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search, color: Color(0xFFFFD700)),
                  hintText: 'በመኪና፣ ሰሌዳ ወይም ባለቤት ይፈልጉ',
                  hintStyle: TextStyle(color: Colors.white38, fontSize: 13),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: filteredFiles.isEmpty
                  ? const Center(
                      child: Text('ምንም የተመዘገበ ፋይል የለም',
                          style: TextStyle(color: Colors.white54)))
                  : ListView.builder(
                      itemCount: filteredFiles.length,
                      itemBuilder: (context, index) {
                        final file = filteredFiles[index];
                        final beforeList = file['beforeMediaList'] as List<MediaItem>? ?? [];
                        final afterList = file['afterMediaList'] as List<MediaItem>? ?? [];
                        final carList = file['carMediaList'] as List<MediaItem>? ?? [];
                        final extraList = file['extraMediaList'] as List<MediaItem>? ?? [];

                        final List<Widget> allMediaWidgets = [
                          ...beforeList.map((m) => _buildMediaCard('1. ከመሰራቱ በፊት', m, file['beforeItemType'])),
                          ...afterList.map((m) => _buildMediaCard('2. ከተሰራ በኋላ', m, file['afterItemType'])),
                          ...carList.map((m) => _buildMediaCard('3. የመኪናው ፎቶ', m, file['carItemType'])),
                          ...extraList.map((m) => _buildMediaCard('4. ተጨማሪ ዕቃ', m, file['extraItemType'])),
                        ];

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E1E1E),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('ሰሌዳ/ባለቤት:- ${file['carInfo']}',
                                      style: const TextStyle(
                                          color: Color(0xFFFFD700),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15)),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline,
                                        color: Colors.redAccent),
                                    onPressed: () => _deleteFile(file['id']),
                                  ),
                                ],
                              ),
                              Text('የመኪናው ዓይነት:- ${file['carModel']}',
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 13)),
                              const SizedBox(height: 4),
                              Text('ዝርዝር:- ${file['workDetail']}',
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 12)),
                              const Divider(color: Colors.white12, height: 20),
                              
                              // እዚህ ጋ በጎን ስክሮል (Roll) እንዲያደርግ በ SizedBox እና BouncingScrollPhysics ተስተካክሏል
                              SizedBox(
                                height: 115,
                                child: ListView(
                                  physics: const BouncingScrollPhysics(),
                                  scrollDirection: Axis.horizontal,
                                  children: allMediaWidgets,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// 4. የገንዘብ ታሪክ Screen
class FinanceHistoryScreen extends StatefulWidget {
  final VoidCallback onRefresh;
  const FinanceHistoryScreen({Key? key, required this.onRefresh}) : super(key: key);

  @override
  State<FinanceHistoryScreen> createState() => _FinanceHistoryScreenState();
}

class _FinanceHistoryScreenState extends State<FinanceHistoryScreen> {
  void _deleteRecord(String id) {
    setState(() {
      AppData.financeRecords.removeWhere((rec) => rec['id'] == id);
    });
    widget.onRefresh();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.flash_on, color: Color(0xFFFFD700), size: 28),
                SizedBox(width: 8),
                Text('ወንደሰን ዎርክሾፕ',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ],
            ),
            const SizedBox(height: 20),
            const Text('የገንዘብ እንቅስቃሴ ታሪክ',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFFD700))),
            const SizedBox(height: 15),
            Expanded(
              child: AppData.financeRecords.isEmpty
                  ? const Center(
                      child: Text('ምንም የገንዘብ መዝገብ የለም',
                          style: TextStyle(color: Colors.white54)))
                  : ListView.builder(
                      itemCount: AppData.financeRecords.length,
                      itemBuilder: (context, index) {
                        final record = AppData.financeRecords[index];
                        final bool isIncome = record['isIncome'];

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E1E1E),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isIncome
                                  ? const Color(0xFF00E676).withOpacity(0.3)
                                  : const Color(0xFFFF4081).withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: isIncome
                                        ? const Color(0xFF00E676).withOpacity(0.2)
                                        : const Color(0xFFFF4081).withOpacity(0.2),
                                    child: Icon(
                                      isIncome
                                          ? Icons.arrow_downward
                                          : Icons.arrow_upward,
                                      color: isIncome
                                          ? const Color(0xFF00E676)
                                          : const Color(0xFFFF4081),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        record['title'],
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        record['date'],
                                        style: const TextStyle(
                                            color: Colors.white54, fontSize: 11),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    '${isIncome ? "+" : "-"} Br ${record['amount'].toStringAsFixed(2)}',
                                    style: TextStyle(
                                      color: isIncome
                                          ? const Color(0xFF00E676)
                                          : const Color(0xFFFF4081),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline,
                                        color: Colors.white38, size: 20),
                                    onPressed: () => _deleteRecord(record['id']),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// 5. ፎቶ/ቪዲዮ በሙሉ ስክሪን ማሳያ (Media Viewer)
class FullScreenMediaViewer extends StatefulWidget {
  final MediaItem mediaItem;

  const FullScreenMediaViewer({Key? key, required this.mediaItem})
      : super(key: key);

  @override
  State<FullScreenMediaViewer> createState() => _FullScreenMediaViewerState();
}

class _FullScreenMediaViewerState extends State<FullScreenMediaViewer> {
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();

    if (widget.mediaItem.isVideo) {
      if (kIsWeb) {
        _videoController =
            VideoPlayerController.networkUrl(Uri.parse(widget.mediaItem.file.path));
      } else {
        _videoController = VideoPlayerController.file(File(widget.mediaItem.file.path));
      }

      _videoController!.initialize().then((_) {
        setState(() {});
        _videoController!.play();
      });
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: widget.mediaItem.isVideo
            ? (_videoController != null && _videoController!.value.isInitialized
                ? AspectRatio(
                    aspectRatio: _videoController!.value.aspectRatio,
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        VideoPlayer(_videoController!),
                        VideoProgressIndicator(_videoController!,
                            allowScrubbing: true),
                        FloatingActionButton(
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                          onPressed: () {
                            setState(() {
                              _videoController!.value.isPlaying
                                  ? _videoController!.pause()
                                  : _videoController!.play();
                            });
                          },
                          child: Icon(
                            _videoController!.value.isPlaying
                                ? Icons.pause
                                : Icons.play_arrow,
                            color: const Color(0xFFFFD700),
                            size: 40,
                          ),
                        ),
                      ],
                    ),
                  )
                : const CircularProgressIndicator(color: Color(0xFFFFD700)))
            : (widget.mediaItem.bytes != null
                ? Image.memory(widget.mediaItem.bytes!)
                : (kIsWeb
                    ? Image.network(widget.mediaItem.file.path)
                    : Image.file(File(widget.mediaItem.file.path)))),
      ),
    );
  }
}

// 6. የገቢ/ወጪ መመዝገቢያ Dialog Widget
class CustomFinanceDialog extends StatefulWidget {
  final String title;
  final Color titleColor;
  final Color buttonColor;
  final bool isIncome;
  final VoidCallback onSaved;

  const CustomFinanceDialog({
    Key? key,
    required this.title,
    required this.titleColor,
    required this.buttonColor,
    required this.isIncome,
    required this.onSaved,
  }) : super(key: key);

  @override
  State<CustomFinanceDialog> createState() => _CustomFinanceDialogState();
}

class _CustomFinanceDialogState extends State<CustomFinanceDialog> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  void _saveFinanceRecord() {
    final title = _titleController.text;
    final amount = double.tryParse(_amountController.text);

    if (title.isEmpty || amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('እባክዎ ትክክለኛ መረጃ ይሙሉ!')),
      );
      return;
    }

    final now = DateTime.now();
    final dateStr =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    AppData.financeRecords.insert(0, {
      'id': now.millisecondsSinceEpoch.toString(),
      'title': title,
      'date': dateStr,
      'amount': amount,
      'isIncome': widget.isIncome,
    });

    widget.onSaved();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF232323),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.title,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: widget.titleColor)),
            const SizedBox(height: 15),
            TextField(
              controller: _titleController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'ምክንያት/መግለጫ (ለምሳሌ፦ የባሌስተራ ስራ)',
                hintStyle: TextStyle(color: Colors.white38, fontSize: 13),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white24)),
                focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFFFD700))),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'የገንዘብ መጠን (በብር)',
                hintStyle: TextStyle(color: Colors.white38, fontSize: 13),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white24)),
                focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFFFD700))),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('ሰርዝ',
                      style: TextStyle(color: Colors.white54)),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.buttonColor,
                    foregroundColor: Colors.black,
                  ),
                  onPressed: _saveFinanceRecord,
                  child: const Text('መዝግብ',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}