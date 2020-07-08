import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Book {
  static final db_title = "title";
  static final db_url = "url";
  static final db_id = "id";
  static final db_notes = "notes";
  static final db_star = "star";
  static final db_author = "author";
  static final db_description = "description";
  static final db_subtitle = "subtitle";

  String title, imageUrl, id, notes, description, subtitle;

  //First author
  List authors, categories;
  bool starred;
  int likes = 0;
  Map<String, List<String>> quiz; // Questions and answers
  Timestamp updatedAt;

  Book({
    @required this.title,
    @required this.imageUrl,
    @required this.id,
    @required this.authors,
    @required this.description,
    @required this.subtitle,
    this.categories,
    this.starred = false,
    this.notes = "",
    this.likes,
    this.quiz,
    this.updatedAt
  });

  Book.fromMap(Map<String, dynamic> map) : this(
    title: map[db_title],
    imageUrl: map[db_url],
    id: map[db_id],
    starred: map[db_star] == 1,
    notes: map[db_notes],
    description: map[db_description],
    authors: map[db_author],
    subtitle: map[db_subtitle],
  );

}