import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  runApp(const WondessenWorkshopApp());
}

class WondessenWorkshopApp extends StatelessWidget {
  const WondessenWorkshopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wondessen Workshop',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        primaryColor: const Color(0xFFFFE500),
      ),
      home: const MainHomeScreen(),
    );
  }
}

// የዳታ ሞዴሎች (Data Models) - ፎቶዎችን በ Base64 String ያስቀምጣል (Web እና Mobile ተስማሚ)
class ServiceFile {
  final String plateAndOwner;
  final String workDetails;
  final String? beforePhotoBase64;
  final String? afterPhotoBase64;
  final String? carPhotoBase64;
  final DateTime date;

  ServiceFile({
    required this.plateAndOwner,
    required this.workDetails,
    this.beforePhotoBase64,
    this.afterPhotoBase64,
    this.carPhotoBase64,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
        'plateAndOwner': plateAndOwner,
        'workDetails': workDetails,
        'beforePhotoBase64': beforePhotoBase64,
        'afterPhotoBase64': afterPhotoBase64,
        'carPhotoBase64': carPhotoBase64,
        'date': date.toIso8601String(),
      };

  factory ServiceFile.fromJson(Map<String, dynamic> json) => ServiceFile(
        plateAndOwner: json['plateAndOwner'] ?? '',
        workDetails: json['workDetails'] ?? '',
        beforePhotoBase64: json['beforePhotoBase64'],
        afterPhotoBase64: json['afterPhotoBase64'],
        carPhotoBase64: json['carPhotoBase64'],
        date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      );
}

class TransactionItem {
  final String title;
  final double amount;
  final bool isIncome; 
  final DateTime date;

  TransactionItem({
    required this.title,
    required this.amount,
    required this.isIncome,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'amount': amount,
        'isIncome': isIncome,
        'date': date.toIso8601String(),
      };

  factory TransactionItem.fromJson(Map<String, dynamic> json) => TransactionItem(
        title: json['title'] ?? '',
        amount: json['amount']?.toDouble() ?? 0.0,
        isIncome: json['isIncome'] ?? true,
        date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      );
}

// ዋና ማዕከል (Global Lists)
List<ServiceFile> globalServiceFiles = [];
List<TransactionItem> globalTransactions = [];

// ዳታዎችን በ SharedPreferences የማስቀመጫ እና የመጫኛ ፋንክሽኖች
Future<void> saveData() async {
  final prefs = await SharedPreferences.getInstance();
  
  final serviceListString = globalServiceFiles.map((e) => jsonEncode(e.toJson())).toList();
  await prefs.setStringList('saved_services', serviceListString);

  final txListString = globalTransactions.map((e) => jsonEncode(e.toJson())).toList();
  await prefs.setStringList('saved_transactions', txListString);
}

Future<void> loadData() async {
  final prefs = await SharedPreferences.getInstance();
  
  final serviceListString = prefs.getStringList('saved_services');
  if (serviceListString != null) {
    globalServiceFiles = serviceListString.map((e) => ServiceFile.fromJson(jsonDecode(e))).toList();
  }

  final txListString = prefs.getStringList('saved_transactions');
  if (txListString != null) {
    globalTransactions = txListString.map((e) => TransactionItem.fromJson(jsonDecode(e))).toList();
  } else {
    globalTransactions = [
      TransactionItem(title: 'የራዲያተር ሽያጭ እና ጥገና', amount: 14500, isIncome: true, date: DateTime.now()),
      TransactionItem(title: 'መጠባበቂያ ዕቃ ግዥ', amount: 3200, isIncome: false, date: DateTime.now()),
    ];
  }
}

class MainHomeScreen extends StatefulWidget {
  const MainHomeScreen({super.key});

  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  int _currentIndex = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData().then((_) {
      setState(() {
        _isLoading = false;
      });
    });
  }

