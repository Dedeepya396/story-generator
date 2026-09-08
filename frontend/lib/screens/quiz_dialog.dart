// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;

// // ============================================================
// // SHOW QUIZ
// // ============================================================

// Future<void> showQuizDialog(
//   BuildContext context,
//   String story,
// ) async {
//   if (story.trim().isEmpty) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text(
//           "Story text is not available for the quiz.",
//         ),
//       ),
//     );

//     return;
//   }

//   showDialog(
//     context: context,
//     barrierDismissible: false,
//     builder: (context) {
//       return QuizDialog(
//         story: story,
//       );
//     },
//   );
// }

// // ============================================================
// // QUIZ DIALOG
// // ============================================================

// class QuizDialog extends StatefulWidget {
//   final String story;

//   const QuizDialog({
//     super.key,
//     required this.story,
//   });

//   @override
//   State<QuizDialog> createState() => _QuizDialogState();
// }

// // ============================================================
// // QUIZ STATE
// // ============================================================

// class _QuizDialogState extends State<QuizDialog> {
//   // ----------------------------------------------------------
//   // QUESTIONS
//   // ----------------------------------------------------------

//   List questions = [];

//   // ----------------------------------------------------------
//   // LOADING
//   // ----------------------------------------------------------

//   bool isLoading = true;

//   // ----------------------------------------------------------
//   // ERROR
//   // ----------------------------------------------------------

//   String? errorMessage;

//   // ----------------------------------------------------------
//   // CURRENT QUESTION
//   // ----------------------------------------------------------

//   int currentQuestion = 0;

//   // ----------------------------------------------------------
//   // SCORE
//   // ----------------------------------------------------------

//   int score = 0;

//   // ----------------------------------------------------------
//   // SELECTED ANSWER
//   // ----------------------------------------------------------

//   int? selectedAnswer;

//   // ==========================================================
//   // INIT
//   // ==========================================================

//   @override
//   void initState() {
//     super.initState();

//     generateQuiz();
//   }

//   // ==========================================================
//   // GENERATE QUIZ
//   // ==========================================================

//   Future<void> generateQuiz() async {
//     try {
//       final response = await http.post(
//         Uri.parse(
//           "http://localhost:8000/quiz/generate",
//         ),
//         headers: {
//           "Content-Type": "application/json",
//         },
//         body: jsonEncode({
//           "story": widget.story,
//         }),
//       );

//       if (response.statusCode != 200) {
//         throw Exception(
//           "Backend error: ${response.body}",
//         );
//       }

//       final data = jsonDecode(response.body);

//       final List generatedQuestions =
//           data["questions"];

//       if (generatedQuestions.length != 5) {
//         throw Exception(
//           "Expected 5 questions",
//         );
//       }

//       if (!mounted) return;

//       setState(() {
//         questions = generatedQuestions;
//         isLoading = false;
//       });
//     } catch (e) {
//       if (!mounted) return;

//       setState(() {
//         isLoading = false;
//         errorMessage = e.toString();
//       });
//     }
//   }

//   // ==========================================================
//   // SELECT ANSWER
//   // ==========================================================

//   void selectAnswer(int index) {
//     if (selectedAnswer != null) {
//       return;
//     }

//     final int correctAnswer = int.parse(
//       questions[currentQuestion]["answer"].toString(),
//     );

//     setState(() {
//       selectedAnswer = index;

//       if (index == correctAnswer) {
//         score++;
//       }
//     });
//   }

//   // ==========================================================
//   // NEXT QUESTION
//   // ==========================================================

//   void nextQuestion() {
//     if (selectedAnswer == null) {
//       return;
//     }

//     if (currentQuestion ==
//         questions.length - 1) {
//       setState(() {
//         currentQuestion = questions.length;
//       });

//       return;
//     }

//     setState(() {
//       currentQuestion++;
//       selectedAnswer = null;
//     });
//   }

//   // ==========================================================
//   // EXIT QUIZ CONFIRMATION
//   // ==========================================================

