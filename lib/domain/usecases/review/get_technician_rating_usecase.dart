// lib/domain/usecases/review/get_technician_rating_usecase.dart
import '../../repositories/review_repository.dart';

class GetTechnicianRatingUseCase {
  final ReviewRepository repository;

  GetTechnicianRatingUseCase(this.repository);

  Future<double> call(String technicianId) async {
    return await repository.getTechnicianRating(technicianId);
  }
}