  List<Widget> get _screens => [
    DashboardScreen(onDataChanged: () => setState(() {})),
    const CustomerRecordsScreen(),
    FinanceManagerScreen(onDataChanged: () => setState(() {})),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Color(0xFFFFE500))),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Row(
          children: const [
            Icon(Icons.flash_on, color: Color(0xFFFFE500)),
            SizedBox(width: 8),
            Text(
              'ወንደሰን ዎርክሾፕ',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        backgroundColor: const Color(0xFF1E1E1E),
        selectedItemColor: const Color(0xFFFFE500),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'ዳሽቦርድ'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'ደንበኞች'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: 'ገንዘብ'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'ቅንብር'),
        ],
      ),
    );
  }
}

// 1. ዳሽቦርድ ማያ ገጽ (Dashboard Screen)
class DashboardScreen extends StatefulWidget {
  final VoidCallback onDataChanged;
  const DashboardScreen({super.key, required this.onDataChanged});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    double totalIncome = globalTransactions.where((t) => t.isIncome).fold(0, (sum, t) => sum + t.amount);
    double totalExpense = globalTransactions.where((t) => !t.isIncome).fold(0, (sum, t) => sum + t.amount);
    double netProfit = totalIncome - totalExpense;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'FINANCE OVERVIEW',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              GestureDetector(
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AddServiceFileScreen()),
                  );
                  setState(() {});
                  widget.onDataChanged();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE500),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '+ አዲስ ፋይል ክፈት',
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
          const Text('Dashboard', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00FED4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('የዘርፍ ገቢ', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('Br ${totalIncome.toStringAsFixed(2)}', style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF2E93),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('የዘርፍ ወጪ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('Br ${totalExpense.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFFFE500),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Text('የተጣራ ትርፍ', style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Br ${netProfit.toStringAsFixed(2)}', style: const TextStyle(color: Colors.black, fontSize: 26, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text('በቀጥታ የተዘገበ ሂሳብ', style: TextStyle(color: Colors.black54, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFE500),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: () => _showAddTransactionDialog(context, true),
            icon: const Icon(Icons.add),
            label: const Text('ገቢ መመዝገቢያ', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF2E93),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: () => _showAddTransactionDialog(context, false),
            icon: const Icon(Icons.remove),
            label: const Text('ወጪ መመዝገቢያ', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showAddTransactionDialog(BuildContext context, bool isIncome) {
    final titleController = TextEditingController();
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: Text(isIncome ? 'ገቢ መመዝገቢያ' : 'ወጪ መመዝገቢያ', style: TextStyle(color: isIncome ? const Color(0xFF00FED4) : const Color(0xFFFF2E93))),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'መግለጫ / ምክንያት', labelStyle: TextStyle(color: Colors.grey)),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'መጠን (ብር)', labelStyle: TextStyle(color: Colors.grey)),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ሰርዝ', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFE500), foregroundColor: Colors.black),
              onPressed: () async {
                if (titleController.text.isNotEmpty && amountController.text.isNotEmpty) {
                  double? amount = double.tryParse(amountController.text);
                  if (amount != null) {
                    setState(() {
                      globalTransactions.add(TransactionItem(
                        title: titleController.text,
                        amount: amount,
                        isIncome: isIncome,
                        date: DateTime.now(),
                      ));
                    });
                    await saveData();
                    widget.onDataChanged();
                    Navigator.pop(context);
                  }
                }
              },
              child: const Text('መዝግብ'),
            ),
          ],
        );
      },
    );
  }
}

// 2. አዲስ ፋይል መክፈቻ ገጽ
class AddServiceFileScreen extends StatefulWidget {
  const AddServiceFileScreen({super.key});

  @override
  State<AddServiceFileScreen> createState() => _AddServiceFileScreenState();
}

class _AddServiceFileScreenState extends State<AddServiceFileScreen> {
  final _plateController = TextEditingController();
  final _detailsController = TextEditingController();
  