//   Future<void> exitQuiz() async {
//     final shouldExit = await showDialog<bool>(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) {
//         return AlertDialog(
//           shape: RoundedRectangleBorder(
//             borderRadius:
//                 BorderRadius.circular(20),
//           ),
//           title: const Text(
//             "Exit Quiz?",
//             style: TextStyle(
//               fontWeight: FontWeight.bold,
//               color: Color(0xFF49243E),
//             ),
//           ),
//           content: const Text(
//             "Are you sure you want to leave the quiz? "
//             "Your progress will be lost.",
//             style: TextStyle(
//               fontSize: 15,
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(
//                   context,
//                   false,
//                 );
//               },
//               child: const Text(
//                 "Cancel",
//                 style: TextStyle(
//                   color: Color(0xFF49243E),
//                 ),
//               ),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.pop(
//                   context,
//                   true,
//                 );
//               },
//               style:
//                   ElevatedButton.styleFrom(
//                 backgroundColor:
//                     const Color(0xFFFB6F92),
//                 foregroundColor:
//                     Colors.white,
//                 shape:
//                     RoundedRectangleBorder(
//                   borderRadius:
//                       BorderRadius.circular(10),
//                 ),
//               ),
//               child: const Text(
//                 "Exit",
//               ),
//             ),
//           ],
//         );
//       },
//     );

//     if (shouldExit == true && mounted) {
//       Navigator.pop(context);
//     }
//   }

//   // ==========================================================
//   // SCORE MESSAGE
//   // ==========================================================

//   String getScoreMessage() {
//     if (score == 5) {
//       return "Excellent! 🌟";
//     }

//     if (score >= 3) {
//       return "Good job! 👍";
//     }

//     return "Keep practicing! 💪";
//   }

//   // ==========================================================
//   // OPTION COLOR
//   // ==========================================================

//   Color getOptionColor(int index) {
//     if (selectedAnswer == null) {
//       return Colors.white;
//     }

//     final int correctAnswer = int.parse(
//       questions[currentQuestion]["answer"]
//           .toString(),
//     );

//     if (index == correctAnswer) {
//       return Colors.green.shade100;
//     }

//     if (index == selectedAnswer &&
//         index != correctAnswer) {
//       return Colors.red.shade100;
//     }

//     return Colors.white;
//   }

//   // ==========================================================
//   // BORDER COLOR
//   // ==========================================================

//   Color getBorderColor(int index) {
//     if (selectedAnswer == null) {
//       return Colors.grey.shade300;
//     }

//     final int correctAnswer = int.parse(
//       questions[currentQuestion]["answer"]
//           .toString(),
//     );

//     if (index == correctAnswer) {
//       return Colors.green;
//     }

//     if (index == selectedAnswer) {
//       return Colors.red;
//     }

//     return Colors.grey.shade300;
//   }

//   // ==========================================================
//   // OPTION ICON
//   // ==========================================================

//   Widget? getOptionIcon(int index) {
//     if (selectedAnswer == null) {
//       return null;
//     }

//     final int correctAnswer = int.parse(
//       questions[currentQuestion]["answer"]
//           .toString(),
//     );

//     if (index == correctAnswer) {
//       return const Icon(
//         Icons.check_circle,
//         color: Colors.green,
//       );
//     }

//     if (index == selectedAnswer) {
//       return const Icon(
//         Icons.cancel,
//         color: Colors.red,
//       );
//     }

//     return null;
//   }

//   // ==========================================================
//   // BUILD
//   // ==========================================================

//   @override
//   Widget build(BuildContext context) {
//     // ========================================================
//     // LOADING
//     // ========================================================

//     if (isLoading) {
//       return Dialog(
//         shape: RoundedRectangleBorder(
//           borderRadius:
//               BorderRadius.circular(24),
//         ),
//         child: const Padding(
//           padding: EdgeInsets.all(40),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               CircularProgressIndicator(
//                 color: Color(0xFFFB6F92),
//               ),
//               SizedBox(
//                 height: 20,
//               ),
//               Text(
//                 "Creating your quiz...",
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight:
//                       FontWeight.w600,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       );
//     }

//     // ========================================================
//     // ERROR
//     // ========================================================

//     if (errorMessage != null) {
//       return Dialog(
//         shape: RoundedRectangleBorder(
//           borderRadius:
//               BorderRadius.circular(24),
//         ),
//         child: Padding(
//           padding:
//               const EdgeInsets.all(30),
//           child: Column(
//             mainAxisSize:
//                 MainAxisSize.min,
//             children: [
//               const Icon(
//                 Icons.error_outline,
//                 size: 55,
//                 color: Colors.red,
//               ),

//               const SizedBox(
//                 height: 15,
//               ),

//               const Text(
//                 "Could not generate quiz",
//                 textAlign:
//                     TextAlign.center,
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight:
//                       FontWeight.bold,
//                   color:
//                       Color(0xFF49243E),
//                 ),
//               ),

//               const SizedBox(
//                 height: 10,
//               ),

//               Text(
//                 errorMessage!,
//                 textAlign:
//                     TextAlign.center,
//                 style:
//                     const TextStyle(
//                   color: Colors.grey,
//                 ),
//               ),

//               const SizedBox(
//                 height: 20,
//               ),

//               SizedBox(
//                 width:
//                     double.infinity,
//                 child:
//                     ElevatedButton(
//                   onPressed: () {
//                     Navigator.pop(
//                       context,
//                     );
//                   },
//                   style:
//                       ElevatedButton.styleFrom(
//                     backgroundColor:
//                         const Color(
//                       0xFFFB6F92,
//                     ),
//                     foregroundColor:
//                         Colors.white,
//                   ),
//                   child:
//                       const Text(
//                     "Close",
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       );
//     }

