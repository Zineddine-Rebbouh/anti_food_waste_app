import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:anti_food_waste_app/features/chat/models/chat_models.dart';
import 'package:anti_food_waste_app/features/chat/presentation/cubit/chat_cubit.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  static const Color primaryGreen = Color(0xFF2D8659);
  static const Color accentBeige = Colors.white;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late AnimationController _modeBannerController;
  late Animation<double> _modeBannerAnimation;

  @override
  void initState() {
    super.initState();
    _modeBannerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _modeBannerAnimation = CurvedAnimation(
      parent: _modeBannerController,
      curve: Curves.easeOut,
    );
    context.read<ChatCubit>().startSession();
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _modeBannerController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    context.read<ChatCubit>().sendMessage(text);
    _textController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: ChatScreen.accentBeige,
      appBar: _buildAppBar(context, l10n),
      drawer: _ChatHistoryDrawer(l10n: l10n),
      body: BlocConsumer<ChatCubit, ChatState>(
        listenWhen: (prev, curr) =>
            prev.messages.length != curr.messages.length ||
            prev.isTyping != curr.isTyping ||
            prev.isAdminTyping != curr.isAdminTyping ||
            prev.mode != curr.mode ||
            prev.modeChangeMessage != curr.modeChangeMessage,
        listener: (context, state) {
          _scrollToBottom();
          if (state.modeChangeMessage != null) {
            _modeBannerController.forward(from: 0);
          }
        },
        builder: (context, state) {
          if (state.isLoading && state.messages.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: ChatScreen.primaryGreen));
          }

          if (state.error != null && state.messages.isEmpty) {
            return _buildErrorState(state.error!, l10n);
          }

          return Column(
            children: [
              if (state.modeChangeMessage != null)
                _ModeChangeBanner(
                  message: state.modeChangeMessage!,
                  isAdmin: state.isAdminMode,
                  adminName: state.adminName,
                  animation: _modeBannerAnimation,
                  onDismiss: () =>
                      context.read<ChatCubit>().acknowledgeModeChange(),
                ),

              _ModeIndicatorBar(state: state),

              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                  itemCount: state.messages.length +
                      (_showTypingIndicator(state) ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == state.messages.length &&
                        _showTypingIndicator(state)) {
                      return _TypingIndicator(
                        isAdmin: state.isAdminTyping,
                        adminName: state.adminName,
                      );
                    }
                    final msg = state.messages[index];
                    return _MessageBubble(message: msg);
                  },
                ),
              ),

              if (state.messages.isNotEmpty &&
                  state.messages.last.sender == 'bot' &&
                  state.messages.last.quickReplies.isNotEmpty)
                _QuickRepliesBar(replies: state.messages.last.quickReplies),

              _InputBar(
                controller: _textController,
                state: state,
                onSend: _sendMessage,
                l10n: l10n,
              ),
            ],
          );
        },
      ),
    );
  }

  bool _showTypingIndicator(ChatState state) =>
      state.isTyping || state.isAdminTyping;

  PreferredSizeWidget _buildAppBar(BuildContext context, AppLocalizations l10n) {
    return AppBar(
      backgroundColor: ChatScreen.accentBeige,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.history_rounded, color: ChatScreen.primaryGreen),
        onPressed: () {
          context.read<ChatCubit>().loadConversations();
          _scaffoldKey.currentState?.openDrawer();
        },
        tooltip: l10n.chat_history,
      ),
      title: BlocBuilder<ChatCubit, ChatState>(
        buildWhen: (p, c) => p.mode != c.mode || p.adminName != c.adminName,
        builder: (context, state) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.support_chat.toUpperCase(),
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: ChatScreen.primaryGreen, letterSpacing: 1.5),
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: state.isAdminMode ? Colors.purple : Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    state.isAdminMode
                        ? '${state.adminName ?? l10n.support_agent} • Agent'
                        : l10n.ai_assistant,
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ],
          );
        },
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.close_rounded, color: ChatScreen.primaryGreen),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget _buildErrorState(String error, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.red.shade50, shape: BoxShape.circle),
              child: Icon(Icons.error_outline_rounded, size: 40, color: Colors.red.shade400),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.failed_load_chat(error),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => context.read<ChatCubit>().startSession(),
              style: ElevatedButton.styleFrom(
                backgroundColor: ChatScreen.primaryGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: Text(l10n.retry.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeChangeBanner extends StatelessWidget {
  final String message;
  final bool isAdmin;
  final String? adminName;
  final Animation<double> animation;
  final VoidCallback onDismiss;

  const _ModeChangeBanner({
    required this.message,
    required this.isAdmin,
    required this.animation,
    required this.onDismiss,
    this.adminName,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isAdmin ? Colors.purple.shade50 : Colors.green.shade50;
    final color = isAdmin ? Colors.purple : Colors.green;

    return SizeTransition(
      axisAlignment: -1,
      sizeFactor: animation,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Icon(isAdmin ? Icons.support_agent_rounded : Icons.smart_toy_rounded, color: color, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(fontSize: 13, color: color.shade900, fontWeight: FontWeight.w700),
              ),
            ),
            GestureDetector(
              onTap: onDismiss,
              child: Icon(Icons.close_rounded, size: 18, color: color.withOpacity(0.4)),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeIndicatorBar extends StatelessWidget {
  final ChatState state;
  const _ModeIndicatorBar({required this.state});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (!state.isAdminMode) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      color: Colors.purple.shade50.withOpacity(0.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.purple, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text(
            state.isAdminMode 
                ? '${l10n.support_agent}: ${state.adminName ?? ""}'
                : l10n.ai_assistant,
            style: TextStyle(fontSize: 11, color: Colors.purple.shade700, fontWeight: FontWeight.w800, letterSpacing: 0.5),
          ),
        ],
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  final bool isAdmin;
  final String? adminName;
  const _TypingIndicator({required this.isAdmin, this.adminName});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20).copyWith(bottomLeft: Radius.zero),
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(strokeWidth: 1.5, color: isAdmin ? Colors.purple : ChatScreen.primaryGreen),
                ),
                const SizedBox(width: 10),
                Text(
                  isAdmin ? l10n.agent_typing(adminName ?? l10n.support_agent) : l10n.ai_thinking,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w600, fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickRepliesBar extends StatelessWidget {
  final List<QuickReply> replies;
  const _QuickRepliesBar({required this.replies});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: replies.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          return ActionChip(
            label: Text(replies[i].label),
            labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: ChatScreen.primaryGreen),
            backgroundColor: Colors.white,
            side: BorderSide(color: ChatScreen.primaryGreen.withOpacity(0.2)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
            onPressed: () => context.read<ChatCubit>().sendMessage(replies[i].label),
          );
        },
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final ChatState state;
  final VoidCallback onSend;
  final AppLocalizations l10n;

  const _InputBar({required this.controller, required this.state, required this.onSend, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final disabled = state.isResolved;
    final hint = disabled ? l10n.chat_ended : (state.isAdminMode ? l10n.message_agent_hint(state.adminName ?? l10n.support_agent) : l10n.type_message);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              enabled: !disabled,
              onChanged: (v) { if (v.isNotEmpty) context.read<ChatCubit>().sendTypingIndicator(true); },
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(fontSize: 15, color: Colors.grey.shade400, fontWeight: FontWeight.w500),
                border: InputBorder.none,
                filled: true,
                fillColor: ChatScreen.accentBeige,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: const BorderSide(color: ChatScreen.primaryGreen, width: 1.5)),
              ),
              onSubmitted: disabled ? null : (_) => onSend(),
              maxLines: 4,
              minLines: 1,
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: disabled ? null : onSend,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: disabled ? Colors.grey.shade200 : ChatScreen.primaryGreen,
                shape: BoxShape.circle,
                boxShadow: disabled ? null : [BoxShadow(color: ChatScreen.primaryGreen.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.sender == 'user';
    final isSystem = message.sender == 'system';
    final isAdmin = message.sender == 'admin';

    if (isSystem) {
      return Center(
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(100)),
          child: Text(message.textContent, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.grey.shade500, letterSpacing: 0.5)),
        ),
      );
    }

    final bubbleColor = isUser ? ChatScreen.primaryGreen : const Color(0xFFF0FDF4);
    final textColor = isUser ? Colors.white : const Color(0xFF111827);

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (isAdmin)
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 4),
              child: Text(message.senderName.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.purple.shade700, letterSpacing: 1)),
            ),
          Container(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: BorderRadius.circular(24).copyWith(
                bottomLeft: isUser ? const Radius.circular(24) : Radius.zero,
                bottomRight: isUser ? Radius.zero : const Radius.circular(24),
              ),
              border: isUser ? null : Border.all(color: Colors.grey.shade100),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Text(message.textContent, style: TextStyle(color: textColor, fontSize: 14, height: 1.5, fontWeight: isUser ? FontWeight.w600 : FontWeight.w500)),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              DateFormat('HH:mm').format(message.createdAt.toLocal()),
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.grey.shade400),
            ),
          ),
          if (message.cards.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...message.cards.map((c) => _ChatCard(card: c)),
          ],
        ],
      ),
    );
  }
}

