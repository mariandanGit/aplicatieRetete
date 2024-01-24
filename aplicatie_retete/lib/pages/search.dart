import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<String> selectedIngredients = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          // Autocomplete widget for ingredient search
          Container(
            margin: EdgeInsets.only(left: 20, right: 20),
            child: AutocompleteFromApi(
              onIngredientSelected: (String ingredient) {
                setState(() {
                  selectedIngredients.add(ingredient);
                });
              },
            ),
          ),
          // Display selected ingredients as styled buttons
          Column(children: [
            Container(
              height: 500,
              child: ListView(
                scrollDirection: Axis.vertical,
                children: List.generate(selectedIngredients.length, (index) {
                  return generateIngredientListItem(
                    buttonText: selectedIngredients[index],
                    onXPressed: () {
                      setState(() {
                        selectedIngredients.removeAt(index);
                      });
                    },
                    onPressed: () {
                      setState(() {});
                    },
                  );
                }),
              ),
            )
          ])
        ],
      ),
    );
  }

  // Generate styled button widget
  Widget generateIngredientListItem({
    required String buttonText,
    required VoidCallback onPressed,
    required VoidCallback onXPressed,
  }) {
    return Container(
      child: Container(
        margin: EdgeInsets.only(bottom: 6),
        height: 100,
        decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(
            color: Colors.grey.shade200, // You can set the color of the border
            width: 2.0, // You can set the width of the border
          )),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(
              buttonText,
              style: TextStyle(color: Colors.black),
            ),
            IconButton(
              icon: Icon(Icons.clear),
              onPressed: onXPressed,
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }
}

class AutocompleteFromApi extends StatelessWidget {
  static const List<String> options = <String>[
    'egg',
    'flour',
    'pasta',
    'tomato paste'
  ];

  final Function(String) onIngredientSelected;

  AutocompleteFromApi({required this.onIngredientSelected});

  @override
  Widget build(BuildContext context) {
    return Autocomplete<String>(
      // Options for autocomplete search
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text == '') {
          return const Iterable<String>.empty();
        }
        return options.where((String option) {
          return option.contains(textEditingValue.text.toLowerCase());
        });
      },
      // Callback when an option is selected
      onSelected: (String selection) {
        onIngredientSelected(selection);
      },
      // Text field for user input
      fieldViewBuilder: (BuildContext context, textEditingController,
          FocusNode focusNode, VoidCallback onFieldSubmitted) {
        return TextField(
          controller: textEditingController,
          focusNode: focusNode,
          decoration: InputDecoration(
            hintText: 'Search to add ingredients',
            filled: true, // Set to true to enable background color
            fillColor: Colors.grey[200], // Set the background color
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.all(15),
            prefixIcon: Icon(Icons.search),
            suffixIcon: IconButton(
              icon: Icon(Icons.clear),
              onPressed: () {
                textEditingController.clear();
              },
            ),
          ),
          onChanged: (String value) {
            // You can perform additional actions on text change if needed
          },
        );
      },
    );
  }
}
