import 'package:flutter/material.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:firebase_auth/firebase_auth.dart'; // <--- 1. ΠΡΟΣΘΗΚΗ IMPORT

import '../theme/app_variables.dart';
import '../widgets/main_nav_bar.dart';
import '../widgets/ai_chat_header.dart';

import '../secrets.dart';

class AiAssistantPage extends StatefulWidget {
  const AiAssistantPage({super.key});

  @override
  State<AiAssistantPage> createState() => _AiAssistantPageState();
}

class _AiAssistantPageState extends State<AiAssistantPage> {
  // 1) SETUP CHAT USERS
  final ChatUser _currentUser = ChatUser(id: 'user', firstName: 'User');
  final ChatUser _aiUser = ChatUser(id: 'ai', firstName: 'AI');

  final List<ChatMessage> _messages = [];
  GenerativeModel? _model;
  ChatSession? _chatSession;

  // 2) LOAD RULES FILE ON STARTUP
  String? _rulesData;

  static const String _modelName = 'gemini-2.0-flash';
  
  // <--- 2. ΒΡΙΣΚΟΥΜΕ ΤΟ ID ΤΟΥ ΧΡΗΣΤΗ ---
  final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();

    _messages.insert(
      0,
      ChatMessage(
        user: _aiUser,
        createdAt: DateTime.now(),
        text:
            "Γειά! Είμαι ο ΑΙ βοηθός σου 🤖\nΡώτα με ό,τι θες σχετικά με την ανακύκλωση.",
      ),
    );

