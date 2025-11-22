#!/bin/bash

# Fix all IconData to Icon() wrapper in profile pages
echo "Fixing IconData to Icon() wrapper..."

# Fix author_profile_page.dart
sed -i '' 's/prefixIcon: Icons\.\([a-z_]*\),/prefixIcon: Icon(Icons.\1),/g' lib/screens/author/author_profile_page.dart

# Fix reviewer_profile_page.dart  
sed -i '' 's/prefixIcon: Icons\.\([a-z_]*\),/prefixIcon: Icon(Icons.\1),/g' lib/screens/reviewer/reviewer_profile_page.dart

echo "Fixed IconData errors!"

# Fix nullable List<String>? toLowerCase issues
echo "Fixing nullable authors issues..."

# Fix in my_papers_page.dart
sed -i '' 's/paper\.authors\.toLowerCase()/paper.authors?.join(" ")?.toLowerCase() ?? ""/g' lib/screens/author/my_papers_page.dart

# Fix in proceedings_page.dart
sed -i '' 's/paper\.authors\.toLowerCase()/paper.authors?.join(" ")?.toLowerCase() ?? ""/g' lib/screens/author/proceedings_page.dart

# Fix in track_process_page.dart
sed -i '' 's/paper\.authors\.toLowerCase()/paper.authors?.join(" ")?.toLowerCase() ?? ""/g' lib/screens/admin/track_process_page.dart

echo "All fixes applied!"
