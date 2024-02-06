import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'recipeDetails.dart';

class RecipesPage extends StatefulWidget {
  final List<Map<String, dynamic>> selectedIngredients;

  RecipesPage({required this.selectedIngredients});

  @override
  _RecipesPageState createState() => _RecipesPageState();
}

class _RecipesPageState extends State<RecipesPage> {
  List<Map<String, dynamic>> _recipes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRecipes();
  }

  Future<void> _fetchRecipes() async {
    final apiKey = 'd0c2009dfc854b279bf0e682b442dc6b';
    final ingredients = widget.selectedIngredients
        .map((ingredient) => ingredient['name'])
        .join(',');

    final url =
        'https://api.spoonacular.com/recipes/findByIngredients?ingredients=$ingredients&number=5&apiKey=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        _recipes = data
            .map((recipe) => {
                  'id': recipe['id'],
                  'title': recipe['title'],
                  'image': recipe['image'],
                })
            .toList();
        _isLoading = false;
      });
    } else {
      // Handle error case
      setState(() {
        _isLoading = false;
      });
      // Display an error message or take appropriate action
      print('Failed to load recipes');
    }
  }

  void _navigateToRecipeDetails(int recipeId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecipeDetails(recipeId: recipeId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recipe results'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _recipes.isEmpty
              ? Center(
                  child: Text('No recipes found.'),
                )
              : ListView.builder(
                  itemCount: _recipes.length,
                  itemBuilder: (context, index) {
                    final recipe = _recipes[index];
                    return GestureDetector(
                      onTap: () {
                        _navigateToRecipeDetails(recipe['id']);
                      },
                      child: Card(
                        elevation: 3,
                        margin: EdgeInsets.all(10),
                        color: Colors.white, // Set card color to white
                        child: Padding(
                          padding: EdgeInsets.all(10),
                          child: Row(
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.0),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0x000000).withOpacity(1),
                                      offset: Offset(6, 0),
                                      blurRadius: 7,
                                      spreadRadius: -8,
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: Image.network(
                                    recipe['image'],
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      recipe['title'],
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      'Tap to view details',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
