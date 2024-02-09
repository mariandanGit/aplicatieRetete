import 'dart:async';
import 'dart:convert';
import 'package:aplicatie_retete/pages/recipeDetails.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:aplicatie_retete/pages/recipes.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  late List<Map<String, dynamic>> _suggestions;
  List<Map<String, dynamic>> _selectedItems = [];
  List<Map<String, dynamic>> _randomRecipes = [];

  @override
  void initState() {
    super.initState();
    _suggestions = [];
    _fetchRandomRecipes();
  }

  Future<void> _fetchRandomRecipes() async {
    final apiKey = 'd0c2009dfc854b279bf0e682b442dc6b';
    final url =
        'https://api.spoonacular.com/recipes/random?number=6&apiKey=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['recipes'];
      setState(() {
        _randomRecipes = data
            .map((item) => {
                  'id': item['id'],
                  'title': item['title'],
                  'image': item['image'],
                })
            .toList();
      });
    } else {
      throw Exception('Failed to load random recipes');
    }
  }

  Future<List<Map<String, dynamic>>> _fetchSuggestions(String query) async {
    final apiKey = 'd0c2009dfc854b279bf0e682b442dc6b';
    final url =
        'https://api.spoonacular.com/food/ingredients/autocomplete?query=$query&number=5&apiKey=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data
          .map((item) => {
                'name': item['name'],
                'image':
                    'https://spoonacular.com/cdn/ingredients_100x100/${item['image']}',
              })
          .toList();
    } else {
      throw Exception('Failed to load suggestions');
    }
  }

  void _onSuggestionSelected(Map<String, dynamic> suggestion) {
    _controller.clear(); // Se șterge conținutul câmpului de căutare
    String selectedIngredientName = suggestion['name'];
    bool alreadySelected =
        _selectedItems.any((item) => item['name'] == selectedIngredientName);
    if (!alreadySelected) {
      setState(() {
        _selectedItems.add(suggestion);
      });
    }
  }

  void _onDeleteItem(Map<String, dynamic> selectedItem) {
    setState(() {
      _selectedItems.remove(selectedItem);
    });
  }

  void _onSubmitIngredients() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecipesPage(selectedIngredients: _selectedItems),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
            children: [
              TextSpan(
                text: 'Cook recipes',
                style: TextStyle(color: Colors.red),
              ),
              TextSpan(
                text: ' from ingredients you have at home!',
                style: TextStyle(color: Colors.black),
              ),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25.0),
                color: Colors.grey[200],
              ),
              padding: EdgeInsets.fromLTRB(16, 0, 3, 0),
              child: Row(
                children: [
                  Expanded(
                    child: TypeAheadField(
                      textFieldConfiguration: TextFieldConfiguration(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: 'Search ingredients',
                          border: InputBorder.none,
                        ),
                      ),
                      suggestionsCallback: (pattern) async {
                        await Future.delayed(const Duration(milliseconds: 500));
                        return await _fetchSuggestions(pattern);
                      },
                      itemBuilder: (context, suggestion) {
                        return ListTile(
                          title: Text(suggestion['name']),
                        );
                      },
                      onSuggestionSelected: (suggestion) {
                        _onSuggestionSelected(suggestion);
                      },
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[800],
                    ),
                    padding: EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.search,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10.0),
            if (_selectedItems.isNotEmpty)
              Container(
                margin: EdgeInsets.only(bottom: 10.0),
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _selectedItems.clear();
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.grey[800],
                    onPrimary: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                  ),
                  icon: Icon(Icons.refresh),
                  label: Text('Clear all'),
                ),
              ),
            Container(
              width: double.infinity,
              height: _selectedItems.isEmpty ? null : 100,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: _selectedItems.map((selectedItem) {
                    return Container(
                      margin: EdgeInsets.fromLTRB(0, 5, 5, 5),
                      child: ElevatedButton(
                        onPressed: () {
                          _onDeleteItem(selectedItem);
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.grey[800],
                          onPrimary: Colors.white,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(selectedItem['name']),
                            SizedBox(width: 10.0),
                            Icon(Icons.clear),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            SizedBox(height: 10.0),
            Container(
              width: double.infinity,
              child: Text(
                'Popular Recipe Recommendations',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 10.0),
            Expanded(
              child: Container(
                width: double.infinity,
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                  shrinkWrap: true,
                  physics: AlwaysScrollableScrollPhysics(),
                  children: _randomRecipes.map((recipe) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                RecipeDetails(recipeId: recipe['id']),
                          ),
                        );
                      },
                      child: Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(15.0),
                              child: Image.network(
                                recipe['image'],
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withOpacity(0.1),
                                      Colors.black.withOpacity(0.2),
                                      Colors.black.withOpacity(0.6),
                                      Colors.black.withOpacity(0.8),
                                    ],
                                    stops: [0.0, 0.2, 0.5, 0.8, 1.0],
                                  ),
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(15.0),
                                    bottomRight: Radius.circular(15.0),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  recipe['title'],
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            SizedBox(height: 10.0),
            Center(
              child: Container(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      _selectedItems.isNotEmpty ? _onSubmitIngredients : null,
                  style: ElevatedButton.styleFrom(
                    primary: Colors.red,
                    onPrimary: Colors.white,
                    minimumSize: Size(double.infinity, 50.0),
                  ),
                  child: Text('Search recipes'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
