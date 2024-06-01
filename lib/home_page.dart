import 'dart:io';
import 'dart:typed_data';

import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

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
          "https://seeklogo.com/images/G/google-gemini-logo-A5787B2669-seeklogo.com.png");

  // Dummy data
  List<Map<String, String>> dummyData = [
    {
      "deal_id": "001",
      "client_name": "John Doe",
      "customer_code": "C001",
      "deal_stage": "Negotiation",
      "enquiry": "Looking for bulk order of widgets"
    },
    {
      "deal_id": "002",
      "client_name": "Jane Smith",
      "customer_code": "C002",
      "deal_stage": "Initial Contact",
      "enquiry": "Interested in pricing and availability"
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
    Future.delayed(Duration(seconds: 2), () {
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
