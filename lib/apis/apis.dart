import 'dart:convert';
import 'dart:developer';

import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart';
import 'package:translator_plus/translator_plus.dart';

import '../helper/global.dart';

class APIs {

  // ── GEMINI (ativo) ──────────────────────────────
  static Future<String> getAnswerGemini(String question) async {
    try {
      final model = GenerativeModel(
        model: 'gemini-1.5-flash-latest',
        apiKey: apiKey,
      );
      final res = await model.generateContent(
        [Content.text(question)],
        safetySettings: [
          SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.none),
          SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.none),
          SafetySetting(HarmCategory.harassment, HarmBlockThreshold.none),
          SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.none),
        ],
      );
      return res.text ?? 'Sem resposta';
    } catch (e) {
      log('getAnswerGeminiE: $e');
      return 'Algo deu errado (tente novamente)';
    }
  }

  // ── CHATGPT ─────────────────────────────────────
  static Future<String> getAnswerGPT(String question) async {
    try {
      final res = await post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $gptKey',
        },
        body: jsonEncode({
          'model': 'gpt-4o-mini',
          'max_tokens': 2000,
          'messages': [
            {'role': 'user', 'content': question},
          ],
        }),
      );
      final data = jsonDecode(res.body);
      return data['choices'][0]['message']['content'];
    } catch (e) {
      log('getAnswerGPTE: $e');
      return 'Algo deu errado (tente novamente)';
    }
  }

  // ── CLAUDE ──────────────────────────────────────
  static Future<String> getAnswerClaude(String question) async {
    try {
      final res = await post(
        Uri.parse('https://api.anthropic.com/v1/messages'),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': claudeKey,
          'anthropic-version': '2023-06-01',
        },
        body: jsonEncode({
          'model': 'claude-sonnet-4-6',
          'max_tokens': 2000,
          'messages': [
            {'role': 'user', 'content': question},
          ],
        }),
      );
      final data = jsonDecode(res.body);
      return data['content'][0]['text'];
    } catch (e) {
      log('getAnswerClaudeE: $e');
      return 'Algo deu errado (tente novamente)';
    }
  }

  // ── XIAOAI / MIMO ────────────────────────────────
  // Formato compatível com OpenAI — confirme o endpoint na sua conta Xiaomi
  static Future<String> getAnswerXiaoAi(String question) async {
    try {
      final res = await post(
        Uri.parse('https://api.mimo.xiaomi.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $xiaoAiKey',
        },
        body: jsonEncode({
          'model': 'mimo-6b',
          'max_tokens': 2000,
          'messages': [
            {'role': 'user', 'content': question},
          ],
        }),
      );
      final data = jsonDecode(res.body);
      return data['choices'][0]['message']['content'];
    } catch (e) {
      log('getAnswerXiaoAiE: $e');
      return 'Algo deu errado (tente novamente)';
    }
  }

  // ── ROTEADOR INTELIGENTE ─────────────────────────
  // Detecta tipo de pergunta e escolhe o melhor provider
  static Future<String> getAnswer(String question) async {
    final q = question.toLowerCase();

    // Código → GPT
    if (q.contains('código') || q.contains('code') ||
        q.contains('dart') || q.contains('python') ||
        q.contains('flutter') || q.contains('função') ||
        q.contains('erro') || q.contains('bug')) {
      log('Router → GPT');
      return getAnswerGPT(question);
    }

    // Texto longo, redação, análise → Claude
    if (q.contains('explica') || q.contains('redija') ||
        q.contains('resumo') || q.contains('analise') ||
        q.contains('escreva') || q.contains('texto') ||
        q.length > 300) {
      log('Router → Claude');
      return getAnswerClaude(question);
    }

    // Perguntas rápidas e gerais → Gemini (gratuito, padrão)
    log('Router → Gemini');
    return getAnswerGemini(question);
  }

  // ── IMAGENS ──────────────────────────────────────
  static Future<List<String>> searchAiImages(String prompt) async {
    try {
      final res =
          await get(Uri.parse('https://lexica.art/api/v1/search?q=$prompt'));
      final data = jsonDecode(res.body);
      return List.from(data['images']).map((e) => e['src'].toString()).toList();
    } catch (e) {
      log('searchAiImagesE: $e');
      return [];
    }
  }

  // ── TRADUÇÃO ─────────────────────────────────────
  static Future<String> googleTranslate({
    required String from,
    required String to,
    required String text,
  }) async {
    try {
      final res = await GoogleTranslator().translate(text, from: from, to: to);
      return res.text;
    } catch (e) {
      log('googleTranslateE: $e');
      return 'Algo deu errado!';
    }
  }
}
