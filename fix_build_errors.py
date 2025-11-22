#!/usr/bin/env python3
import re
import os

def fix_file(filepath, patterns):
    """Apply regex replacements to a file"""
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
        
        original = content
        for pattern, replacement in patterns:
            content = re.sub(pattern, replacement, content, flags=re.MULTILINE)
        
        if content != original:
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(content)
            print(f"✓ Fixed {filepath}")
            return True
        return False
    except Exception as e:
        print(f"✗ Error fixing {filepath}: {e}")
        return False

# Define files and their fixes
fixes = {
    'lib/screens/author/my_papers_page.dart': [
        # Fix CustomLoadingIndicator - change to CircularProgressIndicator
        (r'CustomLoadingIndicator\(\)', r'CircularProgressIndicator()'),
        # Fix _buildDetailRow calls with List<String>?
        (r"_buildDetailRow\('Authors',\s*paper\.authors\)", r"_buildDetailRow('Authors', paper.authors?.join(', ') ?? 'Unknown')"),
        # Fix _buildDetailRow calls with DateTime
        (r"_buildDetailRow\('Submitted',\s*paper\.submittedDate\)", r"_buildDetailRow('Submitted', '${paper.submittedDate.day}/${paper.submittedDate.month}/${paper.submittedDate.year}')"),
    ],
    'lib/screens/author/proceedings_page.dart': [
        (r'CustomLoadingIndicator\(\)', r'CircularProgressIndicator()'),
        (r"paper\.authors,", r"paper.authors?.join(', ') ?? 'Unknown',"),
        (r"paper\.submittedDate,", r"'${paper.submittedDate.day}/${paper.submittedDate.month}/${paper.submittedDate.year}',"),
        (r"_buildDetailRow\('Authors',\s*paper\.authors\)", r"_buildDetailRow('Authors', paper.authors?.join(', ') ?? 'Unknown')"),
        (r"_buildDetailRow\('Published',\s*paper\.submittedDate\)", r"_buildDetailRow('Published', '${paper.submittedDate.day}/${paper.submittedDate.month}/${paper.submittedDate.year}')"),
    ],
    'lib/screens/admin/track_process_page.dart': [
        (r'CustomLoadingIndicator\(\)', r'CircularProgressIndicator()'),
        (r"paper\.authors,", r"paper.authors?.join(', ') ?? 'Unknown',"),
        (r"paper\.submittedDate,", r"'${paper.submittedDate.day}/${paper.submittedDate.month}/${paper.submittedDate.year}',"),
        (r"_buildDetailRow\('Authors',\s*paper\.authors\)", r"_buildDetailRow('Authors', paper.authors?.join(', ') ?? 'Unknown')"),
        (r"_buildDetailRow\('Submitted',\s*paper\.submittedDate\)", r"_buildDetailRow('Submitted', '${paper.submittedDate.day}/${paper.submittedDate.month}/${paper.submittedDate.year}')"),
    ],
    'lib/screens/reviewer/review_paper_page.dart': [
        (r"_buildInfoRow\('Authors',\s*widget\.paper\.authors,\s*Icons\.people\)", r"_buildInfoRow('Authors', widget.paper.authors?.join(', ') ?? 'Unknown', Icons.people)"),
        (r"_buildInfoRow\('Submitted',\s*widget\.paper\.submittedDate,\s*Icons\.calendar_today\)", r"_buildInfoRow('Submitted', '${widget.paper.submittedDate.day}/${widget.paper.submittedDate.month}/${widget.paper.submittedDate.year}', Icons.calendar_today)"),
    ],
    'lib/screens/reviewer/reviewer_paper_page.dart': [
        (r"_buildInfoRow\('Submitted',\s*widget\.paper\.submittedDate,\s*Icons\.calendar_today\)", r"_buildInfoRow('Submitted', '${widget.paper.submittedDate.day}/${widget.paper.submittedDate.month}/${widget.paper.submittedDate.year}', Icons.calendar_today)"),
        (r"widget\.paper\.authors\.split\(','\)\.map\(\(e\)\s*=>\s*e\.trim\(\)\)\.toList\(\)", r"widget.paper.authors ?? []"),
    ],
    'lib/screens/reviewer/reviewer_home_page.dart': [
        (r'CustomLoadingIndicator\(\)', r'CircularProgressIndicator()'),
    ],
    'lib/screens/author/paper_detail_page.dart': [
        (r"_buildInfoRow\('Authors',\s*widget\.paper\.authors,\s*Icons\.people\)", r"_buildInfoRow('Authors', widget.paper.authors?.join(', ') ?? 'Unknown', Icons.people)"),
        (r"_buildInfoRow\('Submitted',\s*widget\.paper\.submittedDate,\s*Icons\.calendar_today\)", r"_buildInfoRow('Submitted', '${widget.paper.submittedDate.day}/${widget.paper.submittedDate.month}/${widget.paper.submittedDate.year}', Icons.calendar_today)"),
        (r"widget\.paper\.submittedDate,", r"'${widget.paper.submittedDate.day}/${widget.paper.submittedDate.month}/${widget.paper.submittedDate.year}',"),
    ],
}

# Run fixes
print("🔧 Fixing build errors...")
print()

base_dir = os.path.dirname(os.path.abspath(__file__))
fixed_count = 0

for filepath, patterns in fixes.items():
    full_path = os.path.join(base_dir, filepath)
    if fix_file(full_path, patterns):
        fixed_count += 1

print()
print(f"✅ Fixed {fixed_count}/{len(fixes)} files")
print()
print("Now run: flutter run")