//     // ========================================================
//     // RESULT
//     // ========================================================

//     if (currentQuestion >=
//         questions.length) {
//       return buildResult();
//     }

//     // ========================================================
//     // CURRENT QUESTION
//     // ========================================================

//     final question =
//         questions[currentQuestion];

//     final String questionText =
//         question["question"];

//     final List options =
//         question["options"];

//     // ========================================================
//     // QUIZ
//     // ========================================================

//     return Dialog(
//       shape:
//           RoundedRectangleBorder(
//         borderRadius:
//             BorderRadius.circular(24),
//       ),
//       child: Container(
//         constraints:
//             const BoxConstraints(
//           maxWidth: 520,
//           maxHeight: 700,
//         ),
//         padding:
//             const EdgeInsets.all(24),
//         child: Column(
//           mainAxisSize:
//               MainAxisSize.min,
//           crossAxisAlignment:
//               CrossAxisAlignment.start,
//           children: [
//             // =================================================
//             // HEADER
//             // =================================================

//             Row(
//               mainAxisAlignment:
//                   MainAxisAlignment
//                       .spaceBetween,
//               children: [
//                 const Text(
//                   "Story Quiz",
//                   style: TextStyle(
//                     fontSize: 24,
//                     fontWeight:
//                         FontWeight.bold,
//                     color:
//                         Color(0xFF49243E),
//                   ),
//                 ),

//                 Row(
//                   children: [
//                     // QUESTION NUMBER
//                     Container(
//                       padding:
//                           const EdgeInsets
//                               .symmetric(
//                         horizontal: 12,
//                         vertical: 6,
//                       ),
//                       decoration:
//                           BoxDecoration(
//                         color:
//                             const Color(
//                           0xFFFFE4F1,
//                         ),
//                         borderRadius:
//                             BorderRadius
//                                 .circular(
//                           20,
//                         ),
//                       ),
//                       child: Text(
//                         "${currentQuestion + 1} / ${questions.length}",
//                         style:
//                             const TextStyle(
//                           color:
//                               Color(
//                             0xFFFB6F92,
//                           ),
//                           fontWeight:
//                               FontWeight
//                                   .bold,
//                         ),
//                       ),
//                     ),

