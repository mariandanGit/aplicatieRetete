import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class RecipeDetails extends StatefulWidget {
  final int recipeId;

  RecipeDetails({required this.recipeId});

  @override
  _RecipeDetailsState createState() => _RecipeDetailsState();
}

class _RecipeDetailsState extends State<RecipeDetails> {
  late Map<String, dynamic> _recipeDetails;
  late List<dynamic> _ingredients;
  late List<dynamic> _directions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRecipeDetails();
  }

  Future<void> _fetchRecipeDetails() async {
    final apiKey = 'd0c2009dfc854b279bf0e682b442dc6b';
    final url =
        'https://api.spoonacular.com/recipes/${widget.recipeId}/information?includeNutrition=false&apiKey=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      setState(() {
        _recipeDetails = data;
        _ingredients = data['extendedIngredients'];
        _isLoading = false;
      });
      _fetchInstructions();
    } else {
      // Handle error case
      setState(() {
        _isLoading = false;
      });
      // Display an error message or take appropriate action
      print('Failed to load recipe details');
    }
  }

  Future<void> _fetchInstructions() async {
    final apiKey = 'd0c2009dfc854b279bf0e682b442dc6b';
    final url =
        'https://api.spoonacular.com/recipes/${widget.recipeId}/analyzedInstructions?apiKey=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        _directions = data.isNotEmpty ? data[0]['steps'] : [];
      });
    } else {
      // Handle error case
      print('Failed to load recipe instructions');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // Make body go behind app bar
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Make app bar transparent
        elevation: 0, // Remove app bar elevation
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white, // Change the back button color to grey
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image container with fading effect
                  Container(
                    height: 400,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(_recipeDetails['image']),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // Recipe details container
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(30),
                      ),
                    ),
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _recipeDetails['title'],
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Servings: ${_recipeDetails['servings']}',
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          'Ready in: ${_recipeDetails['readyInMinutes']} minutes',
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                        SizedBox(height: 16),
                        // Ingredients container
                        Text(
                          'Ingredients:',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: _ingredients.map((ingredient) {
                            return Text(
                              '- ${ingredient['original']}',
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            );
                          }).toList(),
                        ),
                        SizedBox(height: 16),
                        // Directions container
                        Text(
                          'Directions:',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: _directions.map((step) {
                            return Text(
                              '${step['number']}. ${step['step']}',
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            );
                          }).toList(),
                        ),
                        SizedBox(height: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
