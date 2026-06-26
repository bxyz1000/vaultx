import 'dart:io';
import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import 'add_document_screen.dart';
import 'card_viewer_screen.dart';

class FolderScreen extends StatefulWidget {
  final String category;
  final Color color;
  const FolderScreen({
    super.key,
    required this.category,
    required this.color,
  });

  @override
  State<FolderScreen> createState() => _FolderScreenState();
}

class _FolderScreenState extends State<FolderScreen> {
  List<Map<String, dynamic>> _documents = [];

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  Future<void> _loadDocuments() async {
    final docs = await StorageService.getDocumentsByCategory(widget.category);
    setState(() => _documents = docs);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E2E),
        title: Text(widget.category),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: widget.color,
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddDocumentScreen(category: widget.category),
            ),
          );
          if (result == true) _loadDocuments();
        },
        child: const Icon(Icons.add),
      ),
      body: _documents.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.folder_open_rounded,
                      size: 64, color: Colors.grey.shade700),
                  const SizedBox(height: 16),
                  const Text('No documents yet',
                      style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 8),
                  const Text('Tap + to add your first document',
                      style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.8,
              ),
              itemCount: _documents.length,
              itemBuilder: (context, index) {
                final doc = _documents[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CardViewerScreen(document: doc),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E2E),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(16)),
                            child: doc['front_path'] != null
                                ? Image.file(
                                    File(doc['front_path']),
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  )
                                : Container(color: Colors.grey.shade800),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Text(
                            doc['name'] ?? '',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