//                     const SizedBox(
//                       width: 6,
//                     ),

//                     // EXIT BUTTON
//                     IconButton(
//                       onPressed:
//                           exitQuiz,
//                       tooltip:
//                           "Exit Quiz",
//                       icon:
//                           const Icon(
//                         Icons.close,
//                         color:
//                             Color(
//                           0xFF49243E,
//                         ),
//                         size: 26,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),

//             const SizedBox(
//               height: 18,
//             ),

//             // =================================================
//             // PROGRESS
//             // =================================================

//             LinearProgressIndicator(
//               value:
//                   (currentQuestion + 1) /
//                       questions.length,
//               minHeight: 6,
//               borderRadius:
//                   BorderRadius.circular(
//                 10,
//               ),
//               color:
//                   const Color(0xFFFB6F92),
//               backgroundColor:
//                   const Color(
//                 0xFFFFCFE2,
//               ),
//             ),

//             const SizedBox(
//               height: 25,
//             ),

//             // =================================================
//             // QUESTION
//             // =================================================

//             Text(
//               questionText,
//               style:
//                   const TextStyle(
//                 fontSize: 20,
//                 fontWeight:
//                     FontWeight.bold,
//                 color:
//                     Color(0xFF49243E),
//                 height: 1.4,
//               ),
//             ),

//             const SizedBox(
//               height: 20,
//             ),

//             // =================================================
//             // OPTIONS
//             // =================================================

//             Flexible(
//               child:
//                   SingleChildScrollView(
//                 child: Column(
//                   children: [
//                     ...List.generate(
//                       options.length,
//                       (index) {
//                         return buildOption(
//                           index,
//                           options[index]
//                               .toString(),
//                         );
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//             const SizedBox(
//               height: 12,
//             ),

//             // =================================================
//             // NEXT
//             // =================================================

//             SizedBox(
//               width:
//                   double.infinity,
//               height: 50,
//               child:
//                   ElevatedButton(
//                 onPressed:
//                     selectedAnswer ==
//                             null
//                         ? null
//                         : nextQuestion,
//                 style:
//                     ElevatedButton.styleFrom(
//                   backgroundColor:
//                       const Color(
//                     0xFFFB6F92,
//                   ),
//                   foregroundColor:
//                       Colors.white,
//                   disabledBackgroundColor:
//                       Colors.grey.shade300,
//                   shape:
//                       RoundedRectangleBorder(
//                     borderRadius:
//                         BorderRadius
//                             .circular(
//                       12,
//                     ),
//                   ),
//                 ),
//                 child: Text(
//                   currentQuestion ==
//                           questions.length -
//                               1
//                       ? "Finish Quiz"
//                       : "Next Question",
//                   style:
//                       const TextStyle(
//                     fontSize: 16,
//                     fontWeight:
//                         FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ==========================================================
//   // OPTION
//   // ==========================================================

//   Widget buildOption(
//     int index,
//     String option,
//   ) {
//     final icon =
//         getOptionIcon(index);

//     return GestureDetector(
//       onTap: () {
//         selectAnswer(index);
//       },
//       child:
//           AnimatedContainer(
//         duration:
//             const Duration(
//           milliseconds: 200,
//         ),
//         width:
//             double.infinity,
//         margin:
//             const EdgeInsets.only(
//           bottom: 12,
//         ),
//         padding:
//             const EdgeInsets.all(14),
//         decoration:
//             BoxDecoration(
//           color:
//               getOptionColor(index),
//           border:
//               Border.all(
//             color:
//                 getBorderColor(index),
//             width: 2,
//           ),
//           borderRadius:
//               BorderRadius.circular(
//             14,
//           ),
//         ),
//         child:
//             Row(
//           children: [
//             // -------------------------------------------------
//             // A / B / C / D
//             // -------------------------------------------------

