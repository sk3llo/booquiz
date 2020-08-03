import 'package:booquiz/models/Question.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Book {
  static final db_title = "title";
  static final db_url = "url";
  static final db_id = "id";
  static final db_star = "star";
  static final db_author = "author";
  static final db_description = "description";
  static final db_subtitle = "subtitle";

  String title, imageUrl, id, description, subtitle;

  DocumentSnapshot snap;
  List authors, categories;
  bool starred;
  int likes = 0;
  int dislikes = 0;
  double rating;
  int questionsLength = 0;
  List<Question> quiz; // Questions and answers
  Timestamp updatedAt;

  // Fields for user's book
  bool completed;
  DocumentReference lastCompletedQuestion;
  Timestamp lastOpened;
  int questionsCompleted;
  int questionsInProgress;
  DocumentReference ref;

  Book(
      {@required this.snap,
      @required this.title,
      @required this.imageUrl,
      @required this.id,
      @required this.authors,
      @required this.description,
      @required this.subtitle,
      @required this.rating,
      this.categories,
      this.starred = false,
      this.likes,
      this.quiz,
      this.updatedAt,
      this.questionsLength,
      this.completed,
      this.lastCompletedQuestion,
      this.lastOpened,
      this.questionsCompleted,
      this.questionsInProgress,
      this.ref,
      this.dislikes
      });

  Book.fromSnap(DocumentSnapshot snap)
    : this(
        snap: snap,
        title: snap.data['title'],
        imageUrl: snap.data['imageUrl'],
        id: snap.data['id'],
        authors: snap.data['authors'],
        description: snap.data['description'],
        rating: snap.data['rating'],
        subtitle: snap.data['subtitle'],
        starred: snap.data['starred'],
        updatedAt: snap.data['updatedAt'],
        categories: snap.data['categories'],
        // List<String>
        completed: snap.data['completed'],
        lastCompletedQuestion: snap.data['lastCompletedQuestion'],
        lastOpened: snap.data['lastOpened'],
        questionsCompleted: snap.data['questionsCompleted'],
        questionsInProgress: snap?.data['questionsLength'] ?? 0 - snap?.data['questionsCompleted'] ?? 0,
        questionsLength: snap.data['questionsLength'] ?? 0,
        ref: snap.data['ref'],
        likes: snap.data['likes'] ?? 0,
        dislikes: snap.data['dislikes'] ?? 0,
        quiz: []
    );
}
