import 'package:flutter/material.dart';
import 'package:my_gate_clone/features/members/modal/help_request.dart';
import 'package:my_gate_clone/features/members/modal/help_response.dart';
import 'package:my_gate_clone/features/members/providers/help_request.dart';
import 'package:my_gate_clone/features/members/providers/help_response.dart';
import 'package:provider/provider.dart';

class HelpRequestListScreen extends StatefulWidget {
  final int societyId;
  final int memberId;
  final String currentMemberName;
  final String currentMemberPhone;
  final String currentMemberFlat;

  const HelpRequestListScreen({
    super.key,
    required this.societyId,
    required this.memberId,
    required this.currentMemberName,
    required this.currentMemberPhone,
    required this.currentMemberFlat,
  });

  @override
  State<HelpRequestListScreen> createState() => _HelpRequestListScreenState();
}

class _HelpRequestListScreenState extends State<HelpRequestListScreen> {
  final _typeController = TextEditingController();
  final _descController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initData());
  }

  Future<void> _initData() async {
    setState(() => _isLoading = true);
    try {
      final helpProvider = context.read<HelpProvider>();
      final resProvider = context.read<HelpResponseProvider>();

      await helpProvider.fetchHelpsBySociety(widget.societyId);
      resProvider.clearResponses();

      for (var help in helpProvider.helpList) {
        await resProvider.fetchResponsesByHelpId(help.id);
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showAddHelpSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Add Help Request',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _typeController,
              decoration: InputDecoration(
                labelText: 'Help Type',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _descController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancel'),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _submitHelp,
                    child: Text('Submit'),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _submitHelp() async {
    if (_typeController.text.isEmpty || _descController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill all fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final help = HelpModal(
        societyId: widget.societyId,
        memberId: widget.memberId,
        type: _typeController.text.trim(),
        description: _descController.text.trim(),
        createdAt: DateTime.now(),
        memberName: widget.currentMemberName,
        memberPhone: widget.currentMemberPhone,
        memberFlat: widget.currentMemberFlat,
      );

      await context.read<HelpProvider>().addHelp(help);

      _typeController.clear();
      _descController.clear();
      Navigator.pop(context);
      await _initData();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Help request added!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _deleteHelp(HelpModal help) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Delete Help Request?'),
        content: Text('Are you sure you want to delete "${help.type}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await context.read<HelpProvider>().deleteHelp(help.id);
      await _initData();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Help request deleted!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _deleteResponse(HelpResponseModal res) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Delete Response?'),
        content: Text('Are you sure you want to delete this response?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await context.read<HelpResponseProvider>().deleteResponse(res.id);
      await _initData();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Response deleted!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  void dispose() {
    _typeController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [const Color(0xFF2196F3), const Color(0xFF1A237E)],
            ),
          ),
        ),
        title: Text('Help Requests'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _isLoading ? null : _initData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF2196F3),
        onPressed: _showAddHelpSheet,
        child: Icon(Icons.add, color: Colors.white),
      ),
      backgroundColor: Colors.grey.shade100,
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Consumer<HelpProvider>(
              builder: (context, helpProvider, child) {
                if (helpProvider.helpList.isEmpty) {
                  return Center(
                    child: SingleChildScrollView(
                      physics: ClampingScrollPhysics(),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.help_outline,
                            size: 80,
                            color: Colors.grey[400],
                          ),
                          SizedBox(height: 20),
                          Text(
                            'No Help Requests Yet',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Tap + to add your first request',
                            style: TextStyle(color: Colors.grey),
                          ),
                          SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _initData,
                            child: Text('Refresh'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _initData,
                  child: ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: helpProvider.helpList.length,
                    itemBuilder: (context, index) =>
                        _buildHelpCard(helpProvider.helpList[index]),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildHelpCard(HelpModal help) {
    return Consumer<HelpResponseProvider>(
      builder: (context, resProvider, child) {
        final responses = resProvider.responseList
            .where((r) => r.helpId == help.id)
            .toList();
        final isCreator = help.memberId == widget.memberId;

        return Card(
          color: Colors.white,
          elevation: 2,
          margin: EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Color(0xFF2196F3).withOpacity(0.1),
                      child: Icon(
                        Icons.help,
                        size: 22,
                        color: Color(0xFF2196F3),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  help.type,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueGrey[800],
                                  ),
                                ),
                              ),
                              if (isCreator)
                                IconButton(
                                  icon: Icon(
                                    Icons.delete,
                                    size: 20,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => _deleteHelp(help),
                                  padding: EdgeInsets.zero,
                                ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Text(
                            _formatDate(help.createdAt),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),

                // Requester Info
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // User name row
                      Row(
                        spacing: 2,
                        children: [
                          Icon(Icons.person, size: 16, color: Colors.grey[600]),
                          Text(
                            help.memberName,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[800],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      // Phone and flat info row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.phone, size: 14, color: Colors.grey[600]),
                          SizedBox(width: 4),
                          Text(
                            help.memberPhone,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(width: 12),
                          Icon(Icons.home, size: 14, color: Colors.grey[600]),
                          SizedBox(width: 4),
                          Text(
                            help.memberFlat,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12),

                // Description
                Text(
                  help.description,
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  textAlign: TextAlign.justify,
                ),
                SizedBox(height: 16),

                // Responses Section
                if (responses.isNotEmpty) ...[
                  Divider(height: 20),
                  Text(
                    'Responses (${responses.length})',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 8),
                  Column(children: responses.map(_buildResponseCard).toList()),
                ],

                // Add Response Field
                SizedBox(height: responses.isNotEmpty ? 16 : 0),
                _buildResponseField(help.id),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildResponseCard(HelpResponseModal res) {
    final canDelete = res.memberId == widget.memberId;

    return Container(
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        leading: CircleAvatar(
          radius: 18,
          backgroundColor: Color(0xFF4CAF50).withOpacity(0.1),
          child: Icon(Icons.person, size: 16, color: Color(0xFF4CAF50)),
        ),
        title: Row(
          children: [
            Text(
              res.memberName,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            if (res.memberId == widget.memberId)
              Container(
                margin: EdgeInsets.only(left: 6),
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'You',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 2),
            Text(
              res.response,
              style: TextStyle(fontSize: 13, color: Colors.grey[700]),
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Text(
                  '${res.memberPhone} • ${res.flatNo}',
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                ),
                Spacer(),
                Text(
                  _formatDate(res.createdAt),
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                ),
              ],
            ),
          ],
        ),
        trailing: canDelete
            ? IconButton(
                icon: Icon(Icons.delete_outline, size: 18, color: Colors.red),
                onPressed: () => _deleteResponse(res),
                padding: EdgeInsets.zero,
              )
            : null,
      ),
    );
  }

  Widget _buildResponseField(int helpId) {
    final controller = TextEditingController();

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Type your response...',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF2196F3),
            ),
            child: IconButton(
              onPressed: () async {
                if (controller.text.trim().isEmpty) return;
                try {
                  final response = HelpResponseModal(
                    memberName: widget.currentMemberName,
                    memberPhone: widget.currentMemberPhone,
                    flatNo: widget.currentMemberFlat,
                    helpId: helpId,
                    memberId: widget.memberId,
                    response: controller.text.trim(),
                    createdAt: DateTime.now(),
                  );

                  await context.read<HelpResponseProvider>().addResponse(
                    response,
                  );
                  controller.clear();
                  FocusScope.of(context).unfocus();

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Response added!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              icon: Icon(Icons.send, color: Colors.white, size: 20),
              padding: EdgeInsets.all(8),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    return '${date.day}/${date.month}/${date.year}';
  }
}