//             Container(
//               width: 36,
//               height: 36,
//               alignment:
//                   Alignment.center,
//               decoration:
//                   BoxDecoration(
//                 shape:
//                     BoxShape.circle,
//                 color:
//                     Colors.grey.shade200,
//               ),
//               child:
//                   Text(
//                 String.fromCharCode(
//                   65 + index,
//                 ),
//                 style:
//                     const TextStyle(
//                   fontWeight:
//                       FontWeight.bold,
//                 ),
//               ),
//             ),

//             const SizedBox(
//               width: 12,
//             ),

//             // -------------------------------------------------
//             // TEXT
//             // -------------------------------------------------

//             Expanded(
//               child:
//                   Text(
//                 option,
//                 style:
//                     const TextStyle(
//                   fontSize: 16,
//                   color:
//                       Color(
//                     0xFF49243E,
//                   ),
//                 ),
//               ),
//             ),

//             // -------------------------------------------------
//             // ICON
//             // -------------------------------------------------

//             if (icon != null)
//               icon,
//           ],
//         ),
//       ),
//     );
//   }

//   // ==========================================================
//   // RESULT SCREEN
//   // ==========================================================

//   Widget buildResult() {
//     return Dialog(
//       insetPadding:
//           const EdgeInsets.symmetric(
//         horizontal: 40,
//         vertical: 24,
//       ),
//       shape:
//           RoundedRectangleBorder(
//         borderRadius:
//             BorderRadius.circular(20),
//       ),
//       child: Padding(
//         padding:
//             const EdgeInsets.symmetric(
//           horizontal: 24,
//           vertical: 20,
//         ),
//         child: Column(
//           mainAxisSize:
//               MainAxisSize.min,
//           children: [
//             // -------------------------------------------------
//             // CELEBRATION
//             // -------------------------------------------------

//             const Text(
//               "🎉",
//               style:
//                   TextStyle(
//                 fontSize: 42,
//               ),
//             ),

//             const SizedBox(
//               height: 5,
//             ),

//             // -------------------------------------------------
//             // TITLE
//             // -------------------------------------------------

//             const Text(
//               "Quiz Complete!",
//               style:
//                   TextStyle(
//                 fontSize: 22,
//                 fontWeight:
//                     FontWeight.bold,
//                 color:
//                     Color(0xFF49243E),
//               ),
//             ),

//             const SizedBox(
//               height: 12,
//             ),

//             // -------------------------------------------------
//             // SCORE LABEL
//             // -------------------------------------------------

//             const Text(
//               "Your Score",
//               style:
//                   TextStyle(
//                 fontSize: 15,
//                 color:
//                     Colors.grey,
//               ),
//             ),

//             const SizedBox(
//               height: 4,
//             ),

//             // -------------------------------------------------
//             // SCORE
//             // -------------------------------------------------

//             Text(
//               "$score / ${questions.length}",
//               style:
//                   const TextStyle(
//                 fontSize: 28,
//                 fontWeight:
//                     FontWeight.bold,
//                 color:
//                     Color(0xFFFB6F92),
//               ),
//             ),

//             const SizedBox(
//               height: 8,
//             ),

//             // -------------------------------------------------
//             // MESSAGE
//             // -------------------------------------------------

//             Text(
//               getScoreMessage(),
//               textAlign:
//                   TextAlign.center,
//               style:
//                   const TextStyle(
//                 fontSize: 16,
//                 color:
//                     Color(0xFF49243E),
//               ),
//             ),

//             const SizedBox(
//               height: 16,
//             ),

//             // -------------------------------------------------
//             // DONE BUTTON
//             // -------------------------------------------------

//             SizedBox(
//               width: 180,
//               height: 42,
//               child:
//                   ElevatedButton(
//                 onPressed: () {
//                   Navigator.pop(
//                     context,
//                   );
//                 },
//                 style:
//                     ElevatedButton.styleFrom(
//                   backgroundColor:
//                       const Color(
//                     0xFFFB6F92,
//                   ),
//                   foregroundColor:
//                       Colors.white,
//                   shape:
//                       RoundedRectangleBorder(
//                     borderRadius:
//                         BorderRadius
//                             .circular(
//                       10,
//                     ),
//                   ),
//                 ),
//                 child:
//                     const Text(
//                   "Done",
//                   style:
//                       TextStyle(
//                     fontSize: 15,
//                     fontWeight:
//                         FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }



