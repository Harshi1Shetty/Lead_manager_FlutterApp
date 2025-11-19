import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/lead_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/constants.dart';
import 'add_edit_lead_screen.dart';
import 'lead_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    // Initial Load
    Future.microtask(() =>
        Provider.of<LeadProvider>(context, listen: false).loadLeads(refresh: true));

    // Scroll Listener for Lazy Loading
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        Provider.of<LeadProvider>(context, listen: false).loadLeads();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _searchController.clear();
    Provider.of<LeadProvider>(context, listen: false).loadLeads(refresh: true);
    setState(() {
      _isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search leads...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.white70),
                ),
                style: TextStyle(color: Colors.white),
                onChanged: (query) {
                  Provider.of<LeadProvider>(context, listen: false)
                      .searchLeads(query);
                },
              )
            : const Text('Lead Manager'),
        leading: _isSearching
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _clearSearch,
              )
            : null,
        actions: _isSearching
            ? [
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    if (_searchController.text.isNotEmpty) {
                      _searchController.clear();
                      Provider.of<LeadProvider>(context, listen: false)
                          .loadLeads(refresh: true);
                    }
                  },
                )
              ]
            : [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    setState(() {
                      _isSearching = true;
                    });
                  },
                ),
                // Theme Toggle
                IconButton(
                  icon: Icon(themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode),
                  onPressed: () => themeProvider.toggleTheme(),
                ),
                // Export Button
                IconButton(
                  icon: const Icon(Icons.file_download),
                  onPressed: () {
                     Provider.of<LeadProvider>(context, listen: false).exportLeadsToJSON();
                     ScaffoldMessenger.of(context).showSnackBar(
                       const SnackBar(content: Text('Generating JSON Export...')),
                     );
                  },
                ),
              ],
      ),
      body: Consumer<LeadProvider>(
        builder: (context, provider, child) {
          if (provider.leads.isEmpty && provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (provider.leads.isEmpty) {
             return const Center(child: Text("No leads found. Add one!"));
          }

          return ListView.builder(
            controller: _scrollController,
            itemCount: provider.leads.length + (provider.hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              // Loading indicator at the bottom
              if (index == provider.leads.length) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              final lead = provider.leads[index];

              // --- SIMPLE ANIMATION (Slide In) ---
              return TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 400),
                tween: Tween(begin: 0, end: 1),
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, 20 * (1 - value)), // Slide up effect
                      child: child,
                    ),
                  );
                },
                child: Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: getStatusColor(lead.status),
                      child: Text(lead.name[0].toUpperCase(), 
                        style: const TextStyle(color: Colors.white)),
                    ),
                    title: Text(lead.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("${lead.status} • ${lead.contact}"),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => LeadDetailScreen(lead: lead)),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEditLeadScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}