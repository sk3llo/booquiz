import 'package:booquiz/models/Question.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserBook {
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
  int totalTimeTaken = 0;
  // List<Question> quiz; // Questions and answers
  Timestamp updatedAt;

  // Fields for user's book
  bool completed;
  int timesCompleted;
  DocumentReference lastCompletedQuestion;
  Timestamp lastOpened;
  int questionsCompleted;
  int questionsInProgress;
  DocumentReference ref;
  Map<String, dynamic> data;

  UserBook(
      {@required this.title,
      @required this.imageUrl,
      @required this.id,
      @required this.authors,
      @required this.description,
      @required this.subtitle,
      @required this.rating,
      this.snap,
      this.categories,
      this.starred,
      this.likes,
      // this.quiz,
      this.updatedAt,
      this.questionsLength,
      this.totalTimeTaken,
      this.completed,
      this.lastCompletedQuestion,
      this.lastOpened,
      this.questionsCompleted,
      this.questionsInProgress,
      this.dislikes,
      this.timesCompleted,
      this.data});

  UserBook.fromSnap(DocumentSnapshot snap)
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
            lastCompletedQuestion: snap.data['lastCompletedQuestion'],
            lastOpened: snap.data['lastOpened'],
            questionsCompleted: snap.data['questionsCompleted'] ?? 0,
            questionsInProgress:
                snap?.data['questionsLength'] ?? 0 - snap?.data['questionsCompleted'] ?? 0,
            questionsLength: snap.data['questionsLength'] ?? 0,
            completed:
            snap.data['completed'] != null ? snap.data['completed'] :
                snap.data['questionsCompleted'] != null && snap.data['questionsLength'] != null
                    ? snap.data['questionsLength'] != 0 &&
                            snap.data['questionsCompleted'] == snap.data['questionsLength']
                        ? true
                        : false : false,
            totalTimeTaken: snap.data['totalTimeTaken'] ?? 0,
            likes: snap.data['likes'] ?? 0,
            dislikes: snap.data['dislikes'] ?? 0,
            // quiz: [],
            timesCompleted: snap.data['timesCompleted'],
            data: snap.data);

  UserBook.createEmpty() {
    // this.quiz = [];
    this.questionsInProgress = 0;
    this.questionsLength = 0;
    this.questionsCompleted = 0;
    this.completed = false;
  }
}
