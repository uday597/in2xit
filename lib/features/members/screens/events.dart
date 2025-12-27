import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:my_gate_clone/features/members/modal/event_response.dart';
import 'package:provider/provider.dart';
import 'package:my_gate_clone/features/members/modal/events.dart';
import 'package:my_gate_clone/features/owner/modal/members_modal.dart';
import 'package:my_gate_clone/features/members/providers/events.dart';
import 'package:my_gate_clone/features/members/providers/events_response.dart';
import 'package:my_gate_clone/features/owner/provider/members_provider.dart';

class EventsSection extends StatefulWidget {
  final MembersModal member;

  const EventsSection({Key? key, required this.member}) : super(key: key);

  @override
  State<EventsSection> createState() => _EventsSectionState();
}

class _EventsSectionState extends State<EventsSection> {
  final TextEditingController _responseController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchInitialData();
    });
  }

  Future<void> _fetchInitialData() async {
    final eventProv = Provider.of<EventProvider>(context, listen: false);
    final membersProv = Provider.of<MembersProvider>(context, listen: false);

    await eventProv.fetchEvents(
      widget.member.societyId,
      currentMemberId: widget.member.id,
    );
    await membersProv.fatchMembersList(widget.member.societyId);
    final responseProv = Provider.of<EventResponseProvider>(
      context,
      listen: false,
    );
    for (final e in eventProv.events) {
      responseProv.fetchResponses(e.id);
    }
  }

  @override
  void dispose() {
    _responseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final eventProv = Provider.of<EventProvider>(context);
    final responseProv = Provider.of<EventResponseProvider>(context);
    final membersProv = Provider.of<MembersProvider>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(eventProv, membersProv),
        const SizedBox(height: 12),
        _buildEventsList(eventProv, responseProv, membersProv),
      ],
    );
  }

  Widget _buildHeader(EventProvider eventProv, MembersProvider membersProv) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 28,
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Events',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              TextButton.icon(
                onPressed: () =>
                    _showAddEventSheet(context, membersProv, eventProv),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Event'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEventsList(
    EventProvider eventProv,
    EventResponseProvider responseProv,
    MembersProvider membersProv,
  ) {
    if (eventProv.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (eventProv.events.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Text('No events yet.'),
      );
    }

    return RefreshIndicator(
      onRefresh: () => eventProv.fetchEvents(
        widget.member.societyId,
        currentMemberId: widget.member.id,
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: eventProv.events.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, idx) {
          final event = eventProv.events[idx];
          return _buildEventCard(event, eventProv, responseProv, membersProv);
        },
      ),
    );
  }

  Widget _buildEventCard(
    EventsModal event,
    EventProvider eventProv,
    EventResponseProvider responseProv,
    MembersProvider membersProv,
  ) {
    final isCurrentUserOwner = event.memberId == widget.member.id;
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      shadowColor: Colors.grey.withOpacity(0.2),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              spacing: 10,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: event.memberImage.isNotEmpty
                      ? NetworkImage(event.memberImage)
                      : null,
                  child: event.memberImage.isEmpty
                      ? const Icon(Icons.person)
                      : null,
                ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.memberName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      formatDateTime(event.createdAt),
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const Text(
                      "Posted an event",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 6),
            _buildEventHeader(
              event,
              eventProv,
              membersProv,
              isCurrentUserOwner,
            ),
            const SizedBox(height: 12),
            _buildEventContent(event),
            if (event.memberId == widget.member.id) ...[
              const SizedBox(height: 12),
              _buildOwnerActions(event, eventProv, membersProv),
            ],
            const Divider(height: 20, thickness: 1.2),
            InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => Dialog(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.7,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Comments',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => Navigator.pop(context),
                                  icon: const Icon(Icons.close),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: _buildResponsesSection(
                                event,
                                responseProv,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
              child: Text(
                'Comments',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),

            const SizedBox(height: 8),
            _buildResponseInput(event, responseProv),
          ],
        ),
      ),
    );
  }

  Widget _buildEventHeader(
    EventsModal event,
    EventProvider eventProv,
    MembersProvider membersProv,
    bool isCurrentUserOwner,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            event.title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
        if (isCurrentUserOwner)
          _buildVisibilityMenu(event, eventProv, membersProv),
      ],
    );
  }

  Widget _buildVisibilityMenu(
    EventsModal event,
    EventProvider eventProv,
    MembersProvider membersProv,
  ) {
    return PopupMenuButton<String>(
      onSelected: (val) async {
        if (val == 'change') {
          _showChangeVisibilitySheet(event, membersProv, eventProv);
        } else if (val == 'view') {
          if (event.visibility == 'selective') {
            _showSelectedMembersDialog(event, membersProv);
          } else {
            _showSnackBar('This event is public');
          }
        }
      },
      itemBuilder: (_) => [
        const PopupMenuItem(value: 'change', child: Text('Change Visibility')),
        const PopupMenuItem(value: 'view', child: Text('View Visibility')),
      ],
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          shape: BoxShape.circle,
        ),
        child: Icon(
          event.visibility == 'public' ? Icons.public : Icons.group,
          size: 18,
        ),
      ),
    );
  }

  Widget _buildEventContent(EventsModal event) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          event.description,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
            height: 1.4,
          ),
        ),
        if (event.image != null && event.image!.isNotEmpty) ...[
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AspectRatio(
              aspectRatio: 14 / 10,
              child: Image.network(
                event.image!,
                fit: BoxFit.cover,
                alignment: Alignment(0, -0.3),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildOwnerActions(
    EventsModal event,
    EventProvider eventProv,
    MembersProvider membersProv,
  ) {
    return Row(
      children: [
        InkWell(
          onTap: () => _showUpdateEventSheet(event, eventProv, membersProv),
          child: Icon(Icons.edit),
        ),
        const SizedBox(width: 12),
        InkWell(
          onTap: () => _confirmDeleteEvent(event, eventProv),
          child: Icon(Icons.delete, color: Colors.red),
        ),
      ],
    );
  }

  Widget _buildResponsesSection(
    EventsModal event,
    EventResponseProvider responseProv,
  ) {
    final responses = responseProv.getResponses(event.id);
    final isLoading = responseProv.isLoading(event.id);

    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (responses.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Text('No responses yet'),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: responses.length,
      itemBuilder: (_, i) {
        final r = responses[i];
        return _buildResponseItem(r, event.id, responseProv);
      },
    );
  }

  Widget _buildResponseItem(
    EventResponseModal response,
    int eventId,
    EventResponseProvider responseProv,
  ) {
    final isMyComment = response.memberId == widget.member.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage:
                response.memberImage != null && response.memberImage!.isNotEmpty
                ? NetworkImage(response.memberImage!)
                : null,
            child: response.memberImage == null
                ? const Icon(Icons.person)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  response.memberName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  response.comment ?? '',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  formatDateTime(response.createdAt),
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          if (isMyComment)
            IconButton(
              onPressed: () =>
                  _confirmDeleteResponse(response.id, eventId, responseProv),
              icon: const Icon(Icons.delete, size: 18, color: Colors.redAccent),
            ),
        ],
      ),
    );
  }

  Widget _buildResponseInput(
    EventsModal event,
    EventResponseProvider responseProv,
  ) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _responseController,
            decoration: InputDecoration(
              hintText: 'Write a response...',
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey[100],
            ),
            minLines: 1,
            maxLines: 3,
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          onPressed: () => _sendResponse(event.id, responseProv),
          child: const Text('Send'),
        ),
      ],
    );
  }

  void _showAddEventSheet(
    BuildContext ctx,
    MembersProvider membersProv,
    EventProvider eventProv,
  ) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => AddUpdateEventSheet(
        member: widget.member,
        membersProv: membersProv,
        eventProv: eventProv,
        onSuccess: () => _showSnackBar('Event created successfully!'),
      ),
    );
  }

  void _showUpdateEventSheet(
    EventsModal event,
    EventProvider eventProv,
    MembersProvider membersProv,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => AddUpdateEventSheet(
        member: widget.member,
        membersProv: membersProv,
        eventProv: eventProv,
        event: event,
        onSuccess: () => _showSnackBar('Event updated successfully!'),
      ),
    );
  }

  void _showChangeVisibilitySheet(
    EventsModal event,
    MembersProvider membersProv,
    EventProvider eventProv,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _buildVisibilitySheet(event, membersProv, eventProv),
    );
  }

  Widget _buildVisibilitySheet(
    EventsModal event,
    MembersProvider membersProv,
    EventProvider eventProv,
  ) {
    String visibility = event.visibility;
    Set<int> selectedMemberIds = Set.from(event.selectedMemberIds);

    return StatefulBuilder(
      builder: (context, setState) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Change Visibility',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      value: 'public',
                      groupValue: visibility,
                      title: const Text('Public'),
                      onChanged: (v) => setState(() => visibility = v!),
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      value: 'selective',
                      groupValue: visibility,
                      title: const Text('Selective'),
                      onChanged: (v) => setState(() => visibility = v!),
                    ),
                  ),
                ],
              ),
              if (visibility == 'selective')
                SizedBox(
                  height: 200,
                  child: _buildMemberSelectionList(
                    membersProv,
                    selectedMemberIds,
                    (val, memberId) {
                      setState(() {
                        if (val == true) {
                          selectedMemberIds.add(memberId);
                        } else {
                          selectedMemberIds.remove(memberId);
                        }
                      });
                    },
                  ),
                ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () async {
                  final updated = EventsModal(
                    id: event.id,
                    title: event.title,
                    memberName: event.memberName,
                    memberImage: event.memberImage,
                    description: event.description,
                    image: event.image,
                    societyId: event.societyId,
                    memberId: event.memberId,
                    visibility: visibility,
                    visibleTo: visibility == 'selective'
                        ? selectedMemberIds.join(',')
                        : null,
                    createdAt: event.createdAt,
                    updatedAt: DateTime.now(),
                  );
                  await eventProv.updateEvent(updated);
                  Navigator.of(context).pop();
                  _showSnackBar('Visibility updated!');
                },
                child: const Text('Save'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMemberSelectionList(
    MembersProvider membersProv,
    Set<int> selectedIds,
    Function(bool?, int) onChanged,
  ) {
    if (membersProv.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      itemCount: membersProv.members.length,
      itemBuilder: (_, i) {
        final m = membersProv.members[i];
        final selected = selectedIds.contains(m.id);
        return CheckboxListTile(
          value: selected,
          onChanged: (val) => onChanged(val, m.id),
          title: Text(m.memberName),
          subtitle: Text(m.memberFlatNo),
          secondary: _buildMemberAvatar(m),
        );
      },
    );
  }

  Widget _buildMemberAvatar(MembersModal member) {
    if (member.memberImage != null && member.memberImage!.isNotEmpty) {
      return CircleAvatar(backgroundImage: NetworkImage(member.memberImage!));
    }
    return const CircleAvatar(child: Icon(Icons.person));
  }

  void _showSelectedMembersDialog(
    EventsModal event,
    MembersProvider membersProv,
  ) {
    final selectedIds = event.selectedMemberIds;

    if (selectedIds.isEmpty) {
      _showSnackBar('No members selected');
      return;
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Visible To'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: selectedIds.map((id) {
              final member = membersProv.members.firstWhere(
                (m) => m.id == id,
                orElse: () => MembersModal(
                  id: id,
                  societyId: widget.member.societyId,
                  memberEmail: '',
                  memberAddress: '',
                  memberFlatNo: '',
                  memberImage: null,
                  dob: '',
                  gender: '',
                  vehicleNo: '',
                  totalVehicle: '',
                  tower: '',
                  idProof: '',
                  memberName: 'Member #$id',
                  memberPhone: '',
                ),
              );
              return ListTile(
                leading: _buildMemberAvatar(member),
                title: Text(member.memberName),
                subtitle: Text(member.memberFlatNo),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteEvent(EventsModal event, EventProvider prov) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Event'),
        content: const Text('Are you sure you want to delete this event?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await prov.deleteEvent(event.id);
                _showSnackBar('Event deleted successfully!');
              } catch (e) {
                _showSnackBar('Failed to delete event');
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _sendResponse(
    int eventId,
    EventResponseProvider responseProv,
  ) async {
    final text = _responseController.text.trim();
    if (text.isEmpty) {
      _showSnackBar('Please enter a response');
      return;
    }

    try {
      // Show loading
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(width: 10),
              Text('Adding response...'),
            ],
          ),
          duration: Duration(seconds: 2),
        ),
      );

      // Add response
      await responseProv.addResponse(
        eventId: eventId,
        memberId: widget.member.id,
        type: 'comment',
        comment: text,
      );

      // Clear text field
      _responseController.clear();

      // Show success message
      _showSnackBar('Response added successfully!');
    } catch (e) {
      _showSnackBar('Failed to add response: ${e.toString()}');
    }
  }

  void _confirmDeleteResponse(
    int responseId,
    int eventId,
    EventResponseProvider prov,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Response'),
        content: const Text('Are you sure you want to delete your response?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await prov.deleteResponse(responseId, eventId);
                _showSnackBar('Response deleted!');
              } catch (e) {
                _showSnackBar('Failed to delete response');
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  String formatDateTime(DateTime date) {
    return DateFormat('hh:mm a • dd MMM yyyy').format(date);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }
}

class AddUpdateEventSheet extends StatefulWidget {
  final MembersModal member;
  final MembersProvider membersProv;
  final EventProvider eventProv;
  final EventsModal? event;
  final VoidCallback onSuccess;

  const AddUpdateEventSheet({
    Key? key,
    required this.member,
    required this.membersProv,
    required this.eventProv,
    this.event,
    required this.onSuccess,
  }) : super(key: key);

  @override
  State<AddUpdateEventSheet> createState() => _AddUpdateEventSheetState();
}

class _AddUpdateEventSheetState extends State<AddUpdateEventSheet> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _picker = ImagePicker();

  String visibility = 'public';
  Set<int> selectedMemberIds = {};
  File? pickedImage;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.event != null) {
      _titleController.text = widget.event!.title;
      _descController.text = widget.event!.description;
      visibility = widget.event!.visibility;
      selectedMemberIds = Set.from(widget.event!.selectedMemberIds);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (file != null) {
      setState(() => pickedImage = File(file.path));
    }
  }

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    final desc = _descController.text.trim();

    if (title.isEmpty || desc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title and description are required')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      String? imageUrl = widget.event?.image;
      if (pickedImage != null) {
        imageUrl = await widget.eventProv.uploadEventImage(pickedImage!);
      }

      if (widget.event == null) {
        await widget.eventProv.addEvent(
          title: title,
          description: desc,
          imageUrl: imageUrl,
          societyId: widget.member.societyId,
          memberId: widget.member.id,
          visibility: visibility,
          visibleTo: visibility == 'selective'
              ? selectedMemberIds.toList()
              : null,
        );
      } else {
        final updated = EventsModal(
          id: widget.event!.id,
          title: title,
          description: desc,
          image: imageUrl,
          memberName: widget.event!.memberName,
          memberImage: widget.event!.memberImage,
          societyId: widget.event!.societyId,
          memberId: widget.event!.memberId,
          visibility: visibility,
          visibleTo: visibility == 'selective'
              ? selectedMemberIds.join(',')
              : null,
          createdAt: widget.event!.createdAt,
          updatedAt: DateTime.now(),
        );
        await widget.eventProv.updateEvent(updated);
      }

      Navigator.pop(context);
      widget.onSuccess();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              widget.event == null ? 'Create Event' : 'Update Event',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descController,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 8),
            _buildImageSection(),
            const SizedBox(height: 8),
            _buildVisibilitySection(),
            const SizedBox(height: 12),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Column(
      children: [
        if (pickedImage != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              pickedImage!,
              height: 150,
              width: double.infinity,
              fit: BoxFit.contain,
            ),
          )
        else if (widget.event?.image != null && widget.event!.image!.isNotEmpty)
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              widget.event!.image!,
              height: 150,
              width: double.infinity,
              fit: BoxFit.contain,
            ),
          ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: _pickImage,
          icon: const Icon(Icons.image),
          label: Text(
            pickedImage != null || widget.event?.image != null
                ? 'Change Image'
                : 'Add Image',
          ),
        ),
        if (pickedImage != null || widget.event?.image != null)
          TextButton.icon(
            onPressed: () => setState(() => pickedImage = null),
            icon: const Icon(Icons.clear),
            label: const Text('Remove Image'),
          ),
      ],
    );
  }

  Widget _buildVisibilitySection() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: RadioListTile<String>(
                value: 'public',
                groupValue: visibility,
                title: const Text('Public'),
                onChanged: (v) => setState(() => visibility = v!),
              ),
            ),
            Expanded(
              child: RadioListTile<String>(
                value: 'selective',
                groupValue: visibility,
                title: const Text('Selective'),
                onChanged: (v) => setState(() => visibility = v!),
              ),
            ),
          ],
        ),
        if (visibility == 'selective') ...[
          const SizedBox(height: 6),
          const Text(
            'Select Members',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          SizedBox(height: 200, child: _buildMemberSelectionList()),
        ],
      ],
    );
  }

  Widget _buildMemberSelectionList() {
    if (widget.membersProv.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      itemCount: widget.membersProv.members.length,
      itemBuilder: (_, i) {
        final member = widget.membersProv.members[i];
        final selected = selectedMemberIds.contains(member.id);
        return CheckboxListTile(
          value: selected,
          onChanged: (val) {
            setState(() {
              if (val == true) {
                selectedMemberIds.add(member.id);
              } else {
                selectedMemberIds.remove(member.id);
              }
            });
          },
          title: Text(member.memberName),
          subtitle: Text(member.memberFlatNo),
          secondary: CircleAvatar(
            backgroundImage:
                member.memberImage != null && member.memberImage!.isNotEmpty
                ? NetworkImage(member.memberImage!)
                : null,
            child: member.memberImage == null ? const Icon(Icons.person) : null,
          ),
        );
      },
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        onPressed: _isSubmitting ? null : _submit,
        child: _isSubmitting
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                widget.event == null ? 'Create Event' : 'Update Event',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}