    _loadRulesData();
  }

  Future<void> _loadRulesData() async {
    try {
      _rulesData = await rootBundle.loadString('recycling_rules.txt');
      _initGemini();
    } catch (e) {
      _rulesData = null;
      _initGemini();
      // ignore: avoid_print
      print("Error loading rules file: $e");
    }
  }

  // 3) INITIALIZE GEMINI (template style)
  void _initGemini() {
    const apiKeyM = Secret;

    if (apiKeyM.trim().isEmpty) {
      // ignore: avoid_print
      print("Gemini API key is missing (Secret is empty).");
      return;
    }

    _model = GenerativeModel(
      model: _modelName,
      apiKey: apiKeyM,
      systemInstruction: Content.system("""
You are an AI assistant for the SortedOut recycling app.
Answer questions about recycling, sorting waste, composting, and eco-friendly habits.

RULES (developer-provided):
${_rulesData ?? "(No rules file found. Use general best practices and ask for location if needed.)"}

CORE RULES:
1. Be friendly and concise.
2. If the answer depends on the user's city, ask where they live.
3. If unsure, say you’re not sure and suggest checking local municipality rules or packaging labels.
4. Avoid medical/legal advice; recommend official sources if asked.
"""),
    );

    _chatSession = _model!.startChat();
    setState(() {});
  }

  // 4) SEND MESSAGE FUNCTION
  void _sendMessage(ChatMessage chatMessage) async {
    setState(() {
      _messages.insert(0, chatMessage);
    });

    if (_chatSession == null) {
      setState(() {
        _messages.insert(
          0,
          ChatMessage(
            user: _aiUser,
            createdAt: DateTime.now(),
            text: "AI is not configured yet. Check Secret + rules file asset.",
          ),
        );
      });
      return;
    }

    try {
      final DateTime now = DateTime.now();
      final String dateContext =
          "Current Date & Time: ${now.toString()}. User asks: ";

      final content = Content.text(dateContext + chatMessage.text);
      final response = await _chatSession!.sendMessage(content);

      if (response.text != null) {
        setState(() {
          _messages.insert(
            0,
            ChatMessage(
              user: _aiUser,
              createdAt: DateTime.now(),
              text: response.text!,
            ),
          );
        });
      }
    } catch (e) {
      // ignore: avoid_print
      print("Error sending message: $e");
      setState(() {
        _messages.insert(
          0,
          ChatMessage(
            user: _aiUser,
            createdAt: DateTime.now(),
            text: "Συγγνώμη είχα πρόβλημα επικοινωνίας. Προσπάθησε ξανά.",
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double navBarHeight = 90.0;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(AppImages.background),
                fit: BoxFit.cover,
              ),
            ),
          ),

          SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 10, 16, navBarHeight + 5),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  const Align(
                    alignment: Alignment.topLeft,
                    child: AiChatHeader(
                      title: "AI Assistant at your service!",
                      iconAsset: "assets/images/ai_pressed.png",
                    ),
                  ),
                  const SizedBox(height: 10),

                  Expanded(
                    child: DashChat(
                      currentUser: _currentUser,
                      onSend: _sendMessage,
                      messages: _messages,
                      messageListOptions: const MessageListOptions(
                        showDateSeparator: false,
                      ),
                      messageOptions: MessageOptions(
                        showOtherUsersAvatar: false, // <--- ΑΥΤΟ ΚΡΥΒΕΙ ΤΟ "A"
                        showCurrentUserAvatar: false, // <--- ΑΥΤΟ ΚΡΥΒΕΙ ΤΟ ΔΙΚΟ ΣΟΥ AVATAR
                        textColor: AppColors.textMain,
                        currentUserTextColor: AppColors.textMain,
                        // Φτιάχνουμε τα συννεφάκια να φαίνονται ωραία και χωρίς avatars
                        messageDecorationBuilder: (ChatMessage msg,
                            ChatMessage? previous, ChatMessage? next) {
                          final bool isMe = msg.user.id == _currentUser.id;
                          return BoxDecoration(
                            // Χρώματα: Κίτρινο για το AI, Αχνό μπλε/γκρι για τον χρήστη
                            color: isMe
                                ? AppColors.main.withOpacity(0.1)
                                : AppColors.lightGrey,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(18),
                              topRight: const Radius.circular(18),
                              bottomLeft: Radius.circular(isMe ? 18 : 6),
                              bottomRight: Radius.circular(isMe ? 6 : 18),
                            ),
                          );
                        },
                      ),
                      inputOptions: InputOptions(
                        inputTextStyle: TextStyle(
                          color: AppColors.textMain,
                          fontSize: 16, // Λίγο μεγαλύτερα γράμματα για ευκολία
                        ),
                        inputToolbarPadding: const EdgeInsets.symmetric(vertical: 10), // Αέρας πάνω-κάτω
                        inputToolbarStyle: const BoxDecoration(
                          color: Colors.transparent, // Διαφανές φόντο πίσω από την μπάρα
                        ),
                        // --- ΣΧΕΔΙΑΣΜΟΣ ΚΟΥΜΠΙΟΥ ΑΠΟΣΤΟΛΗΣ ---
                        sendButtonBuilder: (onSend) {
                          return Container(
                            margin: const EdgeInsets.only(left: 10, right: 0),
                            decoration: BoxDecoration(
                              color: AppColors.main, // Χρώμα κουμπιού (το βασικό της εφαρμογής)
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.send_rounded, size: 22, color: Colors.white),
                              onPressed: onSend,
                            ),
                          );
                        },
                        // --- ΣΧΕΔΙΑΣΜΟΣ ΠΕΔΙΟΥ ΚΕΙΜΕΝΟΥ ---
                        inputDecoration: InputDecoration(
                          hintText: "Ρώτησε για την ανακύκλωση...",
                          hintStyle: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 14,
                          ),
                          filled: true,
                          fillColor: Colors.white, // Λευκό φόντο για να φαίνεται καθαρά
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          // Αφαιρέθηκε το prefixIcon (ο συνδετήρας) από εδώ
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30), // Οβάλ σχήμα
                            borderSide: BorderSide.none, // Χωρίς περίγραμμα (πιο καθαρό)
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: const BorderSide(
                              color: AppColors.main, // Λεπτό περίγραμμα όταν γράφεις
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),

          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            // <--- 3. ΠΕΡΝΑΜΕ ΤΟ ID ΣΤΟ NAVBAR ---
            child: MainNavBar(currentIndex: 0, currentUserId: currentUserId),
          ),
        ],
      ),
    );
  }
}