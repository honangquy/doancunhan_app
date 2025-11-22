<?php

use Illuminate\Support\Facades\Route;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Auth\AuthController;
use App\Http\Controllers\HomeController;
use App\Http\Controllers\DashboardController;
use App\Http\Controllers\Author\PaperController as AuthorPaperController;
use App\Http\Controllers\Reviewer\BiddingController;
use App\Http\Controllers\Reviewer\AssignmentController;
use App\Http\Controllers\Chair\ConferenceController as ChairConferenceController;
use App\Http\Controllers\Chair\PaperController as ChairPaperController;
use App\Http\Controllers\Chair\ReviewerController as ChairReviewerController;
use App\Http\Controllers\Chair\COIController;
use App\Http\Controllers\Admin\UserController as AdminUserController;
use App\Http\Controllers\Admin\ConferenceController as AdminConferenceController;
use App\Http\Controllers\Admin\ConferenceRequestController as AdminConferenceRequestController;
use App\Http\Controllers\Admin\ReportController;
use App\Http\Controllers\Admin\ActivityLogController;
use App\Http\Controllers\ConferenceRequestController;

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
|
| Here is where you can register web routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| contains the "web" middleware group. Now create something great!
|
*/

// Public Routes
Route::get('/', [HomeController::class, 'index'])->name('home');

// AJAX Routes for Homepage
Route::get('/api/search-conferences', [HomeController::class, 'searchConferences'])->name('api.search.conferences');
Route::get('/api/conference-counts', [HomeController::class, 'getConferenceCounts'])->name('api.conference.counts');

// Assignment Notification Routes
Route::middleware(['auth', 'role:REVIEWER'])->prefix('reviewer')->group(function () {
    Route::get('/notifications', [\App\Http\Controllers\Reviewer\NotificationController::class, 'index'])->name('reviewer.notifications.index');
    Route::patch('/notifications/{id}/read', [\App\Http\Controllers\Reviewer\NotificationController::class, 'markAsRead'])->name('reviewer.notifications.read');
    Route::get('/notifications/unread-count', [\App\Http\Controllers\Reviewer\NotificationController::class, 'getUnreadCount'])->name('reviewer.notifications.unread_count');
    Route::patch('/notifications/mark-all-read', [\App\Http\Controllers\Reviewer\NotificationController::class, 'markAllAsRead'])->name('reviewer.notifications.mark_all_read');
    
    // Assignment tracking routes
    Route::get('/assignments', [\App\Http\Controllers\Reviewer\AssignmentController::class, 'index'])->name('reviewer.assignments.index');
    Route::get('/assignments/{id}', [\App\Http\Controllers\Reviewer\AssignmentController::class, 'show'])->name('reviewer.assignments.show');
    
    // UI Animations Demo
    Route::get('/animations-demo', function () {
        return view('animations-demo');
    })->name('reviewer.animations.demo');
    Route::post('/assignments/{id}/accept', [\App\Http\Controllers\Reviewer\AssignmentController::class, 'accept'])->name('reviewer.assignments.accept');
    Route::post('/assignments/{id}/decline', [\App\Http\Controllers\Reviewer\AssignmentController::class, 'decline'])->name('reviewer.assignments.decline');
    Route::get('/assignments/stats', [\App\Http\Controllers\Reviewer\AssignmentController::class, 'getStats'])->name('reviewer.assignments.stats');
});
// Conference Routes (Public)
Route::get('/conferences', [\App\Http\Controllers\ConferenceController::class, 'index'])->name('conferences.index');
Route::get('/conferences/{id}', [\App\Http\Controllers\ConferenceController::class, 'show'])->name('conferences.show');
Route::get('/conferences/{id}/cfp', [\App\Http\Controllers\ConferenceController::class, 'showCFP'])->name('conferences.cfp');