  Uint8List? _beforePhotoBytes;
  Uint8List? _afterPhotoBytes;
  Uint8List? _carPhotoBytes;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(int type) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      var bytes = await image.readAsBytes();
      setState(() {
        if (type == 1) _beforePhotoBytes = bytes;
        if (type == 2) _afterPhotoBytes = bytes;
        if (type == 3) _carPhotoBytes = bytes;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('አዲስ ፋይል መክፈቻ', style: TextStyle(color: Color(0xFFFFE500))),
        backgroundColor: const Color(0xFF1E1E1E),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text('ADD NEW SERVICE FILE', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 16),
            TextField(
              controller: _plateController,
              decoration: InputDecoration(
                labelText: 'የመኪና ሰሌዳ እና ባለቤት ስም',
                filled: true,
                fillColor: const Color(0xFF1E1E1E),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _detailsController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'የተሰራው ስራ ዝርዝር',
                filled: true,
                fillColor: const Color(0xFF1E1E1E),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 20),
            const Text('የፎቶ ማስረጃዎች', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFFFFE500))),
            const SizedBox(height: 10),
            Row(
              children: [
                _buildImagePlaceholder('ከመሰራቱ በፊት', _beforePhotoBytes, () => _pickImage(1)),
                const SizedBox(width: 10),
                _buildImagePlaceholder('ከተሰራ በኋላ', _afterPhotoBytes, () => _pickImage(2)),
                const SizedBox(width: 10),
                _buildImagePlaceholder('የመኪናው ፎቶ', _carPhotoBytes, () => _pickImage(3)),
              ],
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFE500),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () async {
                if (_plateController.text.isNotEmpty) {
                  // ምስሎችን ወደ Base64 String በመቀየር በድርም ጭምር በቋሚነት እንዲቀመጡ ማድረግ
                  String? beforeBase64 = _beforePhotoBytes != null ? base64Encode(_beforePhotoBytes!) : null;
                  String? afterBase64 = _afterPhotoBytes != null ? base64Encode(_afterPhotoBytes!) : null;
                  String? carBase64 = _carPhotoBytes != null ? base64Encode(_carPhotoBytes!) : null;

                  globalServiceFiles.add(ServiceFile(
                    plateAndOwner: _plateController.text,
                    workDetails: _detailsController.text,
                    beforePhotoBase64: beforeBase64,
                    afterPhotoBase64: afterBase64,
                    carPhotoBase64: carBase64,
                    date: DateTime.now(),
                  ));
                  await saveData();
                  Navigator.pop(context);
                }
              },
              child: const Text('ፋይሉን መዝግብ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder(String label, Uint8List? bytes, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              height: 90,
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFFE500)),
                image: bytes != null ? DecorationImage(image: MemoryImage(bytes), fit: BoxFit.cover) : null,
              ),
              child: bytes == null ? const Center(child: Icon(Icons.camera_alt, color: Color(0xFFFFE500))) : null,
            ),
            const SizedBox(height: 6),
            Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}

// 3. ደንበኞች ፋይሎች ማሳያ (Customer Records)
class CustomerRecordsScreen extends StatefulWidget {
  const CustomerRecordsScreen({super.key});

  @override
  State<CustomerRecordsScreen> createState() => _CustomerRecordsScreenState();
}

