import 'dart:io'; // Needed for File
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/complaint_model.dart';
import '../repository/complaint_repository.dart';

// =======================================================
// STATE
// =======================================================

class ComplaintState {
  final bool isLoading;
  final List<ComplaintModel> complaints;
  final ComplaintModel? selectedComplaint;
  final String? error;
  final Map<String, int>? stats;

  const ComplaintState({
    this.isLoading = false,
    this.complaints = const [],
    this.selectedComplaint,
    this.error,
    this.stats,
  });

  ComplaintState copyWith({
    bool? isLoading,
    List<ComplaintModel>? complaints,
    ComplaintModel? selectedComplaint,
    String? error,
    Map<String, int>? stats,
  }) {
    return ComplaintState(
      isLoading: isLoading ?? this.isLoading,
      complaints: complaints ?? this.complaints,
      selectedComplaint: selectedComplaint ?? this.selectedComplaint,
      error: error,
      stats: stats ?? this.stats,
    );
  }
}

// =======================================================
// NOTIFIER
// =======================================================

class ComplaintNotifier extends StateNotifier<ComplaintState> {
  final ComplaintRepository _repository;

  ComplaintNotifier(this._repository) : super(const ComplaintState());

  // -------------------------------------------------------
  // Fetch all complaints
  // -------------------------------------------------------
  Future<void> fetchComplaints() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final complaints = await _repository.getComplaints();
      final stats = await _repository.getComplaintStats();

      state = state.copyWith(
        isLoading: false,
        complaints: complaints,
        stats: stats,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // -------------------------------------------------------
  // Fetch single complaint
  // -------------------------------------------------------
  Future<void> fetchComplaintById(String id) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final complaint = await _repository.getComplaintById(id);
      state = state.copyWith(
        isLoading: false,
        selectedComplaint: complaint,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // -------------------------------------------------------
  // ✅ FIXED: Create complaint (Now handles Location & Category)
  // -------------------------------------------------------
  Future<void> createComplaint({
    required String title,
    required String description,
    required String category,
    required String location,
    File? image,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // 1. Sanitize location (Double check before sending)
      String finalLocation = location;
      if (finalLocation.trim().isEmpty || finalLocation == "null") {
        finalLocation = "Manual Location Entry";
      }

      // 2. Pass to Repository
      await _repository.createComplaint(
        title: title,
        description: description,
        category: category,
        location: finalLocation, // <--- IMPORTANT FIX
        imageFile: image,
      );

      // 3. Refresh list instantly
      await fetchComplaints();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  // -------------------------------------------------------
  // Request OTP
  // -------------------------------------------------------
  Future<void> requestOtp(String id) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _repository.requestOtp(id);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  // -------------------------------------------------------
  // Close complaint
  // -------------------------------------------------------
  Future<void> closeComplaint(String id, String otp) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _repository.closeComplaint(id, otp);

      // Refresh data
      await fetchComplaintById(id);
      await fetchComplaints();

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  // -------------------------------------------------------
  // Appeal complaint
  // -------------------------------------------------------
  Future<void> appealComplaint(String id) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _repository.appealComplaint(id);

      await fetchComplaintById(id);
      await fetchComplaints();

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  // -------------------------------------------------------
  // Helpers
  // -------------------------------------------------------
  void clearError() {
    state = state.copyWith(error: null);
  }

  void clearSelected() {
    state = state.copyWith(selectedComplaint: null);
  }
}


// =======================================================
// PROVIDERS
// =======================================================

final complaintProvider =
StateNotifierProvider<ComplaintNotifier, ComplaintState>((ref) {
  final repository = ref.read(complaintRepositoryProvider);
  return ComplaintNotifier(repository);
});

final complaintListProvider =
FutureProvider.autoDispose<List<ComplaintModel>>((ref) async {
  final notifier = ref.read(complaintProvider.notifier);

  // Always fetch fresh data
  await notifier.fetchComplaints();

  // Return the latest state
  return ref.read(complaintProvider).complaints;
});