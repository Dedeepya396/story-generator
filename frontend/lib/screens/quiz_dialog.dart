import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// ============================================================
// SHOW QUIZ
// ============================================================

Future<void> showQuizDialog(
  BuildContext context,
  String story,
) async {
  if (story.trim().isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Story text is not available for the quiz.",
        ),
      ),
    );

    return;
  }

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return QuizDialog(
        story: story,
      );
    },
  );
}

// ============================================================
// QUIZ DIALOG
// ============================================================

class QuizDialog extends StatefulWidget {
  final String story;

  const QuizDialog({
    super.key,
    required this.story,
  });

  @override
  State<QuizDialog> createState() => _QuizDialogState();
}

// ============================================================
// QUIZ STATE
// ============================================================

class _QuizDialogState extends State<QuizDialog> {
  // ----------------------------------------------------------
  // QUESTIONS
  // ----------------------------------------------------------

  List questions = [];

  // ----------------------------------------------------------
  // LOADING
  // ----------------------------------------------------------

  bool isLoading = true;

  // ----------------------------------------------------------
  // ERROR
  // ----------------------------------------------------------

  String? errorMessage;

  // ----------------------------------------------------------
  // CURRENT QUESTION
  // ----------------------------------------------------------

  int currentQuestion = 0;

  // ----------------------------------------------------------
  // SCORE
  // ----------------------------------------------------------

  int score = 0;

  // ----------------------------------------------------------
  // SELECTED ANSWER
  // ----------------------------------------------------------

  int? selectedAnswer;

  // ==========================================================
  // INIT
  // ==========================================================

  @override
  void initState() {
    super.initState();

    generateQuiz();
  }

  // ==========================================================
  // GENERATE QUIZ
  // ==========================================================

