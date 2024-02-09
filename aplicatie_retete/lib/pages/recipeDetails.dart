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
      setState(() {
        _isLoading = false;
      });
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
      print('Failed to load recipe instructions');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // Extinde bara de navigare sub imagine
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Face bara de navigare transparentă
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white, // Setează culoarea săgeții de navigare la alb
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator()) // Indicator de încărcare dacă se încarcă datele
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 400,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(_recipeDetails['image']),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
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