// Reviewer invitation routes (public access)
Route::get('/reviewer/invitation/{token}', [\App\Http\Controllers\Reviewer\InvitationController::class, 'acceptInvitation'])->name('reviewer.invitation.accept');
Route::get('/reviewer/join', [\App\Http\Controllers\Reviewer\InvitationController::class, 'showJoinForm'])->name('reviewer.join.form');
Route::post('/reviewer/join', [\App\Http\Controllers\Reviewer\InvitationController::class, 'submitJoinForm'])->name('reviewer.join.submit');

// Conference Join Request Routes (Authenticated and Verified)
Route::middleware(['auth', 'verified'])->group(function () {
    Route::post('/conferences/{id}/join-request', [\App\Http\Controllers\ConferenceController::class, 'submitJoinRequest'])->name('conferences.join-request');
    Route::get('/conferences/{id}/my-requests', [\App\Http\Controllers\ConferenceController::class, 'getUserJoinRequests'])->name('conferences.my-requests');
    Route::get('/my-join-requests', [\App\Http\Controllers\ConferenceController::class, 'myJoinRequests'])->name('join-requests.index');
});

Route::get('/news', [HomeController::class, 'news'])->name('news.index');
Route::get('/process', [HomeController::class, 'process'])->name('process');
Route::get('/support', [HomeController::class, 'support'])->name('support');



// Conference Request Routes (Authenticated and Verified)
Route::middleware(['auth', 'verified'])->group(function () {
    Route::get('/create-conference', function () {
        return view('conference-request.create');
    })->name('conference-request.create');
    

    
    Route::post('/conference-requests', [ConferenceRequestController::class, 'store'])->name('conference-request.store');
    
    // Conference Management Routes
    Route::prefix('conference-management')->name('conference-management.')->group(function () {
        Route::get('/requests', [\App\Http\Controllers\ConferenceManagementController::class, 'requests'])->name('requests');
        Route::get('/requests/{id}', [\App\Http\Controllers\ConferenceManagementController::class, 'showRequest'])->name('request.show');
        Route::post('/requests/{id}/approve', [\App\Http\Controllers\ConferenceManagementController::class, 'approveRequest'])->name('request.approve');
        Route::post('/requests/{id}/reject', [\App\Http\Controllers\ConferenceManagementController::class, 'rejectRequest'])->name('request.reject');
    });
});



// Conference request endpoint without CSRF for testing
Route::post('/submit-conference-request', function (\Illuminate\Http\Request $request) {
    try {
        \Log::info('Web Conference request called', $request->all());
        
        // Validate request
        $validator = \Validator::make($request->all(), [
            'title' => 'required|string|max:500',
            'objective' => 'required|string',
            'level_code' => 'required|in:KHOA,TRUONG',
            'chair_fullname' => 'required|string|max:255',
            'chair_email' => 'required|email|max:255',
            'proposal_file' => 'required|file|mimes:pdf|max:10240',
        ]);
        
        if ($validator->fails()) {
            \Log::error('Validation failed', $validator->errors()->toArray());
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }
        
        \Log::info('Validation passed, handling file upload');
        
        // Handle file upload
        $fileName = null;
        if ($request->hasFile('proposal_file')) {
            \Log::info('File upload detected');
            $file = $request->file('proposal_file');
            $fileName = time() . '_' . $file->getClientOriginalName();
            $file->storeAs('conference-requests', $fileName, 'public');
            \Log::info('File stored: ' . $fileName);
        }
        
        \Log::info('Creating database record');
        
        // Get authenticated user ID or set to null if not authenticated
        $userId = auth()->check() ? auth()->user()->user_id : null;
        
        // Create conference request record
        $conferenceRequest = \App\Models\YeuCauHoiThao::create([
            'user_id' => $userId,
            'title' => $request->title,
            'objective' => $request->objective,
            'field' => $request->field,
            'level_code' => $request->level_code,
            'faculty_name' => $request->faculty_name,
            'expected_date' => $request->expected_date,
            'affiliation' => $request->affiliation,
            'chair_fullname' => $request->chair_fullname,
            'chair_email' => $request->chair_email,
            'chair_phone' => $request->chair_phone,
            'proposal_file' => $fileName,
            'status' => 'PENDING',
            'created_at' => now(),
        ]);
        
        \Log::info('Record created with ID: ' . $conferenceRequest->request_id);
        
        return response()->json([
            'success' => true,
            'message' => 'Conference request submitted successfully',
            'request_id' => $conferenceRequest->request_id,
        ]);
        
    } catch (\Exception $e) {
        \Log::error('Conference request error: ' . $e->getMessage());
        \Log::error('Stack trace: ' . $e->getTraceAsString());
        
        return response()->json([
            'success' => false,
            'message' => 'An error occurred while processing your request',
            'error' => $e->getMessage(),
            'trace' => config('app.debug') ? $e->getTraceAsString() : null
        ], 500);
    }
});

