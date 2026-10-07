import 'dart:convert';

import 'package:app_common_kit/app_common_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yourwish_kentei/yourwish_kentei.dart';

void main() {
  runApp(const UkalabSeiseiAiPassportApp());
}

/// 最小構成の動作確認用アプリ。ホーム→演習10問→結果の最短経路のみ実装する。
class UkalabSeiseiAiPassportApp extends StatelessWidget {
  const UkalabSeiseiAiPassportApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'うかラボ 生成AIパスポート',
      theme: UkalabTheme.light(
        field: UkalabField.ai,
        cert: UkalabCert.genAiPassport,
      ),
      darkTheme: UkalabTheme.dark(
        field: UkalabField.ai,
        cert: UkalabCert.genAiPassport,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<_LoadedContent> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadContent();
  }

  Future<_LoadedContent> _loadContent() async {
    final examText =
        await rootBundle.loadString('content/exam/seisei_ai_passport.json');
    final exam = ExamConfig.fromJson(
      jsonDecode(examText) as Map<String, dynamic>,
    );
    final questionsText =
        await rootBundle.loadString('content/exam/questions.jsonl');
    final parsed = parseQuestionsJsonl(questionsText);
    return _LoadedContent(exam: exam, questions: parsed.questions);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('うかラボ 生成AIパスポート')),
      body: FutureBuilder<_LoadedContent>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return ErrorState(
              message: '問題データの読み込みに失敗しました: ${snapshot.error}',
            );
          }
          final content = snapshot.data;
          if (content == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  content.exam.name,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text('問題データ ${content.questions.length}問'),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => PracticeScreen(
                          questions: content.questions,
                        ),
                      ),
                    );
                  },
                  child: const Text('演習を始める（10問）'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _LoadedContent {
  const _LoadedContent({required this.exam, required this.questions});

  final ExamConfig exam;
  final List<Question> questions;
}

class PracticeScreen extends StatefulWidget {
  const PracticeScreen({super.key, required this.questions});

  final List<Question> questions;

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  late final PracticeSession _session;
  int? _selected;
  bool _answered = false;

  @override
  void initState() {
    super.initState();
    _session = PracticeSession(pool: widget.questions, size: 10, seed: 0);
  }

  void _selectChoice(int choiceIndex) {
    if (_answered) return;
    setState(() {
      _selected = choiceIndex;
      _answered = true;
    });
    _session.answer(choiceIndex);
  }

  void _next() {
    if (_session.finished) return;
    setState(() {
      _selected = null;
      _answered = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final question = _session.current;
    if (question == null) {
      return ResultScreen(session: _session);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('演習')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            QuestionCard(
              index: _session.index + 1,
              total: _session.questions.length,
              text: question.prompt,
              child: Column(
                children: [
                  for (var i = 0; i < question.choices.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: ChoiceTile(
                        label: String.fromCharCode('A'.codeUnitAt(0) + i),
                        text: question.choices[i],
                        state: _choiceState(i, question.answerIndex),
                        onTap: _answered ? null : () => _selectChoice(i),
                      ),
                    ),
                ],
              ),
            ),
            if (_answered) ...[
              const SizedBox(height: 16),
              ExplanationPanel(
                body: question.explanation,
                sourceRef: question.sourceRef,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _next,
                child: Text(_session.finished ? '結果を見る' : '次の問題'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  ChoiceState _choiceState(int i, int answerIndex) {
    if (!_answered) {
      return i == _selected ? ChoiceState.selected : ChoiceState.idle;
    }
    if (i == answerIndex) return ChoiceState.correct;
    if (i == _selected) return ChoiceState.incorrect;
    return ChoiceState.idle;
  }
}

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key, required this.session});

  final PracticeSession session;

  @override
  Widget build(BuildContext context) {
    final total = session.questions.length;
    final correct = session.correctCount;
    return Scaffold(
      appBar: AppBar(title: const Text('結果')),
      body: Center(
        child: ResultSummary(
          correct: correct,
          total: total,
          onClose: () => Navigator.of(context).popUntil((r) => r.isFirst),
        ),
      ),
    );
  }
}
