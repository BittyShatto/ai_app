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
          onPressed: _sendMediaChatMessage,
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
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.show_chart),
                title: Text("Line Graph"),
                onTap: () {
                  Navigator.pop(context);
                  _showGraphPage(ChartType.line);
                },
              ),
              ListTile(
                leading: Icon(Icons.bar_chart),
                title: Text("Bar Chart"),
                onTap: () {
                  Navigator.pop(context);
                  _showGraphPage(ChartType.bar);
                },
              ),
              ListTile(
                leading: Icon(Icons.pie_chart),
                title: Text("Pie Chart"),
                onTap: () {
                  Navigator.pop(context);
                  _showGraphPage(ChartType.pie);
                },
              ),
            ],
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
    // Check for specific deal ID
    RegExp dealIdRegExp = RegExp(r'deal id (\d+)', caseSensitive: false);
    Match? match = dealIdRegExp.firstMatch(query);
    if (match != null) {
      String dealId = match.group(1)!;
      var deal = dummyData.firstWhere((data) => data['deal_id'] == dealId,
          orElse: () => {});
      if (deal.isNotEmpty) {
        return "Deal ID: ${deal['deal_id']}, Name: ${deal['client_name']}, Customer Code: ${deal['customer_code']}, "
            "Stage: ${deal['deal_stage']}, Enquiry: ${deal['enquiry']}, Value: ${deal['value']}";
      } else {
        return "No deal found with ID $dealId.";
      }
    }

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

    // Handle general sales-related queries
    if (query.toLowerCase().contains("sales tips")) {
      return "Here are some sales tips:\n1. Understand your customer's needs.\n2. Build a strong relationship.\n3. Listen more than you talk.\n4. Know your product well.\n5. Follow up after the sale.";
    } else if (query.toLowerCase().contains("sales strategy")) {
      return "A good sales strategy includes:\n1. Identifying your target market.\n2. Setting clear objectives.\n3. Creating a value proposition.\n4. Leveraging social proof.\n5. Using data-driven insights.";
    } else if (query.toLowerCase().contains("customer retention")) {
      return "To retain customers, focus on:\n1. Providing excellent customer service.\n2. Offering loyalty programs.\n3. Seeking feedback and acting on it.\n4. Personalizing your interactions.\n5. Consistently delivering value.";
    } else if (query.toLowerCase().contains("lead generation")) {
      return "Effective lead generation strategies include:\n1. Content marketing.\n2. SEO optimization.\n3. Social media engagement.\n4. Email marketing.\n5. Networking events and webinars.";
    }

    // Handle general information queries
    String lowerQuery = query.toLowerCase();
    if (lowerQuery.contains("hello") || lowerQuery.contains("hi")) {
      return "Hello! How can I assist you today?";
    } else if (lowerQuery.contains("how are you")) {
      return "I'm just a bot, but I'm here to help! How can I assist you?";
    } else if (lowerQuery.contains("what is your name")) {
      return "I'm Gemini, your virtual assistant.";
    } else if (lowerQuery.contains("thank you")) {
      return "You're welcome!";
    } else if (lowerQuery.contains("help")) {
      return "Sure, I'm here to help! You can ask me about deals, sales tips, or any other information you need.";
    }

    // Default response if no specific query is matched
    return "Sorry, I didn't understand that. Can you please rephrase?";
  }

  void _sendMediaChatMessage() async {
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
