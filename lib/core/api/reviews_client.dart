import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/network_service.dart';

part 'reviews_client.g.dart';

@RestApi(baseUrl: "/api/v1/")
abstract class ReviewsClient {
  factory ReviewsClient(Dio dio, {String baseUrl}) = _ReviewsClient;

  /// Submit a star rating and optional comment for a completed task.
  @POST("reviews")
  Future<BaseApiResponse<dynamic>> submitReview(
    @Body() SubmitReviewRequest request,
  );

  /// Fetch completed and paid tasks that the provider hasn't reviewed.
  @GET("reviews/pending/provider")
  Future<BaseApiResponse<PaginatedData<PendingProviderReviewItem>>>
      getPendingProviderReviews({
    @Query("page") int page = 1,
    @Query("per_page") int perPage = 20,
  });
}

/// Provider exposing the [ReviewsClient] dependency.
final reviewsClientProvider = Provider<ReviewsClient>((ref) {
  final dio = ref.watch(dioProvider);
  return ReviewsClient(dio);
});
