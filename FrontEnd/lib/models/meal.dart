import 'dart:typed_data';

class Meal{
  final String mealName;
  final String mealIngredients;
  final String mealInstructions;
  final String mealCategory;
  final bool mealVegetarian;
  final double mealKcal;
  final double mealFat;
  final double mealSaturates;
  final double mealCarbs;
  final double mealSugar;
  final double mealFibre;
  final double mealProtein;
  final double mealSalt;
  Uint8List? mealImage;
  final int mealId;

  Meal(
    this.mealName,
    this.mealIngredients,
    this.mealInstructions,
    this.mealCategory,
    this.mealVegetarian,
    this.mealKcal,
    this.mealFat,
    this.mealSaturates,
    this.mealCarbs,
    this.mealSugar,
    this.mealFibre,
    this.mealProtein,
    this.mealSalt,
    this.mealImage,
    this.mealId,
  );
}