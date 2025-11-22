<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class PaperController extends Controller
{
    /**
     * GET /api/papers/statistics
     * 
     * Trả về thống kê bài báo của tác giả đang login
     * 
     * Response format:
     * {
     *   "success": true,
     *   "data": {
     *     "total_papers": 5,
     *     "by_status": {
     *       "SUBMITTED": 2,
     *       "UNDER_REVIEW": 1,
     *       "ACCEPTED": 1,
     *       "REJECTED": 1
     *     },
     *     "recent_papers": [
     *       {
     *         "paper_id": 1,
     *         "title": "Paper Title",
     *         "status": "SUBMITTED",
     *         "created_at": "2025-01-15T10:30:00.000000Z"
     *       }
     *     ]
     *   }
     * }
     */
    public function statistics(Request $request)
    {
        try {
            $user = $request->user();
            
            // Lấy tất cả papers của user (theo author_id hoặc user_id)
            // Giả sử table baibao có cột user_id hoặc author_id
            $papers = DB::table('baibao')
                ->where('user_id', $user->id) // Hoặc author_id nếu table dùng tên khác
                ->get();
            
            // Đếm tổng số bài
            $totalPapers = $papers->count();
            
            // Đếm theo status
            $byStatus = [
                'SUBMITTED' => $papers->where('status', 'SUBMITTED')->count(),
                'UNDER_REVIEW' => $papers->where('status', 'UNDER_REVIEW')->count(),
                'ACCEPTED' => $papers->where('status', 'ACCEPTED')->count(),
                'REJECTED' => $papers->where('status', 'REJECTED')->count(),
            ];
            
            // Lấy 5 bài gần nhất
            $recentPapers = DB::table('baibao')
                ->where('user_id', $user->id)
                ->orderBy('created_at', 'desc')
                ->limit(5)
                ->get()
                ->map(function ($paper) {
                    return [
                        'paper_id' => $paper->id,
                        'title' => $paper->title,
                        'status' => $paper->status,
                        'created_at' => $paper->created_at,
                    ];
                });
            
            return response()->json([
                'success' => true,
                'data' => [
                    'total_papers' => $totalPapers,
                    'by_status' => $byStatus,
                    'recent_papers' => $recentPapers,
                ]
            ]);
            
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error fetching statistics',
                'error' => $e->getMessage()
            ], 500);
        }
    }
    
    /**
     * GET /api/my-papers
     * 
     * Trả về danh sách tất cả bài báo của tác giả
     * 
     * Response format:
     * {
     *   "success": true,
     *   "data": [
     *     {
     *       "id": 1,
     *       "paper_id": 1,
     *       "title": "Paper Title",
     *       "abstract": "Abstract...",
     *       "status": "SUBMITTED",
     *       "track_id": 1,
     *       "track_name": "Track Name",
     *       "created_at": "2025-01-15T10:30:00.000000Z",
     *       "updated_at": "2025-01-15T10:30:00.000000Z"
     *     }
     *   ]
     * }
     */
    public function myPapers(Request $request)
    {
        try {
            $user = $request->user();
            
            // Lấy papers với join track để lấy track_name
            $papers = DB::table('baibao')
                ->leftJoin('tracks', 'baibao.track_id', '=', 'tracks.id')
                ->where('baibao.user_id', $user->id)
                ->select(
                    'baibao.id',
                    'baibao.id as paper_id',
                    'baibao.title',
                    'baibao.abstract',
                    'baibao.keywords',
                    'baibao.status',
                    'baibao.track_id',
                    'tracks.name as track_name',
                    'baibao.created_at',
                    'baibao.updated_at'
                )
                ->orderBy('baibao.created_at', 'desc')
                ->get();
            
            return response()->json([
                'success' => true,
                'data' => $papers
            ]);
            
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error fetching papers',
                'error' => $e->getMessage()
            ], 500);
        }
    }
    
    /**
     * GET /api/papers/{id}
     * 
     * Trả về chi tiết bài báo
     * 
     * Response format:
     * {
     *   "success": true,
     *   "data": {
     *     "paper_id": 1,
     *     "title": "Paper Title",
     *     "abstract": "Abstract...",
     *     "keywords": "keyword1, keyword2",
     *     "status": "SUBMITTED",
     *     "track": {
     *       "track_id": 1,
     *       "title": "Track Name"
     *     },
     *     "authors": [...],
     *     "versions": [...],
     *     "reviews": [...]
     *   }
     * }
     */
    public function show(Request $request, $id)
    {
        try {
            // Get paper
            $paper = DB::table('baibao')->where('id', $id)->first();
            
            if (!$paper) {
                return response()->json([
                    'success' => false,
                    'message' => 'Paper not found'
                ], 404);
            }
            
            // Get track
            $track = null;
            if ($paper->track_id) {
                $trackData = DB::table('tracks')->where('id', $paper->track_id)->first();
                if ($trackData) {
                    $track = [
                        'track_id' => $trackData->id,
                        'title' => $trackData->name
                    ];
                }
            }
            
            // Get authors (nếu có table riêng)
            // Tạm thời trả về empty array
            $authors = [];
            
            // Get versions (nếu có table riêng)
            $versions = [];
            
            // Get reviews (nếu có table riêng)
            $reviews = [];
            
            return response()->json([
                'success' => true,
                'data' => [
                    'paper_id' => $paper->id,
                    'title' => $paper->title,
                    'abstract' => $paper->abstract ?? '',
                    'keywords' => $paper->keywords,
                    'status' => $paper->status,
                    'track' => $track,
                    'authors' => $authors,
                    'versions' => $versions,
                    'reviews' => $reviews,
                ]
            ]);
            
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error fetching paper detail',
                'error' => $e->getMessage()
            ], 500);
        }
    }
}
