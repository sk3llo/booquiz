import 'package:cloud_firestore/cloud_firestore.dart';

class Question {
  DocumentSnapshot snap;
  DocumentReference author;
  String question, correctAnswer;
  List<String> answers, questionSearch;
  Timestamp createdAt;
  List<QuestionLike> likes; // User ID : like or not
  // Fields after question has been completed
  String answered; // User answer
  int timeTaken; // In milliseconds
  int timesCompleted;
  Timestamp completedAt;

  Question(this.question, this.questionSearch, this.correctAnswer, this.author, this.answers,
      this.createdAt,
      {this.answered, this.timeTaken, this.completedAt, this.timesCompleted});

  Question.fromSnap(DocumentSnapshot snap) {
    this.snap = snap;
    this.question = snap.data['question'];
    this.correctAnswer = snap.data['correctAnswer'];
    this.author = snap.data['author'];
    this.answers = List.from(snap.data['answers']);
    this.questionSearch = List.from(snap.data['questionSearch']);
    this.createdAt = snap.data['createdAt'];
    this.likes = []; // have to get manually from Collection under this doc
    // Fields after question has been completed
    this.answered = snap.data['answered'];
    this.timeTaken = snap.data['timeTaken'];
    this.completedAt = snap.data['completedAt'];
    this.timesCompleted = snap.data['timesCompleted'];
  }
}

class QuestionLike {
  DocumentSnapshot snap;
  bool liked;
  DocumentReference likedBy;
  Timestamp updatedAt;

  QuestionLike(this.liked, this.likedBy, this.updatedAt);

  QuestionLike.fromSnap(DocumentSnapshot snap) {
    this.snap = snap;
    this.liked = snap.data['likedBy'];
    this.likedBy = snap.data['likedBy'];
    this.updatedAt = snap.data['updatedAt'];
  }
}
