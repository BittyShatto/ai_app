import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fl_chart/fl_chart.dart'; // Import fl_chart package

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<ChatMessage> messages = [];
  bool isTyping = false;
  bool showGraph = false; // Flag to control whether to show the graph

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
      "client_name": "John Doe",
      "customer_code": "C001",
      "deal_stage": "Negotiation",
      "enquiry": "Looking for bulk order of widgets",
      "value": "5"
    },
    {
      "deal_id": "2",
      "client_name": "Jane Smith",
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
      "deal_stage": "Customer ",
      "enquiry": "Looking for home insurance options",
      "value": "4"
    },
    {
      "deal_id": "5",
      "client_name": "Emily",
      "customer_code": "C005",
      "deal_stage": "Prospect ",
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
          Expanded(child: _buildChatUI()),
          if (isTyping) _buildTypingIndicator(),
          // Only show the graph if the showGraph flag is true
          if (showGraph) _buildGraph(), // Add graph widget
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

    // Use mock data for testing
    Future.delayed(const Duration(seconds: 2), () {
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
    });
  }

  String _generateResponse(String query) {
    // Check if the user asked for a graph representation
    if (query.toLowerCase().contains("graph")) {
      // Set the showGraph flag to true when the user requests the graph
      setState(() {
        showGraph = true;
      });
      return "Here's the graph representation of the data.";
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

  Widget _buildGraph() {
    return SizedBox(
      height: 300,
      child: BarChart(
        BarChartData(
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '',
                    style: const TextStyle(color: Colors.black),
                  );
                },
                reservedSize: 30,
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value >= 0 && value < dummyData.length) {
                    return Text(
                      dummyData[value.toInt()]["client_name"] ?? "",
                      style: const TextStyle(color: Colors.black),
                    );
                  }
                  return const Text("");
                },
                reservedSize: 30,
              ),
            ),
          ),
          barGroups: generateGraphData(
              "deal_id"), // Make sure "deal_id" is the correct metric
          borderData: FlBorderData(show: false),
          alignment: BarChartAlignment.spaceAround,
          barTouchData: BarTouchData(enabled: false),
          gridData: FlGridData(show: false),
        ),
      ),
    );
  }

  // Method to dynamically generate graph data based on a given metric
  List<BarChartGroupData> generateGraphData(String metric) {
    List<BarChartGroupData> barChartData = [];
    for (int i = 0; i < dummyData.length; i++) {
      double value = double.parse(dummyData[i][metric]!);
      barChartData.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: value,
              color: Colors.primaries[i % Colors.primaries.length],
            )
          ],
        ),
      );
    }
    return barChartData;
  }
}
