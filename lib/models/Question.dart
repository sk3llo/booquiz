import 'package:cloud_firestore/cloud_firestore.dart';

class Question {
  DocumentSnapshot snap;
  DocumentReference author;
  String question, correctAnswer;
  List<String> answers, questionSearch;
  Timestamp createdAt;
  List<QuestionLike> likes; // User ID : like or not


  Question(this.question, this.questionSearch, this.correctAnswer, this.author, this.answers, this.createdAt);

  Question.fromSnap(DocumentSnapshot snap) {
      this.snap = snap;
      this.question = snap.data['question'];
      this.correctAnswer = snap.data['correctAnswer'];
      this.author = snap.data['author'];
      this.answers = snap.data['answers'];
      this.createdAt = snap.data['createdAt'];
      this.questionSearch  = snap.data['questionSearch'];
      this.likes = []; // have to get manually from Collection under this doc
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