class _CustomerRecordsScreenState extends State<CustomerRecordsScreen> {
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    final filteredFiles = globalServiceFiles.where((file) {
      return file.plateAndOwner.toLowerCase().contains(searchQuery.toLowerCase()) ||
             file.workDetails.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('VEHICLE FILES & RECORDS', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 12),
          TextField(
            decoration: InputDecoration(
              labelText: 'በሰሌዳ ቁጥር ወይም በባለቤት ስም ይፈልጉ',
              prefixIcon: const Icon(Icons.search, color: Color(0xFFFFE500)),
              filled: true,
              fillColor: const Color(0xFF1E1E1E),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onChanged: (value) {
              setState(() {
                searchQuery = value;
              });
            },
          ),
          const SizedBox(height: 12),
          Expanded(
            child: filteredFiles.isEmpty
                ? const Center(child: Text('ምንም የተመዘገበ የሰርቪስ ፋይል አልተገኘም', style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    itemCount: filteredFiles.length,
                    itemBuilder: (context, index) {
                      final file = filteredFiles[index];
                      return Card(
                        color: const Color(0xFF1E1E1E),
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text('ሰሌዳ/ባለቤት፦ ${file.plateAndOwner}', style: const TextStyle(color: Color(0xFFFFE500), fontWeight: FontWeight.bold)),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () async {
                                      setState(() {
                                        globalServiceFiles.remove(file);
                                      });
                                      await saveData();
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text('ዝርዝር፦ ${file.workDetails}', style: const TextStyle(color: Colors.white70)),
                              const SizedBox(height: 12),
                              const Divider(color: Colors.grey),
                              const SizedBox(height: 4),
                              const Text('የፎቶ ማስረጃዎች:', style: TextStyle(color: Color(0xFFFFE500), fontSize: 13, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  _buildSavedPhotoItem('ከመሰራቱ በፊት', file.beforePhotoBase64),
                                  _buildSavedPhotoItem('ከተሰራ በኋላ', file.afterPhotoBase64),
                                  _buildSavedPhotoItem('የመኪናው ፎቶ', file.carPhotoBase64),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSavedPhotoItem(String title, String? base64Str) {
    Uint8List? bytes;
    if (base64Str != null && base64Str.isNotEmpty) {
      try {
        bytes = base64Decode(base64Str);
      } catch (e) {
        bytes = null;
      }
    }

    return Column(
      children: [
        Container(
          width: 75,
          height: 75,
          decoration: BoxDecoration(
            color: Colors.black26,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade700),
            image: bytes != null
                ? DecorationImage(image: MemoryImage(bytes), fit: BoxFit.cover)
                : null,
          ),
          child: bytes == null
              ? const Icon(Icons.image_not_supported, color: Colors.grey, size: 24)
              : null,
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(fontSize: 10, color: Colors.white70),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// 4. የገንዘብ ማስተዳደሪያ (Finance Manager Screen)
class FinanceManagerScreen extends StatefulWidget {
  final VoidCallback onDataChanged;
  const FinanceManagerScreen({super.key, required this.onDataChanged});

  @override
  State<FinanceManagerScreen> createState() => _FinanceManagerScreenState();
}

class _FinanceManagerScreenState extends State<FinanceManagerScreen> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('የገንዘብ ዝውውር ታሪክ (Finance History)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 12),
          Expanded(
            child: globalTransactions.isEmpty
                ? const Center(child: Text('ምንም የሂሳብ መረጃ የለም', style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    itemCount: globalTransactions.length,
                    itemBuilder: (context, index) {
                      final tx = globalTransactions[index];
                      return Card(
                        color: const Color(0xFF1E1E1E),
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: Icon(
                            tx.isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                            color: tx.isIncome ? const Color(0xFF00FED4) : const Color(0xFFFF2E93),
                          ),
                          title: Text(tx.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          subtitle: Text('${tx.date.year}-${tx.date.month}-${tx.date.day}', style: const TextStyle(color: Colors.grey)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${tx.isIncome ? '+' : '-'} Br ${tx.amount.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: tx.isIncome ? const Color(0xFF00FED4) : const Color(0xFFFF2E93),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                onPressed: () async {
                                  setState(() {
                                    globalTransactions.remove(tx);
                                  });
                                  await saveData();
                                  widget.onDataChanged();
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// 5. ቅንብሮች (Settings Screen)
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'የወንደሰን ዎርክሾፕ መተግበሪያ (v1.0)',
        style: TextStyle(color: Colors.white, fontSize: 16),
      ),
    );
  }
}