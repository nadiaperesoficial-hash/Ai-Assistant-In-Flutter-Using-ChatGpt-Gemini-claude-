import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../helper/global.dart';
import '../model/message.dart';

class MessageCard extends StatelessWidget {
  final Message message;

  const MessageCard({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return message.msgType == MessageType.bot
        ? _BotMessage(message: message)
        : _UserMessage(message: message);
  }
}

class _UserMessage extends StatelessWidget {
  final Message message;
  const _UserMessage({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            constraints: BoxConstraints(maxWidth: mq.width * .75),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFEEEEEE),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Text(
              message.msg,
              style: GoogleFonts.inter(
                fontSize: 15,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BotMessage extends StatelessWidget {
  final Message message;
  const _BotMessage({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (message.aiProvider != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _ProviderChip(provider: message.aiProvider!),
            ),
          message.msg.isEmpty
              ? AnimatedTextKit(
                  animatedTexts: [
                    TypewriterAnimatedText(
                      'Aguarde...',
                      textStyle: GoogleFonts.inter(
                        fontSize: 15,
                        color: Colors.grey,
                        height: 1.5,
                      ),
                      speed: const Duration(milliseconds: 80),
                    ),
                  ],
                  repeatForever: true,
                )
              : Text(
                  message.msg,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    color: Colors.black87,
                    height: 1.6,
                  ),
                ),
        ],
      ),
    );
  }
}

class _ProviderChip extends StatelessWidget {
  final String provider;
  const _ProviderChip({required this.provider});

  @override
  Widget build(BuildContext context) {
    final map = {
      'Gemini':   (const Color(0xFF4285F4), '⚡'),
      'Llama':    (const Color(0xFF6B8EFF), '🦙'),
      'Mixtral':  (const Color(0xFF10B981), '🌀'),
      'Gemma':    (const Color(0xFF34A853), '💎'),
      'Groq':     (const Color(0xFF6B8EFF), '⚡'),
      'Claude':   (const Color(0xFFF97316), '🧠'),
      'DeepSeek': (const Color(0xFF8B5CF6), '🔍'),
    };

    final entry = map[provider];
    final color = entry?.$1 ?? Colors.grey;
    final icon  = entry?.$2 ?? '🤖';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(icon, style: const TextStyle(fontSize: 13)),
        const SizedBox(width: 4),
        Text(
          provider,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
