import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/lead.dart';
import '../providers/lead_provider.dart';
import '../utils/constants.dart';
import 'add_edit_lead_screen.dart';

class LeadDetailScreen extends StatelessWidget {
  final Lead lead;

  const LeadDetailScreen({super.key, required this.lead});

  @override
  Widget build(BuildContext context) {
    // We use Consumer to ensure we are looking at the latest data if it changes
    return Consumer<LeadProvider>(
      builder: (context, provider, child) {
        // Find the specific lead from the provider list to get live updates
        // If lead was deleted, handle it gracefully
        final currentLead = provider.leads.firstWhere(
            (l) => l.id == lead.id,
            orElse: () => lead); 
        
        return Scaffold(
          appBar: AppBar(
            title: const Text('Lead Details'),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddEditLeadScreen(lead: currentLead),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  _confirmDelete(context, provider, currentLead.id!);
                },
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: getStatusColor(currentLead.status),
                        child: Text(
                          currentLead.name[0].toUpperCase(),
                          style: const TextStyle(fontSize: 40, color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        currentLead.name,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 8),
                      Chip(
                        label: Text(
                          currentLead.status,
                          style: const TextStyle(color: Colors.white),
                        ),
                        backgroundColor: getStatusColor(currentLead.status),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 40),
                _buildDetailRow(Icons.phone, 'Contact', currentLead.contact),
                const SizedBox(height: 20),
                _buildDetailRow(Icons.calendar_today, 'Created Date',
                    DateFormat.yMMMd().format(currentLead.createdTime)),
                const SizedBox(height: 20),
                const Text("Notes:",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Text(
                    (currentLead.notes != null && currentLead.notes!.isNotEmpty)
                        ? currentLead.notes!
                        : "No notes available.",
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                const Spacer(),
                const Text("Quick Status Update:",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: leadStatuses.map((status) {
                    if (status == currentLead.status) return const SizedBox.shrink();
                    return ActionChip(
                      label: Text(status),
                      onPressed: () {
                         final updatedLead = currentLead.copyWith(status: status);
                         provider.updateLead(updatedLead);
                      },
                    );
                  }).toList(),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            Text(value, style: const TextStyle(fontSize: 18)),
          ],
        )
      ],
    );
  }

  void _confirmDelete(BuildContext context, LeadProvider provider, int id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Lead?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              provider.deleteLead(id);
              Navigator.pop(ctx); // Close dialog
              Navigator.pop(context); // Go back to list
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}