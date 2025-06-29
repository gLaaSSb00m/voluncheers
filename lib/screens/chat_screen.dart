import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  bool _isChatActive = false;
  final List<Map<String, String>> _messages = [
    {'text': 'Hello, thanks for your interest!', 'isMe': 'false'},
    {'text': 'Looking forward to joining', 'isMe': 'true'},
  ];
  final TextEditingController _controller = TextEditingController();

  void _startChat() {
    setState(() {
      _isChatActive = true;
    });
  }

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        _messages.add({'text': _controller.text, 'isMe': 'true'});
        _controller.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isChatActive 
        ? _buildChatInterface()
        : _buildMessagesList(); // Show messages list instead of placeholder
  }

  Widget _buildMessagesList() {
    return Scaffold(
      appBar: AppBar(
        title: Text('Messages'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Type your search...',
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16),
                ),
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  _buildMessageTile('Green Earth Org', '5:22', true),
                  _buildMessageTile('ABC Org', '3:00', false),
                  _buildMessageTile('XYZ Institution', '2:22', false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageTile(String title, String time, bool isRead) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.grey[300],
        child: Text(title[0]), // Show first letter of organization
      ),
      title: Text(title),
      subtitle: Text(time),
      trailing: isRead ? Icon(Icons.done_all, color: Colors.blue) : Icon(Icons.done),
      onTap: _startChat, // Start chat when tapped
    );
  }

  Widget _buildChatInterface() {
    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey[300],
                ),
                SizedBox(width: 10),
                Text(
                  'Green Earth Org',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.white,
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  return Align(
                    alignment: message['isMe'] == 'true'
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      margin: EdgeInsets.only(bottom: 8),
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: message['isMe'] == 'true'
                            ? Color(0xFF01311F)
                            : Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        message['text']!,
                        style: TextStyle(
                          color: message['isMe'] == 'true' ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(8),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Type your message',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Color(0xFF01311F)),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}