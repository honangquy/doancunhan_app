<?php

namespace App\Http\Controllers\Api\Mobile;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Validator;

/**
 * ========================================
 * REVIEWER MOBILE API CONTROLLER
 * ========================================
 * 
 * Copy file này vào: app/Http/Controllers/Api/Mobile/ReviewerMobileController.php
 * 
 * Sau đó thêm routes vào routes/api.php (xem file BACKEND_REVIEWER_MOBILE_ROUTES.php)
 */

class ReviewerMobileController extends Controller
{
    /**
     * 1. GET /api/mobile/reviewer/dashboard
     * Lấy thống kê tổng quan cho reviewer
     */
    public function dashboard(Request $request)
    {
        try {
            $user = Auth::user();
            
            // Get assignment stats
            $assignmentStats = DB::table('phancongphanbien as pcp')
                ->where('pcp.reviewer_id', $user->user_id)
                ->select(
                    DB::raw('COUNT(*) as total'),
                    DB::raw('SUM(CASE WHEN pcp.status = "PENDING" THEN 1 ELSE 0 END) as pending'),
                    DB::raw('SUM(CASE WHEN pcp.status = "ACCEPTED" THEN 1 ELSE 0 END) as accepted'),
                    DB::raw('SUM(CASE WHEN pcp.status = "COMPLETED" THEN 1 ELSE 0 END) as completed'),
                    DB::raw('SUM(CASE WHEN pcp.status = "DECLINED" THEN 1 ELSE 0 END) as declined')
                )
                ->first();

            // Get review stats
            $reviewStats = DB::table('phanbien as pb')
                ->where('pb.reviewer_id', $user->user_id)
                ->whereNotNull('pb.submitted_at')
                ->select(
                    DB::raw('COUNT(*) as total'),
                    DB::raw('AVG((pb.score_novelty + pb.score_relevance + pb.score_technical_quality + pb.score_presentation + pb.score_references) / 5.0) as average_score'),
                    DB::raw('SUM(CASE WHEN pb.recommendation_code IN ("ACCEPT", "MINOR_REVISION") THEN 1 ELSE 0 END) as accept'),
                    DB::raw('SUM(CASE WHEN pb.recommendation_code IN ("REJECT", "MAJOR_REVISION") THEN 1 ELSE 0 END) as reject'),
                    DB::raw('SUM(CASE WHEN pb.is_draft = 1 THEN 1 ELSE 0 END) as drafts')
                )
                ->first();

            // Get recent assignments (top 5)
            $recentAssignments = DB::table('phancongphanbien as pcp')
                ->join('baibao as b', 'pcp.paper_id', '=', 'b.paper_id')
                ->join('hoithao as ht', 'b.conference_id', '=', 'ht.conference_id')
                ->where('pcp.reviewer_id', $user->user_id)
                ->select(
                    'pcp.assignment_id as id',
                    'pcp.status',
                    'pcp.assigned_at',
                    'b.title as paper_title',
                    'ht.name as conference_name'
                )
                ->orderBy('pcp.assigned_at', 'desc')
                ->limit(5)
                ->get();

            return response()->json([
                'success' => true,
                'data' => [
                    'stats' => [
                        'assignments' => [
                            'total' => (int)$assignmentStats->total,
                            'pending' => (int)$assignmentStats->pending,
                            'accepted' => (int)$assignmentStats->accepted,
                            'completed' => (int)$assignmentStats->completed,
                            'declined' => (int)$assignmentStats->declined,
                        ],
                        'reviews' => [
                            'total' => (int)$reviewStats->total,
                            'drafts' => (int)$reviewStats->drafts,
                            'average_score' => round((float)$reviewStats->average_score, 2),
                        ],
                    ],
                    'recent_assignments' => $recentAssignments,
                ]
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Lỗi khi tải dashboard: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * 2. GET /api/mobile/reviewer/assignments
     * Lấy danh sách phân công (có filter theo status)
     */
    public function getAssignments(Request $request)
    {
        try {
            $user = Auth::user();
            $status = $request->query('status'); // PENDING, ACCEPTED, COMPLETED, DECLINED

            $query = DB::table('phancongphanbien as pcp')
                ->join('baibao as b', 'pcp.paper_id', '=', 'b.paper_id')
                ->join('hoithao as ht', 'b.conference_id', '=', 'ht.conference_id')
                ->join('nguoidung as author', 'b.user_id', '=', 'author.user_id')
                ->leftJoin('nguoidung as assigner', 'pcp.assigned_by', '=', 'assigner.user_id')
                ->where('pcp.reviewer_id', $user->user_id);

            if ($status) {
                $query->where('pcp.status', $status);
            }

            $assignments = $query->select(
                    'pcp.assignment_id as id',
                    'pcp.paper_id',
                    'pcp.status',
                    'pcp.assigned_at',
                    'pcp.response_at',
                    'pcp.deadline',
                    'b.title as paper_title',
                    'b.abstract as paper_abstract',
                    'b.keywords',
                    'b.file_path',
                    'b.status as paper_status',
                    'ht.conference_id',
                    'ht.name as conference_name',
                    'assigner.full_name as assigned_by_name',
                    'author.full_name as author_name',
                    'author.email as author_email'
                )
                ->orderBy('pcp.assigned_at', 'desc')
                ->get();

            // Get stats
            $allAssignments = DB::table('phancongphanbien')
                ->where('reviewer_id', $user->user_id)
                ->select(
                    DB::raw('COUNT(*) as total'),
                    DB::raw('SUM(CASE WHEN status = "PENDING" THEN 1 ELSE 0 END) as pending'),
                    DB::raw('SUM(CASE WHEN status = "ACCEPTED" THEN 1 ELSE 0 END) as accepted'),
                    DB::raw('SUM(CASE WHEN status = "COMPLETED" THEN 1 ELSE 0 END) as completed'),
                    DB::raw('SUM(CASE WHEN status = "DECLINED" THEN 1 ELSE 0 END) as declined')
                )
                ->first();

            return response()->json([
                'success' => true,
                'data' => [
                    'assignments' => $assignments,
                    'stats' => [
                        'total' => (int)$allAssignments->total,
                        'pending' => (int)$allAssignments->pending,
                        'accepted' => (int)$allAssignments->accepted,
                        'completed' => (int)$allAssignments->completed,
                        'declined' => (int)$allAssignments->declined,
                    ]
                ]
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Lỗi khi tải danh sách phân công: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * 3. GET /api/mobile/reviewer/assignments/{id}
     * Lấy chi tiết phân công
     */
    public function getAssignmentDetail(Request $request, $id)
    {
        try {
            $user = Auth::user();

            // Get assignment detail
            $assignment = DB::table('phancongphanbien as pcp')
                ->join('baibao as b', 'pcp.paper_id', '=', 'b.paper_id')
                ->join('hoithao as ht', 'b.conference_id', '=', 'ht.conference_id')
                ->join('nguoidung as author', 'b.user_id', '=', 'author.user_id')
                ->leftJoin('nguoidung as assigner', 'pcp.assigned_by', '=', 'assigner.user_id')
                ->where('pcp.assignment_id', $id)
                ->where('pcp.reviewer_id', $user->user_id)
                ->select(
                    'pcp.assignment_id as id',
                    'pcp.paper_id',
                    'pcp.status',
                    'pcp.assigned_at',
                    'pcp.response_at',
                    'pcp.deadline',
                    'b.title as paper_title',
                    'b.abstract as paper_abstract',
                    'b.keywords',
                    'b.file_path as paper_file',
                    'b.status as paper_status',
                    'ht.conference_id',
                    'ht.name as conference_name',
                    'assigner.full_name as assigned_by_name',
                    'author.full_name as author_name',
                    'author.email as author_email',
                    'author.organization as author_organization'
                )
                ->first();

            if (!$assignment) {
                return response()->json([
                    'success' => false,
                    'message' => 'Không tìm thấy phân công'
                ], 404);
            }

            // Get paper versions (if any)
            $versions = DB::table('paper_versions')
                ->where('paper_id', $assignment->paper_id)
                ->select('version_id', 'paper_id', 'version_no', 'file_path', 'submitted_at', 'note')
                ->orderBy('version_no', 'asc')
                ->get();

            // Get all authors
            $authors = DB::table('tacgia as tg')
                ->join('nguoidung as ng', 'tg.user_id', '=', 'ng.user_id')
                ->where('tg.paper_id', $assignment->paper_id)
                ->select(
                    'tg.author_order',
                    'tg.is_contact',
                    'ng.organization',
                    'ng.full_name',
                    'ng.email'
                )
                ->orderBy('tg.author_order', 'asc')
                ->get();

            // Get existing review (if any)
            $existingReview = DB::table('phanbien')
                ->where('assignment_id', $id)
                ->where('reviewer_id', $user->user_id)
                ->select(
                    'review_id',
                    'assignment_id',
                    'score_novelty',
                    'score_relevance',
                    'score_technical_quality',
                    'score_presentation',
                    'score_references',
                    DB::raw('(score_novelty + score_relevance + score_technical_quality + score_presentation + score_references) / 5.0 as total_score'),
                    'detailed_comments',
                    'recommendation_code',
                    'is_draft',
                    'submitted_at'
                )
                ->first();

            return response()->json([
                'success' => true,
                'data' => [
                    'assignment' => $assignment,
                    'versions' => $versions,
                    'authors' => $authors,
                    'existing_review' => $existingReview,
                ]
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Lỗi khi tải chi tiết phân công: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * 4. POST /api/mobile/reviewer/assignments/{id}/accept
     * Chấp nhận phân công
     */
    public function acceptAssignment(Request $request, $id)
    {
        try {
            $user = Auth::user();

            $assignment = DB::table('phancongphanbien')
                ->where('assignment_id', $id)
                ->where('reviewer_id', $user->user_id)
                ->where('status', 'PENDING')
                ->first();

            if (!$assignment) {
                return response()->json([
                    'success' => false,
                    'message' => 'Assignment not found or already processed'
                ], 404);
            }

            DB::table('phancongphanbien')
                ->where('assignment_id', $id)
                ->update([
                    'status' => 'ACCEPTED',
                    'response_at' => now(),
                ]);

            return response()->json([
                'success' => true,
                'message' => 'Assignment accepted successfully',
                'data' => [
                    'assignment_id' => (int)$id,
                    'status' => 'ACCEPTED'
                ]
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Lỗi khi chấp nhận phân công: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * 5. POST /api/mobile/reviewer/assignments/{id}/decline
     * Từ chối phân công
     */
    public function declineAssignment(Request $request, $id)
    {
        try {
            $validator = Validator::make($request->all(), [
                'reason' => 'required|string|min:10'
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Validation failed',
                    'errors' => $validator->errors()
                ], 422);
            }

            $user = Auth::user();

            $assignment = DB::table('phancongphanbien')
                ->where('assignment_id', $id)
                ->where('reviewer_id', $user->user_id)
                ->where('status', 'PENDING')
                ->first();

            if (!$assignment) {
                return response()->json([
                    'success' => false,
                    'message' => 'Assignment not found or already processed'
                ], 404);
            }

            DB::table('phancongphanbien')
                ->where('assignment_id', $id)
                ->update([
                    'status' => 'DECLINED',
                    'response_at' => now(),
                    'decline_reason' => $request->input('reason'),
                ]);

            return response()->json([
                'success' => true,
                'message' => 'Assignment declined successfully',
                'data' => [
                    'assignment_id' => (int)$id,
                    'status' => 'DECLINED'
                ]
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Lỗi khi từ chối phân công: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * 6. GET /api/mobile/reviewer/reviews
     * Lấy danh sách review đã nộp
     */
    public function getReviews(Request $request)
    {
        try {
            $user = Auth::user();

            $reviews = DB::table('phanbien as pb')
                ->join('phancongphanbien as pcp', 'pb.assignment_id', '=', 'pcp.assignment_id')
                ->join('baibao as b', 'pcp.paper_id', '=', 'b.paper_id')
                ->join('hoithao as ht', 'b.conference_id', '=', 'ht.conference_id')
                ->where('pb.reviewer_id', $user->user_id)
                ->select(
                    'pb.review_id',
                    'pb.assignment_id',
                    'pcp.paper_id',
                    'pb.recommendation_code',
                    DB::raw('(pb.score_novelty + pb.score_relevance + pb.score_technical_quality + pb.score_presentation + pb.score_references) / 5.0 as total_score'),
                    'pb.score_novelty',
                    'pb.score_relevance',
                    'pb.score_technical_quality',
                    'pb.score_presentation',
                    'pb.score_references',
                    'pb.submitted_at',
                    'pb.is_draft',
                    'b.title as paper_title',
                    'b.status as paper_status',
                    'ht.name as conference_name',
                    'pcp.assigned_at'
                )
                ->orderBy('pb.submitted_at', 'desc')
                ->get();

            // Get stats
            $stats = DB::table('phanbien')
                ->where('reviewer_id', $user->user_id)
                ->whereNotNull('submitted_at')
                ->select(
                    DB::raw('COUNT(*) as total'),
                    DB::raw('AVG((score_novelty + score_relevance + score_technical_quality + score_presentation + score_references) / 5.0) as average_score'),
                    DB::raw('SUM(CASE WHEN recommendation_code IN ("ACCEPT", "MINOR_REVISION") THEN 1 ELSE 0 END) as accept'),
                    DB::raw('SUM(CASE WHEN recommendation_code IN ("REJECT", "MAJOR_REVISION") THEN 1 ELSE 0 END) as reject')
                )
                ->first();

            return response()->json([
                'success' => true,
                'data' => [
                    'reviews' => $reviews,
                    'stats' => [
                        'total' => (int)$stats->total,
                        'average_score' => round((float)$stats->average_score, 2),
                        'accept' => (int)$stats->accept,
                        'reject' => (int)$stats->reject,
                    ]
                ]
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Lỗi khi tải danh sách review: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * 7. GET /api/mobile/reviewer/reviews/{id}
     * Lấy chi tiết review
     */
    public function getReviewDetail(Request $request, $id)
    {
        try {
            $user = Auth::user();

            $review = DB::table('phanbien as pb')
                ->join('phancongphanbien as pcp', 'pb.assignment_id', '=', 'pcp.assignment_id')
                ->join('baibao as b', 'pcp.paper_id', '=', 'b.paper_id')
                ->where('pb.review_id', $id)
                ->where('pb.reviewer_id', $user->user_id)
                ->select(
                    'pb.review_id',
                    'pb.assignment_id',
                    'pcp.paper_id',
                    'pb.score_novelty',
                    'pb.score_relevance',
                    'pb.score_technical_quality',
                    'pb.score_presentation',
                    'pb.score_references',
                    DB::raw('(pb.score_novelty + pb.score_relevance + pb.score_technical_quality + pb.score_presentation + pb.score_references) / 5.0 as total_score'),
                    'pb.detailed_comments',
                    'pb.recommendation_code',
                    'pb.is_draft',
                    'pb.submitted_at',
                    'pb.review_file_path',
                    'b.title as paper_title',
                    'b.abstract as paper_abstract',
                    'b.status as paper_status'
                )
                ->first();

            if (!$review) {
                return response()->json([
                    'success' => false,
                    'message' => 'Review not found'
                ], 404);
            }

            return response()->json([
                'success' => true,
                'data' => $review
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Lỗi khi tải chi tiết review: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * 8. POST /api/mobile/reviewer/reviews
     * Submit review (draft hoặc final)
     */
    public function submitReview(Request $request)
    {
        try {
            $validator = Validator::make($request->all(), [
                'assignment_id' => 'required|integer',
                'score_novelty' => 'required|integer|min:1|max:10',
                'score_relevance' => 'required|integer|min:1|max:10',
                'score_technical_quality' => 'required|integer|min:1|max:10',
                'score_presentation' => 'required|integer|min:1|max:10',
                'score_references' => 'required|integer|min:1|max:10',
                'detailed_comments' => 'required|string|min:50',
                'recommendation_code' => 'required|string',
                'is_draft' => 'boolean',
                'review_file' => 'nullable|file|mimes:pdf,doc,docx|max:10240'
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Validation failed',
                    'errors' => $validator->errors()
                ], 422);
            }

            $user = Auth::user();
            $assignmentId = $request->input('assignment_id');

            // Verify assignment belongs to this reviewer
            $assignment = DB::table('phancongphanbien')
                ->where('assignment_id', $assignmentId)
                ->where('reviewer_id', $user->user_id)
                ->where('status', 'ACCEPTED')
                ->first();

            if (!$assignment) {
                return response()->json([
                    'success' => false,
                    'message' => 'Assignment not found or not accepted'
                ], 404);
            }

            // Handle file upload
            $filePath = null;
            if ($request->hasFile('review_file')) {
                $file = $request->file('review_file');
                $filename = 'review_' . $assignmentId . '_' . time() . '.' . $file->getClientOriginalExtension();
                $filePath = $file->storeAs('reviews', $filename, 'public');
            }

            $isDraft = $request->input('is_draft', false);

            // Check if review already exists
            $existingReview = DB::table('phanbien')
                ->where('assignment_id', $assignmentId)
                ->where('reviewer_id', $user->user_id)
                ->first();

            $reviewData = [
                'assignment_id' => $assignmentId,
                'reviewer_id' => $user->user_id,
                'score_novelty' => $request->input('score_novelty'),
                'score_relevance' => $request->input('score_relevance'),
                'score_technical_quality' => $request->input('score_technical_quality'),
                'score_presentation' => $request->input('score_presentation'),
                'score_references' => $request->input('score_references'),
                'detailed_comments' => $request->input('detailed_comments'),
                'recommendation_code' => $request->input('recommendation_code'),
                'is_draft' => $isDraft,
                'submitted_at' => $isDraft ? null : now(),
            ];

            if ($filePath) {
                $reviewData['review_file_path'] = $filePath;
            }

            if ($existingReview) {
                // Update existing review
                DB::table('phanbien')
                    ->where('review_id', $existingReview->review_id)
                    ->update($reviewData);
                
                $reviewId = $existingReview->review_id;
            } else {
                // Insert new review
                $reviewId = DB::table('phanbien')->insertGetId($reviewData);
            }

            // Update assignment status if final submission
            if (!$isDraft) {
                DB::table('phancongphanbien')
                    ->where('assignment_id', $assignmentId)
                    ->update(['status' => 'COMPLETED']);
            }

            return response()->json([
                'success' => true,
                'message' => $isDraft ? 'Review saved as draft' : 'Review submitted successfully',
                'data' => [
                    'review_id' => (int)$reviewId,
                    'is_draft' => $isDraft
                ]
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Lỗi khi submit review: ' . $e->getMessage()
            ], 500);
        }
    }
}
