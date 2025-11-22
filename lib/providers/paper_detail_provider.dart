import 'package:flutter/foundation.dart';
import '../models/paper_detail.dart';
import '../models/paper_detail_new.dart';
import '../services/api_service.dart';

class PaperDetailProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  PaperDetail? _paperDetail;
  PaperDetailFull? _paperDetailFull;
  bool _isLoading = false;
  String? _error;

  PaperDetail? get paperDetail => _paperDetail;
  PaperDetailFull? get paperDetailFull => _paperDetailFull;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadPaperDetail(int paperId) async {
    print('📱 [PaperDetailProvider] Loading paper detail for ID: $paperId');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _paperDetail = await _apiService.getPaperDetail(paperId);
      print('📱 [PaperDetailProvider] Paper detail loaded: ${_paperDetail?.title}');
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('❌ [PaperDetailProvider] Error loading paper detail: $e');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadPaperDetailFull(int paperId) async {
    print('📱 [PaperDetailProvider] Loading full paper detail for ID: $paperId');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _paperDetailFull = await _apiService.getPaperDetailFull(paperId);
      print('📱 [PaperDetailProvider] Full paper detail loaded: ${_paperDetailFull?.title}');
      print('   Authors: ${_paperDetailFull?.authors.length}');
      print('   Assignments: ${_paperDetailFull?.assignments.length}');
      print('   Reviews: ${_paperDetailFull?.reviews.length}');
      print('   Can edit: ${_paperDetailFull?.canEdit}');
      print('   Can withdraw: ${_paperDetailFull?.canWithdraw}');
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('❌ [PaperDetailProvider] Error loading full paper detail: $e');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updatePaper({
    required int paperId,
    required String title,
    required String abstract,
    required String keywords,
    required int conferenceId,
    int? trackId,
  }) async {
    print('📱 [PaperDetailProvider] Updating paper $paperId');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _apiService.updatePaperNew(
        paperId,
        title: title,
        abstract: abstract,
        keywords: keywords,
        conferenceId: conferenceId,
        trackId: trackId,
      );
      print('✅ [PaperDetailProvider] Paper updated successfully');
      
      // Reload detail after update
      await loadPaperDetailFull(paperId);
    } catch (e) {
      print('❌ [PaperDetailProvider] Error updating paper: $e');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> withdrawPaper(int paperId, {String? reason}) async {
    print('📱 [PaperDetailProvider] Withdrawing paper $paperId');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _apiService.withdrawPaperNew(paperId, reason: reason);
      print('✅ [PaperDetailProvider] Paper withdrawn successfully');
      
      // Reload detail after withdraw
      await loadPaperDetailFull(paperId);
    } catch (e) {
      print('❌ [PaperDetailProvider] Error withdrawing paper: $e');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  void clear() {
    _paperDetail = null;
    _paperDetailFull = null;
    _error = null;
    notifyListeners();
  }
}
