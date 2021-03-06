import 'package:flutter/material.dart';
import 'package:note2/sql_helper.dart';
import 'package:intl/intl.dart';

class Second extends StatefulWidget {
  const Second({Key? key, required this.index, required this.func})
      : super(key: key);

  final int index;
  final Function func;

  @override
  State<Second> createState() => SecondState();
}

class SecondState extends State<Second> {

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  List<Map<String,dynamic>> notes = [];

  void refreshNotes() async {

    final data = await SQLHelper.getItems();

    setState(() {
      notes = data ;
    });

  }

  void initState(){
    super.initState();
    refreshNotes();
  }

  void funct(){
    final Function fun = widget.func ;
    fun() ;
  }

  String getdate(int index){
    if(index==-1){
      return DateFormat.yMd().format(DateTime.now());
    }
    else{
      return notes[widget.index]['date'];
    }
  }

  Future<void> addItem() async {
    await SQLHelper.createItem(titleController.text, descriptionController.text);
    refreshNotes();
    funct() ;
  }

  // Update an existing Note
  Future<void> updateItem(int id) async {
    await SQLHelper.updateItem(id, titleController.text, descriptionController.text);
    refreshNotes();
    funct() ;
  }

  // Delete an item
  Future<void> deleteItem(int id) async {
    await SQLHelper.deleteItem(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Successfully deleted a Note'),
    ));
    refreshNotes();
    funct() ;
  }

  @override
  Widget build(BuildContext context) {

    if(widget.index>=0) {
      titleController.text = notes[widget.index]['title'];
      descriptionController.text = notes[widget.index]['description'];
    }

    return Scaffold(

      appBar: AppBar(
        title: const Text('Notes App', style: TextStyle(color: Colors.white70),),
        actions: <Widget>[
          IconButton(onPressed: () async{
            if(widget.index==-1){
              Navigator.pop(context);
            }
            else {
              int id = notes[widget.index]['id'];
              await deleteItem(id); Navigator.pop(context);
            }
          },
              icon: Icon(Icons.delete)),

          IconButton(onPressed: () async{
            if(widget.index==-1){
              await addItem();
              Navigator.pop(context);
            }
            else {
              int id = notes[widget.index]['id'];
              await updateItem(id);
            }
          },
              icon: Icon(Icons.save)),

        ],
      ),

      backgroundColor: Colors.orange[100],
      body: ListView(
        children: [

          Container(
            width: double.infinity,
            margin: EdgeInsets.all(10),
            child: Text(
            getdate(widget.index),
            textAlign: TextAlign.end,
          ),
          ),

          Container(
            margin: EdgeInsets.all(10),

            child: TextField(
              controller: titleController,
              decoration: const InputDecoration(hintText: 'Title'),
            ),
          ),
          const SizedBox(
            height: 50,
          ),
          Container(
            margin: EdgeInsets.all(10),
            decoration: BoxDecoration(border: Border.all(width: 1)),
            constraints: BoxConstraints(maxHeight: 500),

            child: TextField(
              controller: descriptionController,
              decoration: const InputDecoration(hintText: 'Description'),
              keyboardType: TextInputType.multiline,
              maxLines: null,
            ),
          ),
        ],
      ),

    );
  }
}