  Future<void> generateQuiz() async {
    try {
      final response = await http.post(
        Uri.parse(
          "http://localhost:8000/quiz/generate",
        ),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "story": widget.story,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception(
          "Backend error: ${response.body}",
        );
      }

      final data = jsonDecode(response.body);

      final List generatedQuestions =
          data["questions"];

      if (generatedQuestions.length != 5) {
        throw Exception(
          "Expected 5 questions",
        );
      }

      if (!mounted) return;

      setState(() {
        questions = generatedQuestions;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }

  // ==========================================================
  // SELECT ANSWER
  // ==========================================================

  void selectAnswer(int index) {
    if (selectedAnswer != null) {
      return;
    }

    final int correctAnswer = int.parse(
      questions[currentQuestion]["answer"].toString(),
    );

    setState(() {
      selectedAnswer = index;

      if (index == correctAnswer) {
        score++;
      }
    });
  }

  // ==========================================================
  // NEXT QUESTION
  // ==========================================================

  void nextQuestion() {
    if (selectedAnswer == null) {
      return;
    }

    if (currentQuestion ==
        questions.length - 1) {
      setState(() {
        currentQuestion = questions.length;
      });

      return;
    }

    setState(() {
      currentQuestion++;
      selectedAnswer = null;
    });
  }

  // ==========================================================
  // EXIT QUIZ CONFIRMATION
  // ==========================================================

  Future<void> exitQuiz() async {
    final shouldExit = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(20),
          ),
          title: const Text(
            "Exit Quiz?",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF49243E),
            ),
          ),
          content: const Text(
            "Are you sure you want to leave the quiz? "
            "Your progress will be lost.",
            style: TextStyle(
              fontSize: 15,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  false,
                );
              },
              child: const Text(
                "Cancel",
                style: TextStyle(
                  color: Color(0xFF49243E),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(0xFFFB6F92),
                foregroundColor:
                    Colors.white,
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                "Exit",
              ),
            ),
          ],
        );
      },
    );

    if (shouldExit == true && mounted) {
      Navigator.pop(context);
    }
  }

  // ==========================================================
  // SCORE MESSAGE
  // ==========================================================

  String getScoreMessage() {
    if (score == 5) {
      return "Excellent! 🌟";
    }

    if (score >= 3) {
      return "Good job! 👍";
    }

    return "Keep practicing! 💪";
  }

  // ==========================================================
  // OPTION COLOR
  // ==========================================================

  Color getOptionColor(int index) {
    if (selectedAnswer == null) {
      return Colors.white;
    }

    final int correctAnswer = int.parse(
      questions[currentQuestion]["answer"]
          .toString(),
    );

    if (index == correctAnswer) {
      return Colors.green.shade100;
    }

    if (index == selectedAnswer &&
        index != correctAnswer) {
      return Colors.red.shade100;
    }

    return Colors.white;
  }

  // ==========================================================
  // BORDER COLOR
  // ==========================================================

  Color getBorderColor(int index) {
    if (selectedAnswer == null) {
      return Colors.grey.shade300;
    }

    final int correctAnswer = int.parse(
      questions[currentQuestion]["answer"]
          .toString(),
    );

    if (index == correctAnswer) {
      return Colors.green;
    }

    if (index == selectedAnswer) {
      return Colors.red;
    }

    return Colors.grey.shade300;
  }

  // ==========================================================
  // OPTION ICON
  // ==========================================================

  Widget? getOptionIcon(int index) {
    if (selectedAnswer == null) {
      return null;
    }

    final int correctAnswer = int.parse(
      questions[currentQuestion]["answer"]
          .toString(),
    );

    if (index == correctAnswer) {
      return const Icon(
        Icons.check_circle,
        color: Colors.green,
      );
    }

    if (index == selectedAnswer) {
      return const Icon(
        Icons.cancel,
        color: Colors.red,
      );
    }

    return null;
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    // ========================================================
    // LOADING
    // ========================================================

    if (isLoading) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(24),
        ),
        child: const Padding(
          padding: EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                color: Color(0xFFFB6F92),
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                "Creating your quiz...",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight:
                      FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // ========================================================
    // ERROR
    // ========================================================

    if (errorMessage != null) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(24),
        ),
        child: Padding(
          padding:
              const EdgeInsets.all(30),
          child: Column(
            mainAxisSize:
                MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 55,
                color: Colors.red,
              ),

              const SizedBox(
                height: 15,
              ),

              const Text(
                "Could not generate quiz",
                textAlign:
                    TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight:
                      FontWeight.bold,
                  color:
                      Color(0xFF49243E),
                ),
              ),

              const SizedBox(
                height: 10,
              ),

              Text(
                errorMessage!,
                textAlign:
                    TextAlign.center,
                style:
                    const TextStyle(
                  color: Colors.grey,
                ),
              ),

              const SizedBox(
                height: 20,
              ),

              SizedBox(
                width:
                    double.infinity,
                child:
                    ElevatedButton(
                  onPressed: () {
                    Navigator.pop(
                      context,
                    );
                  },
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(
                      0xFFFB6F92,
                    ),
                    foregroundColor:
                        Colors.white,
                  ),
                  child:
                      const Text(
                    "Close",
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // ========================================================
    // RESULT
    // ========================================================

    if (currentQuestion >=
        questions.length) {
      return buildResult();
    }

    // ========================================================
    // CURRENT QUESTION
    // ========================================================

    final question =
        questions[currentQuestion];

    final String questionText =
        question["question"];

    final List options =
        question["options"];

    // ========================================================
    // QUIZ
    // ========================================================

    return Dialog(
      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(24),
      ),
      child: Container(
        constraints:
            const BoxConstraints(
          maxWidth: 520,
          maxHeight: 700,
        ),
        padding:
            const EdgeInsets.all(24),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            // =================================================
            // HEADER
            // =================================================

            Row(
              mainAxisAlignment:
                  MainAxisAlignment
                      .spaceBetween,
              children: [
                const Text(
                  "Story Quiz",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight:
                        FontWeight.bold,
                    color:
                        Color(0xFF49243E),
                  ),
                ),

                Row(
                  children: [
                    // QUESTION NUMBER
                    Container(
                      padding:
                          const EdgeInsets
                              .symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration:
                          BoxDecoration(
                        color:
                            const Color(
                          0xFFFFE4F1,
                        ),
                        borderRadius:
                            BorderRadius
                                .circular(
                          20,
                        ),
                      ),
                      child: Text(
                        "${currentQuestion + 1} / ${questions.length}",
                        style:
                            const TextStyle(
                          color:
                              Color(
                            0xFFFB6F92,
                          ),
                          fontWeight:
                              FontWeight
                                  .bold,
                        ),
                      ),
                    ),

                    const SizedBox(
                      width: 6,
                    ),

                    // EXIT BUTTON
                    IconButton(
                      onPressed:
                          exitQuiz,
                      tooltip:
                          "Exit Quiz",
                      icon:
                          const Icon(
                        Icons.close,
                        color:
                            Color(
                          0xFF49243E,
                        ),
                        size: 26,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(
              height: 18,
            ),

            // =================================================
            // PROGRESS
            // =================================================

            LinearProgressIndicator(
              value:
                  (currentQuestion + 1) /
                      questions.length,
              minHeight: 6,
              borderRadius:
                  BorderRadius.circular(
                10,
              ),
              color:
                  const Color(0xFFFB6F92),
              backgroundColor:
                  const Color(
                0xFFFFCFE2,
              ),
            ),

            const SizedBox(
              height: 25,
            ),

            // =================================================
            // QUESTION
            // =================================================

            Text(
              questionText,
              style:
                  const TextStyle(
                fontSize: 20,
                fontWeight:
                    FontWeight.bold,
                color:
                    Color(0xFF49243E),
                height: 1.4,
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            // =================================================
            // OPTIONS
            // =================================================

            Flexible(
              child:
                  SingleChildScrollView(
                child: Column(
                  children: [
                    ...List.generate(
                      options.length,
                      (index) {
                        return buildOption(
                          index,
                          options[index]
                              .toString(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(
              height: 12,
            ),

            // =================================================
            // NEXT
            // =================================================

            SizedBox(
              width:
                  double.infinity,
              height: 50,
              child:
                  ElevatedButton(
                onPressed:
                    selectedAnswer ==
                            null
                        ? null
                        : nextQuestion,
                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(
                    0xFFFB6F92,
                  ),
                  foregroundColor:
                      Colors.white,
                  disabledBackgroundColor:
                      Colors.grey.shade300,
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius
                            .circular(
                      12,
                    ),
                  ),
                ),
                child: Text(
                  currentQuestion ==
                          questions.length -
                              1
                      ? "Finish Quiz"
                      : "Next Question",
                  style:
                      const TextStyle(
                    fontSize: 16,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // OPTION
  // ==========================================================

  Widget buildOption(
    int index,
    String option,
  ) {
    final icon =
        getOptionIcon(index);

    return GestureDetector(
      onTap: () {
        selectAnswer(index);
      },
      child:
          AnimatedContainer(
        duration:
            const Duration(
          milliseconds: 200,
        ),
        width:
            double.infinity,
        margin:
            const EdgeInsets.only(
          bottom: 12,
        ),
        padding:
            const EdgeInsets.all(14),
        decoration:
            BoxDecoration(
          color:
              getOptionColor(index),
          border:
              Border.all(
            color:
                getBorderColor(index),
            width: 2,
          ),
          borderRadius:
              BorderRadius.circular(
            14,
          ),
        ),
        child:
            Row(
          children: [
            // -------------------------------------------------
            // A / B / C / D
            // -------------------------------------------------

            Container(
              width: 36,
              height: 36,
              alignment:
                  Alignment.center,
              decoration:
                  BoxDecoration(
                shape:
                    BoxShape.circle,
                color:
                    Colors.grey.shade200,
              ),
              child:
                  Text(
                String.fromCharCode(
                  65 + index,
                ),
                style:
                    const TextStyle(
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(
              width: 12,
            ),

            // -------------------------------------------------
            // TEXT
            // -------------------------------------------------

            Expanded(
              child:
                  Text(
                option,
                style:
                    const TextStyle(
                  fontSize: 16,
                  color:
                      Color(
                    0xFF49243E,
                  ),
                ),
              ),
            ),

            // -------------------------------------------------
            // ICON
            // -------------------------------------------------

            if (icon != null)
              icon,
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // RESULT SCREEN
  // ==========================================================

  Widget buildResult() {
    return Dialog(
      insetPadding:
          const EdgeInsets.symmetric(
        horizontal: 40,
        vertical: 24,
      ),
      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Padding(
        padding:
            const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 20,
        ),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            // -------------------------------------------------
            // CELEBRATION
            // -------------------------------------------------

            const Text(
              "🎉",
              style:
                  TextStyle(
                fontSize: 42,
              ),
            ),

            const SizedBox(
              height: 5,
            ),

            // -------------------------------------------------
            // TITLE
            // -------------------------------------------------

            const Text(
              "Quiz Complete!",
              style:
                  TextStyle(
                fontSize: 22,
                fontWeight:
                    FontWeight.bold,
                color:
                    Color(0xFF49243E),
              ),
            ),

            const SizedBox(
              height: 12,
            ),

            // -------------------------------------------------
            // SCORE LABEL
            // -------------------------------------------------

            const Text(
              "Your Score",
              style:
                  TextStyle(
                fontSize: 15,
                color:
                    Colors.grey,
              ),
            ),

            const SizedBox(
              height: 4,
            ),

            // -------------------------------------------------
            // SCORE
            // -------------------------------------------------

            Text(
              "$score / ${questions.length}",
              style:
                  const TextStyle(
                fontSize: 28,
                fontWeight:
                    FontWeight.bold,
                color:
                    Color(0xFFFB6F92),
              ),
            ),

            const SizedBox(
              height: 8,
            ),

            // -------------------------------------------------
            // MESSAGE
            // -------------------------------------------------

            Text(
              getScoreMessage(),
              textAlign:
                  TextAlign.center,
              style:
                  const TextStyle(
                fontSize: 16,
                color:
                    Color(0xFF49243E),
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            // -------------------------------------------------
            // DONE BUTTON
            // -------------------------------------------------

            SizedBox(
              width: 180,
              height: 42,
              child:
                  ElevatedButton(
                onPressed: () {
                  Navigator.pop(
                    context,
                  );
                },
                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(
                    0xFFFB6F92,
                  ),
                  foregroundColor:
                      Colors.white,
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius
                            .circular(
                      10,
                    ),
                  ),
                ),
                child:
                    const Text(
                  "Done",
                  style:
                      TextStyle(
                    fontSize: 15,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}