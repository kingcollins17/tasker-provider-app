import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/network_service.dart';

part 'services_client.g.dart';

@RestApi(baseUrl: "/api/v1/")
abstract class ServicesClient {
  factory ServicesClient(Dio dio, {String baseUrl}) = _ServicesClient;

  @GET("categories")
  Future<BaseApiResponse<PaginatedData<Category>>> getCategories({
    @Query("page") int page = 1,
    @Query("per_page") int perPage = 20,
    @Query("search") String? search,
    @Query("is_active") bool? isActive,
    @Query("sort_by") String? sortBy = "created_at",
    @Query("sort_desc") bool sortDesc = true,
  });

  @GET("categories/{category_id}")
  Future<BaseApiResponse<Category>> getCategory(
    @Path("category_id") String categoryId,
  );

  @GET("services")
  Future<BaseApiResponse<PaginatedData<Service>>> getServices({
    @Query("page") int page = 1,
    @Query("per_page") int perPage = 20,
    @Query("search") String? search,
    @Query("category_id") String? categoryId,
    @Query("is_active") bool? isActive,
    @Query("sort_by") String? sortBy = "created_at",
    @Query("sort_desc") bool sortDesc = true,
  });

  @GET("services/{service_id}")
  Future<BaseApiResponse<Service>> getService(
    @Path("service_id") String serviceId,
  );
}

/// Provider exposing the [ServicesClient] dependency.
final servicesClientProvider = Provider<ServicesClient>((ref) {
  final dio = ref.watch(dioProvider);
  return ServicesClient(dio);
});
