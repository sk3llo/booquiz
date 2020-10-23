import 'package:booquiz/models/Question.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MainBook {
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
  int likes = 0;
  int dislikes = 0;
  double rating;
  int questionsLength = 0;
  List<Question> quiz; // Questions and answers
  List<Question> completedQuiz; // Questions and answers
  Timestamp updatedAt;

  // Fields for user's book
  int timesCompleted;
  DocumentReference ref;
  Map<String, dynamic> data;

  MainBook(
      {@required this.title,
        @required this.imageUrl,
        @required this.id,
        @required this.authors,
        @required this.description,
        @required this.subtitle,
        @required this.rating,
        this.snap,
        this.categories,
        this.likes,
        this.quiz,
        this.completedQuiz,
        this.updatedAt,
        this.questionsLength,
        this.dislikes,
        this.timesCompleted,
        this.data});

  MainBook.fromSnap(DocumentSnapshot snap)
      : this(
      snap: snap,
      title: snap.data['title'],
      imageUrl: snap.data['imageUrl'],
      id: snap.data['id'],
      authors: snap.data['authors'],
      description: snap.data['description'],
      rating: snap.data['rating'],
      subtitle: snap.data['subtitle'],
      updatedAt: snap.data['updatedAt'],
      categories: snap.data['categories'],
      questionsLength: snap.data['questionsLength'] ?? 0,
      likes: snap.data['likes'] ?? 0,
      dislikes: snap.data['dislikes'] ?? 0,
      quiz: [],
      completedQuiz: [],
      timesCompleted: snap.data['timesCompleted'],
      data: snap.data);
}
