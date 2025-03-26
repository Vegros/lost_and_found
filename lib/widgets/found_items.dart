import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:lost_and_found/models/lost_Item.dart';
import 'package:lost_and_found/noti_service.dart';
import 'dart:typed_data';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class FoundItems extends StatefulWidget {
  const FoundItems({super.key});

  @override
  State<FoundItems> createState() {
    return _FoundItemsState();
  }
}

class _FoundItemsState extends State<FoundItems> {
  List<LostItem> lostItems = [];
  var isLoading = true;

  @override
  void initState() {
    super.initState();
    loadItem();
  }

  void removeItem(LostItem item) async {
    final url = Uri.https(
      'lost-and-found-9b9cd-default-rtdb.europe-west1.firebasedatabase.app',
      'lost_items/${item.id}.json',
    );
    final response = await http.delete(url);
    if (response.statusCode == 200) {
      setState(() {
        lostItems.remove(item);
      });
    }
    NotiService().showNotifications(
      id: 0,
      title: "Item Found",
      body: "The item ${item.name} marked as found",
    );
  }

  Future<void> loadItem() async {
    setState(() {
      isLoading = true;
    });

    final url = Uri.https(
      'lost-and-found-9b9cd-default-rtdb.europe-west1.firebasedatabase.app',
      'lost_items.json',
    );

    final response = await http.get(url);

    if (response.statusCode != 200) {
      setState(() {
        isLoading = false;
        lostItems = [];
      });
      return;
    }
    if (response.body == "null") {
      setState(() {
        isLoading = false;
        lostItems = [];
      });
      return;
    }

    final List<LostItem> loadedList = [];
    final Map<String, dynamic> firebaseData = json.decode(response.body);

    for (final item in firebaseData.entries) {
      final data = item.value;
      if (data == null || !data.containsKey('itemName')) {
        continue;
      }

      loadedList.add(
        LostItem(
          id: item.key,
          name: data['itemName'],
          date: data['date'],
          image: data['itemImage'],
          contactName: data['contactName'],
          contactEmail: data['contactEmail'],
          contactPhone: data['contactPhone'],
        ),
      );
    }

    if (!mounted) return;

    setState(() {
      isLoading = false;
      lostItems = loadedList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Items Found",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: loadItem,
        child:
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : lostItems.isEmpty
                ? const Center(child: Text('No Items in the list'))
                : ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: lostItems.length,
                  itemBuilder: (context, index) {
                    final item = lostItems[index];
                    return _buildLostItemCard(item);
                  },
                ),
      ),
    );
  }

  Widget _buildLostItemCard(LostItem item) {
    Uint8List? imageBytes;
    if (item.image.isNotEmpty) {
      imageBytes = base64Decode(item.image);
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: const Color(0xFF7845D2),
      shadowColor: const Color(0x56000000),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child:
                      imageBytes != null
                          ? Image.memory(
                            imageBytes,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          )
                          : const Icon(
                            Icons.image_not_supported,
                            size: 100,
                            color: Colors.white,
                          ),
                ),
                const SizedBox(width: 15),
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              "Contact Person",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                const Icon(Icons.person, color: Colors.purple),
                const SizedBox(width: 5),
                Text(
                  item.contactName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => launchUrl(Uri.parse("tel:${item.contactPhone}")),
                  child: Row(
                    children: [
                      const Icon(Icons.phone, color: Colors.blue),
                      const SizedBox(width: 5),
                      Text(
                        item.contactPhone,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            GestureDetector(
              onTap: () => launchUrl(Uri.parse("mailto:${item.contactEmail}")),
              child: Row(
                children: [
                  const Icon(Icons.email, color: Colors.blue),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      item.contactEmail,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () => removeItem(item),
              icon: const Icon(Icons.check_circle_outline),
              label: const Text("Mark Found"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 45),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
