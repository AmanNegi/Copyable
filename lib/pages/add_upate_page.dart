import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class AddUpdatePage extends StatefulHookWidget {
  final bool edit;
  final String text;

  const AddUpdatePage({Key? key, this.edit = false, this.text = ""})
      : super(key: key);

  @override
  State<AddUpdatePage> createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddUpdatePage> {
  late TextEditingController _textEditingController;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    _textEditingController =
        useTextEditingController(text: widget.edit ? widget.text : "");

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.edit ? "Edit Item" : "Add Item"),
        elevation: 0,
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: "UnattachedTag",
        label: const Text("Save"),
        onPressed: () {
          if (_textEditingController.text.isEmpty ||
              _textEditingController.text.trim().isEmpty) {
            Navigator.pop(context);
            return;
          }
          Navigator.pop(
            context,
            {'content': _textEditingController.text},
          );
        },
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          children: [
            TextField(
              focusNode: _focusNode,
              controller: _textEditingController,
              maxLines: 999,
              decoration: const InputDecoration(
                hintText: "Enter Text Here",
                border: InputBorder.none,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
