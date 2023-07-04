import 'dart:typed_data';

class WorkoutExercise{
  final String exerciseName;
  final String exerciseMuscleCategory;
  final Uint8List exerciseImage;
  final int exerciseRepetitions;
  final bool exerciseIsDone;
  final int workoutExerciseId;

  WorkoutExercise(
      this.exerciseName,
      this.exerciseMuscleCategory,
      this.exerciseImage,
      this.exerciseRepetitions,
      this.exerciseIsDone,
      this.workoutExerciseId,
  );
}