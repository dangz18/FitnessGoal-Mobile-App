import 'dart:typed_data';

class AllExercises{
  int exerciseId;
  String exerciseName;
  String exerciseMuscleCategory;
  Uint8List? exerciseImage;

  AllExercises(
      this.exerciseId,
      this.exerciseName,
      this.exerciseMuscleCategory,
      this.exerciseImage,
      );
}