class _ChatCard extends StatelessWidget {
  final ChatCard card;
  const _ChatCard({required this.card});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(card.title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Color(0xFF111827))),
          if (card.subtitle.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(card.subtitle, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade500)),
          ],
          if (card.data.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...card.data.entries.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Text("${e.key}: ", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.grey.shade400)),
                  Text(e.value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
                ],
              ),
            )),
          ],
          if (card.actions.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: card.actions.map((act) => ElevatedButton(
                onPressed: () => context.read<ChatCubit>().sendMessage(act.label),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ChatScreen.primaryGreen.withOpacity(0.05),
                  foregroundColor: ChatScreen.primaryGreen,
                  elevation: 0,
                  minimumSize: Size.zero,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(act.label.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
              )).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _ChatHistoryDrawer extends StatelessWidget {
  final AppLocalizations l10n;
  const _ChatHistoryDrawer({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: ChatScreen.accentBeige,
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: ChatScreen.primaryGreen),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.support_agent_rounded, size: 48, color: Colors.white),
                  const SizedBox(height: 12),
                  Text(l10n.chat_history.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: ElevatedButton.icon(
              onPressed: () { Navigator.pop(context); context.read<ChatCubit>().startNewChat(); },
              icon: const Icon(Icons.add_rounded),
              label: Text(l10n.new_chat.toUpperCase()),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                backgroundColor: ChatScreen.primaryGreen,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                textStyle: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1),
              ),
            ),
          ),
          const Divider(indent: 20, endIndent: 20),
          Expanded(
            child: BlocBuilder<ChatCubit, ChatState>(
              builder: (context, state) {
                if (state.conversations.isEmpty) {
                  return Center(child: Text(l10n.no_chat_history, style: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.w600)));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: state.conversations.length,
                  itemBuilder: (context, index) {
                    final conv = state.conversations[index];
                    final isActive = conv.id == state.conversationId;
                    final isResolved = conv.status == 'resolved' || conv.status == 'ended';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: isActive ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ListTile(
                        onTap: () { Navigator.pop(context); context.read<ChatCubit>().switchConversation(conv.id); },
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        leading: CircleAvatar(
                          backgroundColor: isResolved ? Colors.grey.shade100 : ChatScreen.primaryGreen.withOpacity(0.1),
                          child: Icon(isResolved ? Icons.check_rounded : Icons.chat_bubble_outline_rounded, size: 18, color: isResolved ? Colors.grey : ChatScreen.primaryGreen),
                        ),
                        title: Text(
                          conv.id.length > 8 ? "Chat #${conv.id.substring(0, 8)}" : "Chat #${conv.id}",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 14, fontWeight: isActive ? FontWeight.w800 : FontWeight.w600, color: isActive ? ChatScreen.primaryGreen : Colors.grey.shade700),
                        ),
                        subtitle: Text(
                          DateFormat('MMM d, HH:mm').format(conv.createdAt.toLocal()),
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade400, fontWeight: FontWeight.w500),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