import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// ============================================================
// SHOW QUIZ
// ============================================================

Future<void> showQuizDialog(
  BuildContext context,
  String story, {
  String language = 'english',
  int? videoDurationSeconds,
}) async {
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
        language: language,
        videoDurationSeconds: videoDurationSeconds,
      );
    },
  );
}

// ============================================================
// QUIZ DIALOG
// ============================================================

class QuizDialog extends StatefulWidget {
  final String story;
  final String language;
  final int? videoDurationSeconds;

  const QuizDialog({
    super.key,
    required this.story,
    this.language = 'english',
    this.videoDurationSeconds,
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
  // SELECTED ANSWERS
  // ----------------------------------------------------------
  //
  // Stores the selected answer for every question.
  //
  // Example:
  //
  // [2, 0, null, 3, null]
  //
  // null means that question has not been answered yet.
  //
  // ----------------------------------------------------------

  List<int?> selectedAnswers = [];

  // Convenient getter for the answer of the current question.
  int? get selectedAnswer {
    if (currentQuestion >= selectedAnswers.length) {
      return null;
    }

    return selectedAnswers[currentQuestion];
  }

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
          "language": widget.language,
          if (widget.videoDurationSeconds != null)
            "video_duration": widget.videoDurationSeconds,
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

      if (generatedQuestions.isEmpty) {
        throw Exception(
          "Failed to load quiz questions",
        );
      }

      if (!mounted) return;

      setState(() {
        questions = generatedQuestions;

        // Create one empty answer slot for
        // each question.
        selectedAnswers = List<int?>.filled(
          generatedQuestions.length,
          null,
        );

        currentQuestion = 0;
        score = 0;

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
    if (currentQuestion >= selectedAnswers.length) {
      return;
    }

    setState(() {
      selectedAnswers[currentQuestion] = index;
    });
  }

  // ==========================================================
  // CALCULATE SCORE
  // ==========================================================

  void calculateScore() {
    int calculatedScore = 0;

    for (int i = 0; i < questions.length; i++) {
      final int? userAnswer = selectedAnswers[i];

      if (userAnswer == null) {
        continue;
      }

      final int correctAnswer =
          int.parse(
        questions[i]["answer"].toString(),
      );

      if (userAnswer == correctAnswer) {
        calculatedScore++;
      }
    }

    score = calculatedScore;
  }

  // ==========================================================
  // NEXT QUESTION
  // ==========================================================

  void nextQuestion() {
    // User must select an answer before continuing.
    if (selectedAnswer == null) {
      return;
    }

    // If this is the last question,
    // calculate score and show result screen.
    if (currentQuestion ==
        questions.length - 1) {
      calculateScore();

      setState(() {
        currentQuestion = questions.length;
      });

      return;
    }

    setState(() {
      currentQuestion++;
    });
  }

  // ==========================================================
  // PREVIOUS QUESTION
  // ==========================================================

  void previousQuestion() {
    if (currentQuestion == 0) {
      return;
    }

    setState(() {
      currentQuestion--;
    });
  }

  // ==========================================================
  // REPLAY QUIZ
  // ==========================================================
  //
  // Important:
  // We DO NOT call generateQuiz().
  //
  // This means the same questions are used again.
  //
  // ==========================================================

  void replayQuiz() {
    setState(() {
      currentQuestion = 0;
      score = 0;

      // Clear all previously selected answers.
      selectedAnswers = List<int?>.filled(
        questions.length,
        null,
      );
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
            borderRadius: BorderRadius.circular(20),
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
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(0xFFFB6F92),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
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
    if (questions.isEmpty) return "Keep practicing! 💪";
    final ratio = score / questions.length;
    if (ratio == 1.0) {
      return "Excellent! 🌟";
    }

    if (ratio >= 0.6) {
      return "Good job! 👍";
    }

    return "Keep practicing! 💪";
  }

  // ==========================================================
  // OPTION COLOR
  // ==========================================================
  //
  // IMPORTANT:
  //
  // We no longer compare the selected option with
  // the correct answer here.
  //
  // This prevents revealing the correct answer
  // during the quiz.
  //
  // ==========================================================

  Color getOptionColor(int index) {
    if (selectedAnswer == index) {
      return const Color(0xFFFFE4F1);
    }

    return Colors.white;
  }

  // ==========================================================
  // BORDER COLOR
  // ==========================================================

  Color getBorderColor(int index) {
    if (selectedAnswer == index) {
      return const Color(0xFFFB6F92);
    }

    return Colors.grey.shade300;
  }

  // ==========================================================
  // OPTION ICON
  // ==========================================================
  //
  // This icon only indicates which answer the user selected.
  // It does NOT indicate whether the answer is correct.
  //
  // ==========================================================

  Widget? getOptionIcon(int index) {
    if (selectedAnswer == index) {
      return const Icon(
        Icons.radio_button_checked,
        color: Color(0xFFFB6F92),
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
            // QUESTION TYPE BADGE
            // =================================================

            Builder(
              builder: (context) {
                final String qType = (question["type"] ?? "mcq").toString();
                String badgeLabel = "Multiple Choice 💡";
                Color badgeBg = const Color(0xFFF3E5F5);
                Color badgeTextColor = const Color(0xFF7B1FA2);

                if (qType == "true_false") {
                  badgeLabel = "True or False 📝";
                  badgeBg = const Color(0xFFE0F7FA);
                  badgeTextColor = const Color(0xFF00838F);
                } else if (qType == "fill_blank") {
                  badgeLabel = "Fill in the Blank ✏️";
                  badgeBg = const Color(0xFFFFF8E1);
                  badgeTextColor = const Color(0xFFF57F17);
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: badgeBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      badgeLabel,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: badgeTextColor,
                      ),
                    ),
                  ),
                );
              },
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
            // BACK + NEXT
            // =================================================

            Row(
              children: [
                // ------------------------------------------------
                // BACK BUTTON
                // ------------------------------------------------

                if (currentQuestion > 0)
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child:
                          OutlinedButton(
                        onPressed:
                            previousQuestion,
                        style:
                            OutlinedButton
                                .styleFrom(
                          foregroundColor:
                              const Color(
                            0xFF49243E,
                          ),
                          side:
                              const BorderSide(
                            color:
                                Color(
                              0xFFFB6F92,
                            ),
                            width: 2,
                          ),
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius
                                    .circular(
                              12,
                            ),
                          ),
                        ),
                        child:
                            const Text(
                          "Back",
                          style:
                              TextStyle(
                            fontSize: 16,
                            fontWeight:
                                FontWeight
                                    .bold,
                          ),
                        ),
                      ),
                    ),
                  ),

                if (currentQuestion > 0)
                  const SizedBox(
                    width: 12,
                  ),

                // ------------------------------------------------
                // NEXT BUTTON
                // ------------------------------------------------

                Expanded(
                  child: SizedBox(
                    height: 50,
                    child:
                        ElevatedButton(
                      onPressed:
                          selectedAnswer ==
                                  null
                              ? null
                              : nextQuestion,
                      style:
                          ElevatedButton
                              .styleFrom(
                        backgroundColor:
                            const Color(
                          0xFFFB6F92,
                        ),
                        foregroundColor:
                            Colors.white,
                        disabledBackgroundColor:
                            Colors.grey
                                .shade300,
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
                              FontWeight
                                  .bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
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
      child: Container(
        constraints:
            const BoxConstraints(
          maxWidth: 520,
          maxHeight: 700,
        ),
        padding:
            const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 20,
        ),
        child: Column(
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
                color: Colors.grey,
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
            // ANSWER REVIEW
            // -------------------------------------------------

            Expanded(
              child:
                  SingleChildScrollView(
                child:
                    buildAnswerReview(),
              ),
            ),

            const SizedBox(
              height: 12,
            ),

            // -------------------------------------------------
            // REPLAY + DONE
            // -------------------------------------------------

            Row(
              children: [
                // REPLAY
                Expanded(
                  child:
                      OutlinedButton(
                    onPressed:
                        replayQuiz,
                    style:
                        OutlinedButton
                            .styleFrom(
                      foregroundColor:
                          const Color(
                        0xFF49243E,
                      ),
                      side:
                          const BorderSide(
                        color:
                            Color(
                          0xFFFB6F92,
                        ),
                        width: 2,
                      ),
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
                      "Replay",
                      style:
                          TextStyle(
                        fontWeight:
                            FontWeight
                                .bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                  width: 12,
                ),

                // DONE
                Expanded(
                  child:
                      ElevatedButton(
                    onPressed: () {
                      Navigator.pop(
                        context,
                      );
                    },
                    style:
                        ElevatedButton
                            .styleFrom(
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
                        fontWeight:
                            FontWeight
                                .bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // ANSWER REVIEW
  // ==========================================================

  Widget buildAnswerReview() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const Text(
          "Answers",
          style: TextStyle(
            fontSize: 19,
            fontWeight:
                FontWeight.bold,
            color:
                Color(0xFF49243E),
          ),
        ),

        const SizedBox(
          height: 12,
        ),

        ...List.generate(
          questions.length,
          (index) {
            final question =
                questions[index];

            final int correctAnswer =
                int.parse(
              question["answer"]
                  .toString(),
            );

            final int? userAnswer =
                selectedAnswers[index];

            final bool isCorrect =
                userAnswer ==
                    correctAnswer;

            final String userAnswerText =
                userAnswer == null
                    ? "Not answered"
                    : question["options"]
                            [userAnswer]
                        .toString();

            final String correctAnswerText =
                question["options"]
                        [correctAnswer]
                    .toString();

            return Container(
              width:
                  double.infinity,
              margin:
                  const EdgeInsets.only(
                bottom: 12,
              ),
              padding:
                  const EdgeInsets.all(
                14,
              ),
              decoration:
                  BoxDecoration(
                color:
                    Colors.grey.shade50,
                borderRadius:
                    BorderRadius
                        .circular(
                  12,
                ),
                border:
                    Border.all(
                  color:
                      Colors.grey.shade300,
                ),
              ),
              child:
                  Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  // QUESTION
                  Text(
                    "${index + 1}. ${question["question"]}",
                    style:
                        const TextStyle(
                      fontSize: 15,
                      fontWeight:
                          FontWeight
                              .bold,
                      color:
                          Color(
                        0xFF49243E,
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  // USER ANSWER
                  Text(
                    "Your answer: $userAnswerText",
                    style:
                        TextStyle(
                      fontSize: 14,
                      color: isCorrect
                          ? Colors
                              .green
                              .shade700
                          : Colors
                              .red
                              .shade700,
                    ),
                  ),

                  const SizedBox(
                    height: 4,
                  ),

                  // CORRECT ANSWER
                  Text(
                    "Correct answer: $correctAnswerText",
                    style:
                        const TextStyle(
                      fontSize: 14,
                      color:
                          Colors.green,
                      fontWeight:
                          FontWeight
                              .w600,
                    ),
                  ),

                  const SizedBox(
                    height: 6,
                  ),

                  // RESULT
                  Text(
                    isCorrect
                        ? "✓ Correct"
                        : "✗ Incorrect",
                    style:
                        TextStyle(
                      fontSize: 14,
                      fontWeight:
                          FontWeight
                              .bold,
                      color: isCorrect
                          ? Colors
                              .green
                          : Colors
                              .red,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}