// Guest Routes (not authenticated)
Route::middleware('guest')->group(function () {
    Route::get('/login', [AuthController::class, 'showLoginForm'])->name('login');
    Route::post('/login', [AuthController::class, 'login']);
    Route::get('/register', [AuthController::class, 'showRegisterForm'])->name('register');
    Route::post('/register', [AuthController::class, 'register']);
    Route::get('/forgot-password', [AuthController::class, 'showForgotPasswordForm'])->name('password.request');
    Route::post('/forgot-password', [AuthController::class, 'sendResetLink'])->name('password.email');
    Route::get('/reset-password/{token}', [AuthController::class, 'showResetPasswordForm'])->name('password.reset');
    Route::post('/reset-password', [AuthController::class, 'resetPassword'])->name('password.update');
});

// Email Verification Routes
Route::middleware('auth')->group(function () {
    Route::get('/email/verify', [AuthController::class, 'showVerifyEmailForm'])->name('verification.notice');
    Route::post('/email/verification-notification', [AuthController::class, 'resendVerificationEmail'])->middleware(['throttle:6,1'])->name('verification.send');
});

Route::get('/email/verify/{id}/{hash}', [AuthController::class, 'verifyEmail'])
    ->name('verification.verify');

// Authenticated Routes (require email verification)
Route::middleware(['auth', 'verified'])->group(function () {
    Route::post('/logout', [AuthController::class, 'logout'])->name('logout');
    Route::get('/profile', [AuthController::class, 'showProfile'])->name('profile.show');
    Route::put('/profile', [AuthController::class, 'updateProfile'])->name('profile.update');
    Route::put('/profile/password', [AuthController::class, 'updatePassword'])->name('profile.password');
    Route::post('/profile/avatar', [AuthController::class, 'updateAvatar'])->name('profile.avatar');
    
    // Dashboard (role-based)
    Route::get('/dashboard', [DashboardController::class, 'index'])->name('dashboard');
    
    // Author Routes
    Route::prefix('author')->middleware('role:AUTHOR')->name('author.')->group(function () {
        Route::get('/dashboard', [DashboardController::class, 'authorDashboard'])->name('dashboard');
        
        // Paper Management
        Route::get('/papers', [AuthorPaperController::class, 'index'])->name('papers.index');
        Route::get('/papers/create', [AuthorPaperController::class, 'create'])->name('papers.create');
        Route::post('/papers', [AuthorPaperController::class, 'store'])->name('papers.store');
        Route::get('/papers/{id}', [AuthorPaperController::class, 'show'])->name('papers.show');
        Route::get('/papers/{id}/edit', [AuthorPaperController::class, 'edit'])->name('papers.edit');
        Route::put('/papers/{id}', [AuthorPaperController::class, 'update'])->name('papers.update');
        Route::post('/papers/{id}/withdraw', [AuthorPaperController::class, 'withdraw'])->name('papers.withdraw');
        Route::get('/papers/{id}/download', [AuthorPaperController::class, 'download'])->name('papers.download');
    });
    
    // Reviewer Routes
    Route::prefix('reviewer')->middleware('role:REVIEWER')->name('reviewer.')->group(function () {
        Route::get('/dashboard', [DashboardController::class, 'reviewerDashboard'])->name('dashboard');
        
        // Reviews
        Route::get('/reviews', [\App\Http\Controllers\Reviewer\ReviewerController::class, 'reviews'])->name('reviews');
        Route::get('/reviews/create/{assignmentId}', [\App\Http\Controllers\Reviewer\ReviewerController::class, 'createReview'])->name('reviews.create');
        Route::post('/reviews/{assignmentId}/store', [\App\Http\Controllers\Reviewer\ReviewerController::class, 'storeReview'])->name('reviews.store');
        Route::get('/reviews/{assignmentId}/data', [\App\Http\Controllers\Reviewer\ReviewerController::class, 'getReviewData'])->name('reviews.data');
        Route::get('/reviews/{id}', [\App\Http\Controllers\Reviewer\ReviewerController::class, 'showReview'])->name('reviews.show');
        Route::get('/reviews/{id}/edit', [\App\Http\Controllers\Reviewer\ReviewerController::class, 'editReview'])->name('reviews.edit');
        Route::put('/reviews/{id}', [\App\Http\Controllers\Reviewer\ReviewerController::class, 'updateReview'])->name('reviews.update');
        
        // Paper Download  
        Route::get('/papers/{paperId}/download', [\App\Http\Controllers\Reviewer\ReviewerController::class, 'downloadPaper'])->name('papers.download');
        
        // Bidding & COI Management
        Route::get('/bidding', [BiddingController::class, 'index'])->name('bidding');
        Route::get('/conferences', [BiddingController::class, 'getConferences'])->name('conferences');
        Route::get('/conference/{conferenceId}/papers', [BiddingController::class, 'getConferencePapers'])->name('conference.papers');
        Route::post('/bidding', [BiddingController::class, 'submitBidding'])->name('bidding.submit');
        Route::post('/bidding/bulk', [BiddingController::class, 'submitBulkBidding'])->name('bidding.bulk');
        Route::get('/assignments/data', [BiddingController::class, 'getAssignments'])->name('assignments.data');
        Route::post('/assignment/{assignmentId}/respond', [BiddingController::class, 'respondToAssignment'])->name('assignment.respond');
        Route::get('/bidding/statistics/{conferenceId?}', [BiddingController::class, 'getBiddingStatistics'])->name('bidding.statistics');
        
        // Phase 8.10: Legacy COI Management (keeping for compatibility)
        Route::get('/coi', [\App\Http\Controllers\Reviewer\COIController::class, 'index'])->name('coi.index');
        Route::get('/coi/create', [\App\Http\Controllers\Reviewer\COIController::class, 'create'])->name('coi.create');
        Route::post('/coi', [\App\Http\Controllers\Reviewer\COIController::class, 'store'])->name('coi.store');
        Route::get('/coi/{id}', [\App\Http\Controllers\Reviewer\COIController::class, 'show'])->name('coi.show');
        Route::delete('/coi/{id}', [\App\Http\Controllers\Reviewer\COIController::class, 'retract'])->name('coi.retract');
        Route::get('/coi/search-papers', [\App\Http\Controllers\Reviewer\COIController::class, 'searchPapers'])->name('coi.search-papers');
    });
    
    // Chair Routes
    Route::prefix('chair')->middleware('role:CHAIR')->name('chair.')->group(function () {
        // Dashboard
        Route::get('/dashboard', [\App\Http\Controllers\Chair\ChairController::class, 'dashboard'])->name('dashboard');
        

        
        // Conference Management (New)
        Route::get('/conferences', [\App\Http\Controllers\Chair\ConferenceSetupController::class, 'index'])->name('conferences.index');
        Route::get('/conferences/configure/{requestId}', [\App\Http\Controllers\Chair\ConferenceSetupController::class, 'configure'])->name('conferences.configure');
        Route::post('/conferences/configure/{requestId}', [\App\Http\Controllers\Chair\ConferenceSetupController::class, 'store'])->name('conferences.store');
        
        // Test route for debugging
        Route::post('/test-conference-debug/{requestId}', function(Request $request, $requestId) {
            \Log::info('Test route called', [
                'requestId' => $requestId,
                'data' => $request->all()
            ]);
            return response()->json(['success' => true, 'data' => $request->all()]);
        })->name('test.conference.debug');
        Route::get('/conferences/{conferenceId}', [\App\Http\Controllers\Chair\ConferenceSetupController::class, 'show'])->name('conferences.show');
        Route::get('/conferences/{conferenceId}/edit', [\App\Http\Controllers\Chair\ConferenceSetupController::class, 'edit'])->name('conferences.edit');
        Route::put('/conferences/{conferenceId}', [\App\Http\Controllers\Chair\ConferenceSetupController::class, 'update'])->name('conferences.update');

        // Legacy Conference Configuration (keep for compatibility)
        Route::get('/my-conferences', [\App\Http\Controllers\Chair\ConferenceController::class, 'myConferences'])->name('my-conferences');
        Route::get('/configure-conference/{id}', [\App\Http\Controllers\Chair\ConferenceController::class, 'configureForm'])->name('configure-conference');
        
        // Paper Management
        Route::get('/papers', [\App\Http\Controllers\Chair\ChairController::class, 'papers'])->name('papers');
        Route::get('/papers/{id}', [\App\Http\Controllers\Chair\ChairController::class, 'showPaper'])->name('papers.show');
        Route::get('/papers/{id}/ajax', [\App\Http\Controllers\Chair\ChairController::class, 'showPaperAjax'])->name('papers.ajax');
        
        // Reviewer Assignment (Legacy)
        Route::get('/papers/{id}/assign', [\App\Http\Controllers\Chair\ChairController::class, 'assignReviewers'])->name('papers.assign');
        Route::post('/papers/{id}/assign', [\App\Http\Controllers\Chair\ChairController::class, 'storeAssignment'])->name('papers.assign.store');
        // Route::delete('/assignments/{id}', [\App\Http\Controllers\Chair\ChairController::class, 'removeAssignment'])->name('assignments.remove'); // Commented out due to route conflict
        Route::get('/papers/{paperId}/coi/{reviewerId}', [\App\Http\Controllers\Chair\ChairController::class, 'checkCOI'])->name('papers.coi.check');
        Route::get('/papers/{id}/suggest-reviewers', [\App\Http\Controllers\Chair\ChairController::class, 'suggestReviewers'])->name('papers.suggest');
        
        // Phase 8.8: Reviews Management
        Route::get('/papers/{id}/reviews', [\App\Http\Controllers\Chair\ChairController::class, 'reviews'])->name('papers.reviews');
        Route::get('/papers/{id}/reviews/export', [\App\Http\Controllers\Chair\ChairController::class, 'exportReviews'])->name('papers.reviews.export');
        Route::get('/reviews/{id}', [\App\Http\Controllers\Chair\ChairController::class, 'getReviewDetails'])->name('reviews.details');
        Route::get('/test-review/{id}', function($id) {
            $review = DB::table('phanbien as pb')
                ->join('reviewer_assignments as ra', 'pb.assignment_id', '=', 'ra.id')
                ->join('nguoidung as u', 'ra.user_id', '=', 'u.user_id')
                ->where('pb.review_id', $id)
                ->select(['pb.*', 'u.full_name as reviewer_name', 'u.email as reviewer_email', 'u.organization as reviewer_organization'])
                ->first();
            
            if (!$review) {
                return response()->json(['error' => 'Review not found'], 404);
            }
            
            return response()->json($review);
        });
        
        // Phase 8.9: Final Decision
        Route::get('/papers/{id}/decision', [\App\Http\Controllers\Chair\ChairController::class, 'makeDecision'])->name('papers.decision');
        Route::post('/papers/{id}/decision', [\App\Http\Controllers\Chair\ChairController::class, 'storeDecision'])->name('papers.decision.store');
        
        // Phase 8.10: Reviewers Management - Direct to invitation controller
        Route::get('/reviewers', [\App\Http\Controllers\Chair\ReviewerInvitationController::class, 'index'])->name('reviewers.index');
        
        // Phase 8.10: COI Management
        Route::get('/coi', [\App\Http\Controllers\Chair\COIController::class, 'index'])->name('coi.index');
        Route::get('/coi/{id}', [\App\Http\Controllers\Chair\COIController::class, 'show'])->name('coi.show');
        Route::get('/coi/{id}/resolve', [\App\Http\Controllers\Chair\COIController::class, 'resolveForm'])->name('coi.resolve-form');
        Route::post('/coi/{id}/resolve', [\App\Http\Controllers\Chair\COIController::class, 'resolve'])->name('coi.resolve');
        Route::get('/conferences/{conferenceId}/coi-statistics', [\App\Http\Controllers\Chair\COIController::class, 'statistics'])->name('coi.statistics');
        
        // Reviewer Invitation Management
        Route::get('/reviewers/invite', [\App\Http\Controllers\Chair\ReviewerInvitationController::class, 'index'])->name('reviewers.invite');
        Route::post('/reviewers/invite/send', [\App\Http\Controllers\Chair\ReviewerInvitationController::class, 'sendInvitation'])->name('reviewers.invite.send');
        Route::get('/reviewers/invitations', [\App\Http\Controllers\Chair\ReviewerInvitationController::class, 'sentInvitations'])->name('reviewers.invite.list');
        Route::post('/reviewers/invite/{id}/resend', [\App\Http\Controllers\Chair\ReviewerInvitationController::class, 'resendInvitation'])->name('reviewers.invite.resend');
        Route::post('/reviewers/invite/{id}/revoke', [\App\Http\Controllers\Chair\ReviewerInvitationController::class, 'revokeInvitation'])->name('reviewers.invite.revoke');
        
        // Test route
        Route::get('/test-invite', function() {
            return view('chair.reviewers.invite', ['conferences' => collect()]);
        })->name('test.invite');
        
        // Route with parameter should be last to avoid conflicts
        Route::get('/reviewers/{id}', [\App\Http\Controllers\Chair\ChairController::class, 'showReviewer'])->name('reviewers.show');
        
        // Reviewer Assignment Management (New Bidding System)
        Route::get('/assignments', [\App\Http\Controllers\Chair\ReviewerAssignmentController::class, 'index'])->name('assignments.index');
        Route::get('/assignments/statistics/{conferenceId}', [\App\Http\Controllers\Chair\ReviewerAssignmentController::class, 'getAssignmentStatistics'])->name('assignments.statistics');
        Route::get('/assignments/papers/{conferenceId}', [\App\Http\Controllers\Chair\ReviewerAssignmentController::class, 'getConferencePapers'])->name('assignments.papers');
        Route::get('/assignments/paper/{paperId}/biddings', [\App\Http\Controllers\Chair\ReviewerAssignmentController::class, 'getPaperBiddings'])->name('assignments.paper.biddings');
        Route::post('/assignments/manual-assign', [\App\Http\Controllers\Chair\ReviewerAssignmentController::class, 'manualAssign'])->name('assignments.manual');
        Route::post('/assignments/auto-assign', [\App\Http\Controllers\Chair\ReviewerAssignmentController::class, 'autoAssign'])->name('assignments.auto');
        Route::delete('/assignments/{assignmentId}', [\App\Http\Controllers\Chair\ReviewerAssignmentController::class, 'removeAssignment'])->name('reviewer.assignments.remove');
        
        // Legacy routes for backward compatibility
        Route::get('/assignments/{paperId}/assign', [\App\Http\Controllers\Chair\ReviewerAssignmentController::class, 'assign'])->name('assignments.assign');
        Route::post('/assignments/store', [\App\Http\Controllers\Chair\ReviewerAssignmentController::class, 'store'])->name('assignments.store');
    });
    
    // Admin Routes
    Route::prefix('admin')->middleware('role:ADMIN')->name('admin.')->group(function () {
        Route::get('/dashboard', [DashboardController::class, 'adminDashboard'])->name('dashboard');
        
        // Join Request Management
        Route::get('/join-requests', [\App\Http\Controllers\ConferenceController::class, 'adminJoinRequests'])->name('join-requests.index');
        Route::get('/conferences/{id}/join-requests', [\App\Http\Controllers\ConferenceController::class, 'manageJoinRequests'])->name('conferences.join-requests');
        Route::post('/join-requests/{id}/process', [\App\Http\Controllers\ConferenceController::class, 'processJoinRequest'])->name('join-requests.process');
        
        // Conference Request Management (Chair Request to Organize)
        Route::get('/conference-requests', [AdminConferenceRequestController::class, 'index'])->name('conference-requests.index');
        Route::get('/conference-requests/{id}', [AdminConferenceRequestController::class, 'show'])->name('conference-requests.show');
        Route::post('/conference-requests/{id}/approve', [AdminConferenceRequestController::class, 'approve'])->name('conference-requests.approve');
        Route::post('/conference-requests/{id}/reject', [AdminConferenceRequestController::class, 'reject'])->name('conference-requests.reject');
        Route::get('/conference-requests/{id}/download', [AdminConferenceRequestController::class, 'downloadProposal'])->name('conference-requests.download');
        Route::post('/conference-requests/bulk-action', [AdminConferenceRequestController::class, 'bulkAction'])->name('conference-requests.bulk-action');

        // Conference Configuration Final Approval
        Route::get('/configured-conferences', [AdminConferenceRequestController::class, 'configuredConferences'])->name('configured-conferences.index');
        Route::get('/configured-conferences/{id}', [AdminConferenceRequestController::class, 'showConference'])->name('configured-conferences.show');
        Route::post('/conference-requests/{id}/approve-conference', [AdminConferenceRequestController::class, 'approveConference'])->name('conference-requests.approve-conference');
        Route::post('/conference-requests/{id}/reject-conference', [AdminConferenceRequestController::class, 'rejectConference'])->name('conference-requests.reject-conference');
        
        // User Management
        Route::get('/users', [DashboardController::class, 'adminUsers'])->name('users.index');
        
        // Conference Management (All Conferences - Active ones)
        Route::get('/conferences', [AdminConferenceRequestController::class, 'allConferences'])->name('conferences.index');
        Route::get('/conferences/{id}', [AdminConferenceRequestController::class, 'showConferenceDetails'])->name('conferences.show');
        Route::get('/conferences/{id}/edit', [AdminConferenceRequestController::class, 'editConference'])->name('conferences.edit');
        Route::put('/conferences/{id}', [AdminConferenceRequestController::class, 'updateConference'])->name('conferences.update');
        Route::post('/conferences/{id}/status', [AdminConferenceRequestController::class, 'changeConferenceStatus'])->name('conferences.change-status');
        Route::delete('/conferences/{id}', [AdminConferenceRequestController::class, 'deleteConference'])->name('conferences.delete');
        Route::post('/conferences/bulk-delete', [AdminConferenceRequestController::class, 'bulkDelete'])->name('conferences.bulk-delete');
        
        // Reports & Statistics
        Route::get('/reports', [DashboardController::class, 'adminReports'])->name('reports.index');
        
        // User Management
        Route::get('/users', [DashboardController::class, 'adminUsers'])->name('users.index');
        Route::post('/users', [DashboardController::class, 'storeUser'])->name('users.store');
        Route::get('/users/{id}/edit', [DashboardController::class, 'editUser'])->name('users.edit');
        Route::put('/users/{id}', [DashboardController::class, 'updateUser'])->name('users.update');
        Route::delete('/users/{id}', [DashboardController::class, 'deleteUser'])->name('users.destroy');
        
        // Role Management
        Route::get('/roles', [DashboardController::class, 'adminRoles'])->name('roles.index');
        
        // Permissions Management
        Route::get('/permissions', [DashboardController::class, 'adminPermissions'])->name('permissions.index');
        
        // System Settings
        Route::get('/settings', [DashboardController::class, 'adminSettings'])->name('settings.index');
        
        // System Logs
        Route::get('/logs', [\App\Http\Controllers\Admin\ActivityLogController::class, 'index'])->name('logs.index');
        Route::get('/logs/stats', [\App\Http\Controllers\Admin\ActivityLogController::class, 'stats'])->name('logs.stats');
        Route::get('/logs/export', [\App\Http\Controllers\Admin\ActivityLogController::class, 'export'])->name('logs.export');
        Route::delete('/logs/clear', [\App\Http\Controllers\Admin\ActivityLogController::class, 'clear'])->name('logs.clear');
        Route::get('/logs/{id}', [\App\Http\Controllers\Admin\ActivityLogController::class, 'show'])->name('logs.show');
        
        // Email Verification Management
        Route::post('/users/{id}/verify-email', [DashboardController::class, 'verifyUserEmail'])->name('users.verify-email');
        Route::post('/users/{id}/unverify-email', [DashboardController::class, 'unverifyUserEmail'])->name('users.unverify-email');
        
        // User API Routes
        Route::get('/api/users/{id}', [DashboardController::class, 'getUserDetails'])->name('users.api.details');
        Route::post('/api/users/bulk-delete', [DashboardController::class, 'bulkDeleteUsers'])->name('users.api.bulk-delete');
        Route::post('/api/users/{id}/role', [DashboardController::class, 'updateUserRole'])->name('users.api.update-role');
        
        // Conference API Routes
        Route::get('/api/conferences/{id}', [DashboardController::class, 'getConferenceDetails'])->name('conferences.api.details');
        Route::post('/api/conferences/bulk-delete', [DashboardController::class, 'bulkDeleteConferences'])->name('conferences.api.bulk-delete');
    });
});

