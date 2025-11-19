import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/lead.dart';
import '../providers/lead_provider.dart';
import '../utils/constants.dart';

class AddEditLeadScreen extends StatefulWidget {
  final Lead? lead; // If null, we are adding. If not null, we are editing.

  const AddEditLeadScreen({super.key, this.lead});

  @override
  State<AddEditLeadScreen> createState() => _AddEditLeadScreenState();
}

class _AddEditLeadScreenState extends State<AddEditLeadScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _contact;
  late String _status;
  String? _notes;

  @override
  void initState() {
    super.initState();
    _name = widget.lead?.name ?? '';
    _contact = widget.lead?.contact ?? '';
    _status = widget.lead?.status ?? 'New';
    _notes = widget.lead?.notes ?? '';
  }

  void _saveLead() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final provider = Provider.of<LeadProvider>(context, listen: false);

      if (widget.lead == null) {
        // Add New
        final newLead = Lead(
          name: _name,
          contact: _contact,
          status: _status,
          notes: _notes,
          createdTime: DateTime.now(),
        );
        provider.addLead(newLead);
      } else {
        // Update Existing
        final updatedLead = widget.lead!.copyWith(
          name: _name,
          contact: _contact,
          status: _status,
          notes: _notes,
        );
        provider.updateLead(updatedLead);
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.lead != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Lead' : 'Add New Lead'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(labelText: 'Lead Name *'),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Name is required' : null,
                onSaved: (val) => _name = val!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _contact,
                decoration: const InputDecoration(
                  labelText: 'Contact Details (Phone/Email) *',
                  prefixIcon: Icon(Icons.contact_phone),
                ),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Contact is required' : null,
                onSaved: (val) => _contact = val!,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _status,
                decoration: const InputDecoration(labelText: 'Status'),
                items: leadStatuses
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (val) => setState(() => _status = val!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _notes,
                decoration: const InputDecoration(
                    labelText: 'Notes (Optional)', alignLabelWithHint: true),
                maxLines: 4,
                onSaved: (val) => _notes = val,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveLead,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Save Lead', style: TextStyle(fontSize: 18)),
              )
            ],
          ),
        ),
      ),
    );
  }
}