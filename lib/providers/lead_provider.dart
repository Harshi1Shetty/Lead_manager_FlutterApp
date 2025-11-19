import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/lead.dart';
import '../services/database_helper.dart';

class LeadProvider with ChangeNotifier {
  List<Lead> _leads = [];
  
  // Pagination State
  int _page = 1;
  final int _limit = 10;
  bool _hasMore = true;
  bool _isLoading = false;

  List<Lead> get leads => _leads;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;

  // Initial Load
  Future<void> loadLeads({bool refresh = false}) async {
    if (_isLoading) return;
    
    if (refresh) {
      _page = 1;
      _hasMore = true;
      _leads.clear();
      notifyListeners();
    }

    if (!_hasMore) return;

    _isLoading = true;
    // Only notify if it's the initial load to show a spinner
    if (_page == 1) notifyListeners(); 

    try {
      // Simulate network delay for animation effect (optional)
      await Future.delayed(const Duration(milliseconds: 500));

      final newLeads = await DatabaseHelper.instance.readLeads(
        limit: _limit, 
        page: _page
      );

      if (newLeads.length < _limit) {
        _hasMore = false;
      }

      _leads.addAll(newLeads);
      _page++;
    } catch (e) {
      debugPrint("Error loading leads: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Search (Overrides pagination for simplicity in this mini-app)
  Future<void> searchLeads(String query) async {
    if (query.isEmpty) {
      loadLeads(refresh: true);
      return;
    }
    _leads = await DatabaseHelper.instance.searchLeads(query);
    _hasMore = false; // Disable pagination during search
    notifyListeners();
  }

  Future<void> addLead(Lead lead) async {
    await DatabaseHelper.instance.create(lead);
    loadLeads(refresh: true);
  }

  Future<void> updateLead(Lead lead) async {
    await DatabaseHelper.instance.update(lead);
    // Simple reload to reflect changes
    int index = _leads.indexWhere((l) => l.id == lead.id);
    if (index != -1) {
      _leads[index] = lead;
      notifyListeners();
    }
  }

  Future<void> deleteLead(int id) async {
    await DatabaseHelper.instance.delete(id);
    _leads.removeWhere((l) => l.id == id);
    notifyListeners();
  }

  // --- JSON EXPORT FEATURE ---
  Future<void> exportLeadsToJSON() async {
    try {
      // 1. Convert leads to List of Maps
      final List<Map<String, dynamic>> jsonList = 
          _leads.map((lead) => lead.toMap()).toList();
      
      // 2. Encode to JSON String
      final String jsonString = jsonEncode(jsonList);

      // 3. Get Temporary Directory
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/leads_export.json');

      // 4. Write to file
      await file.writeAsString(jsonString);

      // 5. Share the file
      await Share.shareXFiles([XFile(file.path)], text: 'Here is the Leads Export JSON');
    } catch (e) {
      debugPrint("Error exporting: $e");
    }
  }
}