import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/network_service.dart';

part 'tasks_client.g.dart';

@RestApi(baseUrl: "/api/v1/")
abstract class TasksClient {
  factory TasksClient(Dio dio, {String baseUrl}) = _TasksClient;

  @GET("tasks")
  Future<BaseApiResponse<PaginatedData<TaskLite>>> getTasks({
    @Query("page") int page = 1,
    @Query("per_page") int perPage = 20,
    @Query("status") String? status,
    @Query("category_id") String? categoryId,
    @Query("service_id") String? serviceId,
    @Query("search") String? search,
    @Query("latitude") double? latitude,
    @Query("longitude") double? longitude,
    @Query("radius_km") double? radiusKm,
    @Query("sort_by") String? sortBy = "created_at",
    @Query("sort_desc") bool sortDesc = true,
    @Query("region_id") String? regionId,
    @Query("budget_min") double? budgetMin,
    @Query("budget_max") double? budgetMax,
    @Query("scheduled_start_at") String? scheduledStartAt,
    @Query("expires_at") String? expiresAt,
    @Query("customer_id") String? customerId,
  });

  @GET("tasks/{taskId}")
  Future<BaseApiResponse<Task>> getTask(@Path("taskId") String taskId);

  @POST("tasks/{taskId}/bids")
  Future<BaseApiResponse<TaskBid>> submitBid(
    @Path("taskId") String taskId,
    @Body() CreateBidRequest request,
  );

  @GET("tasks/{taskId}/my-bid")
  Future<BaseApiResponse<TaskBid>> getMyBidForTask(
    @Path("taskId") String taskId,
  );

  @PUT("bids/{bidId}")
  Future<BaseApiResponse<TaskBid>> updateBid(
    @Path("bidId") String bidId,
    @Body() CreateBidRequest request,
  );

  @POST("bids/{bidId}/withdraw")
  Future<BaseApiResponse<TaskBid>> withdrawBid(
    @Path("bidId") String bidId,
  );

  @POST("tasks/{taskId}/dispatch/respond")
  Future<BaseApiResponse<dynamic>> respondToDispatchPing(
    @Path("taskId") String taskId,
    @Body() DispatchRespondRequest request,
  );

  @GET("assignments/current")
  Future<BaseApiResponse<Assignment>> getCurrentAssignment();

  @GET("tasks/{taskId}/assignment")
  Future<BaseApiResponse<Assignment>> getTaskAssignment(
    @Path("taskId") String taskId,
  );

  @POST("tasks/{taskId}/start")
  Future<BaseApiResponse<dynamic>> startTask(
    @Path("taskId") String taskId,
    @Body() StartTaskRequest request,
  );

  @POST("tasks/{taskId}/complete")
  Future<BaseApiResponse<dynamic>> completeTask(
    @Path("taskId") String taskId,
    @Body() CompleteTaskRequest request,
  );
}

/// Provider exposing the [TasksClient] dependency.
final tasksClientProvider = Provider<TasksClient>((ref) {
  final dio = ref.watch(dioProvider);
  return TasksClient(dio);
});