// Debug route
Route::get('/chair/debug-menu', function () {
    return view('chair.debug-menu');
})->name('chair.debug-menu')->middleware(['auth']);

// Test join request debug
Route::get('/debug/test-join/{token}', function($token) {
    // Simulate a join request with invitation
    $invitation = DB::table('reviewer_invitations')
        ->where('token', $token)
        ->where('status', 'PENDING')
        ->first();
    
    if (!$invitation) {
        return 'Invitation not found';
    }
    
    $user = DB::table('nguoidung')->where('email', $invitation->email)->first();
    if (!$user) {
        return 'User not found with email: ' . $invitation->email;
    }
    
    // Check existing roles
    $existingRoles = DB::table('vaitronguoidung')
        ->where('user_id', $user->user_id)
        ->get();
    
    $output = "User: {$user->full_name} (ID: {$user->user_id})\n";
    $output .= "Email: {$user->email}\n";
    $output .= "Existing roles: " . count($existingRoles) . "\n";
    foreach($existingRoles as $role) {
        $output .= "- {$role->role_code} for conference {$role->conference_id}\n";
    }
    
    // Test role assignment
    $existingReviewerRole = DB::table('vaitronguoidung')
        ->where('user_id', $user->user_id)
        ->where('conference_id', $invitation->conference_id)
        ->where('role_code', 'REVIEWER')
        ->first();
    
    if (!$existingReviewerRole) {
        DB::table('vaitronguoidung')->insert([
            'user_id' => $user->user_id,
            'conference_id' => $invitation->conference_id,
            'role_code' => 'REVIEWER'
        ]);
        $output .= "\n✅ REVIEWER role assigned!";
    } else {
        $output .= "\n⚠️ REVIEWER role already exists";
    }
    
    return nl2br($output);
});
