import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'graph_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<ChatMessage> messages = [];
  bool isTyping = false;

  ChatUser currentUser = ChatUser(id: "0", firstName: "User");
  ChatUser geminiUser = ChatUser(
    id: "1",
    firstName: "Gemini",
    profileImage:
        "https://seeklogo.com/images/G/google-gemini-logo-A5787B2669-seeklogo.com.png",
  );

  // Dummy data
  List<Map<String, String>> dummyData = [
    {
      "deal_id": "1",
      "client_name": "John",
      "customer_code": "C001",
      "deal_stage": "Negotiation",
      "enquiry": "Looking for bulk order of widgets",
      "value": "5"
    },
    {
      "deal_id": "2",
      "client_name": "Smith",
      "customer_code": "C002",
      "deal_stage": "Initial Contact",
      "enquiry": "Interested in pricing and availability",
      "value": "3"
    },
    {
      "deal_id": "3",
      "client_name": "Sarah",
      "customer_code": "C003",
      "deal_stage": "Lead",
      "enquiry": "Inquiring about mortgage rates",
      "value": "2"
    },
    {
      "deal_id": "4",
      "client_name": "Michael",
      "customer_code": "C004",
      "deal_stage": "Customer",
      "enquiry": "Looking for home insurance options",
      "value": "4"
    },
    {
      "deal_id": "5",
      "client_name": "Emily",
      "customer_code": "C005",
      "deal_stage": "Prospect",
      "enquiry": "Wants information on retirement planning",
      "value": "1"
    },
    // Add more dummy data as needed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Gemini Chat"),
      ),
      body: Column(
        children: [
          Expanded(
            child: Column(
              children: [
                Expanded(child: _buildChatUI()),
              ],
            ),
          ),
          if (isTyping) _buildTypingIndicator(),
        ],
      ),
    );
  }

  Widget _buildChatUI() {
    return DashChat(
      inputOptions: InputOptions(trailing: [
        IconButton(
          onPressed: _sendMediaMessage,
          icon: const Icon(Icons.image),
        ),
      ]),
      currentUser: currentUser,
      onSend: _sendMessage,
      messages: messages,
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          CircularProgressIndicator(),
          SizedBox(width: 10),
          Text("Gemini is typing..."),
        ],
      ),
    );
  }

  void _sendMessage(ChatMessage chatMessage) {
    setState(() {
      messages = [chatMessage, ...messages];
      isTyping = true; // Show typing indicator
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (chatMessage.text.toLowerCase().contains("graph")) {
        setState(() {
          isTyping = false; // Hide typing indicator
        });

        // Ask for graph options
        _showGraphOptions();
      } else {
        String response = _generateResponse(chatMessage.text);

        ChatMessage message = ChatMessage(
          user: geminiUser,
          createdAt: DateTime.now(),
          text: response,
        );

        setState(() {
          isTyping = false; // Hide typing indicator
          messages = [message, ...messages];
        });
      }
    });
  }

  void _showGraphOptions() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Select Graph Type"),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                GestureDetector(
                  child: Text("Line Graph"),
                  onTap: () {
                    Navigator.pop(context);
                    _showGraphPage(ChartType.line);
                  },
                ),
                GestureDetector(
                  child: Text("Bar Chart"),
                  onTap: () {
                    Navigator.pop(context);
                    _showGraphPage(ChartType.bar);
                  },
                ),
                GestureDetector(
                  child: Text("Pie Chart"),
                  onTap: () {
                    Navigator.pop(context);
                    _showGraphPage(ChartType.pie);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showGraphPage(ChartType selectedChartType) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GraphPage(
          dummyData: dummyData,
          selectedChartType: selectedChartType,
        ),
      ),
    );
  }

  String _generateResponse(String query) {
    // Check for specific queries and respond with dummy data
    if (query.toLowerCase().contains("name")) {
      return dummyData
          .map((data) =>
              "Deal ID: ${data['deal_id']}, Name: ${data['client_name']}")
          .join("\n");
    } else if (query.toLowerCase().contains("customer code")) {
      return dummyData
          .map((data) =>
              "Deal ID: ${data['deal_id']}, Customer Code: ${data['customer_code']}")
          .join("\n");
    } else if (query.toLowerCase().contains("enquiry")) {
      return dummyData
          .map((data) =>
              "Deal ID: ${data['deal_id']}, Enquiry: ${data['enquiry']}")
          .join("\n");
    } else if (query.toLowerCase().contains("deal stage")) {
      return dummyData
          .map((data) =>
              "Deal ID: ${data['deal_id']}, Stage: ${data['deal_stage']}")
          .join("\n");
    }
    // Default response if no specific query is matched
    return "Sorry, I didn't understand that. Can you please rephrase?";
  }

  void _sendMediaMessage() async {
    ImagePicker picker = ImagePicker();
    XFile? file = await picker.pickImage(
      source: ImageSource.gallery,
    );
    if (file != null) {
      ChatMessage chatMessage = ChatMessage(
        user: currentUser,
        createdAt: DateTime.now(),
        text: "Describe this picture?",
        medias: [
          ChatMedia(url: file.path, fileName: "", type: MediaType.image)
        ],
      );
      _sendMessage(chatMessage);
    }
  }
}
