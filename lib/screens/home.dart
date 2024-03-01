import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notes_app/constants/colors.dart';
import 'package:notes_app/screens/edit.dart';
import '../models/note.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Note> filteredNotes = [];
  bool sorted = false;

  @override
  void initState() {
    super.initState();
    filteredNotes = sampleNotes;
  }

  getRandomColor() {
    Random random = Random();
    return backgroundColors[random.nextInt(backgroundColors.length)];
  }

  List<Note> sortNotesByModifiedTime(List<Note> notes) {
    if (sorted) {
      notes.sort((a, b) => a.modifiedTime.compareTo(b.modifiedTime));
    } else {
      notes.sort((b, a) => a.modifiedTime.compareTo(b.modifiedTime));
    }

    sorted = !sorted;

    return notes;
  }

  void deleteNote(int index) {
    setState(() {
      filteredNotes.removeAt(index);
    });
  }

  void onSearchTextChanged(String searchText) {
    setState(() {
      filteredNotes = sampleNotes
          .where((note) =>
              note.content.toLowerCase().contains(searchText.toLowerCase()) ||
              note.title.toLowerCase().contains(searchText.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey.shade900,
        body: Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Notes',
                      style: TextStyle(fontSize: 28, color: Colors.white)),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        filteredNotes = sortNotesByModifiedTime(filteredNotes);
                      });
                    },
                    padding: const EdgeInsets.all(0),
                    icon: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade800.withOpacity(.8),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.sort, color: Colors.white),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 20),
              TextField(
                onChanged: onSearchTextChanged,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  hintText: "Search notes ...",
                  hintStyle: const TextStyle(color: Colors.grey),
                  fillColor: Colors.grey.shade800,
                  filled: true,
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(color: Colors.transparent),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(color: Colors.transparent),
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Colors.grey,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: filteredNotes.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Card(
                      color: getRandomColor(),
                      elevation: 3,
                      margin: const EdgeInsets.only(bottom: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: ListTile(
                          title: RichText(
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            text: TextSpan(
                                text: '${filteredNotes[index].title} \n',
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    height: 1.5),
                                children: [
                                  TextSpan(
                                      text: filteredNotes[index].content,
                                      style: const TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.normal,
                                          fontSize: 14,
                                          height: 1.5))
                                ]),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              'Edited: ${DateFormat('EEE MMM d, yyy h:mm a').format(sampleNotes[index].modifiedTime)}',
                              style: TextStyle(
                                fontSize: 10,
                                fontStyle: FontStyle.italic,
                                color: Colors.grey.shade800,
                              ),
                            ),
                          ),
                          trailing: IconButton(
                            onPressed: () async {
                              final result = await confirmDialog(context);
                              if (result != null && result) {
                                deleteNote(index);
                              }
                            },
                            icon: const Icon(Icons.delete),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              )
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => const EditScreen(),
              ),
            );

            if (result != null) {
              setState(() {
                sampleNotes.add(Note(
                    id: sampleNotes.length,
                    title: result[0],
                    content: result[1],
                    modifiedTime: DateTime.now()));
                filteredNotes = sampleNotes;
              });
            }
          },
          elevation: 10,
          backgroundColor: Colors.grey.shade800,
          child: Icon(
            color: Colors.grey.shade300,
            Icons.add,
            size: 38,
          ),
        ),
      ),
    );
  }

  Future<dynamic> confirmDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey.shade900,
          icon: const Icon(
            Icons.info,
            color: Colors.grey,
          ),
          title: const Text(
            'Are you sure you want to delete?',
            style: TextStyle(color: Colors.white),
          ),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, true);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const SizedBox(
                  width: 60,
                  child: Text(
                    'Yes',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, false);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const SizedBox(
                  width: 60,
                  child: Text(
                    'No',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
