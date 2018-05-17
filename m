From: Joe Thornber <thornber@sourceware.org>
Date: Thu, 17 May 2018 05:06:02 -0400
Subject: master - scripts/code-stats.rb: count files better, handle bad utf8
Message-ID: <201805170906.w4H962Q6015844@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3417d6229dcdcb2e1c9595026a8f97d10f25804a
Commit:        3417d6229dcdcb2e1c9595026a8f97d10f25804a
Parent:        64dd656ef7943f9991c83802dfa5f762c902e1fb
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Thu May 17 09:52:13 2018 +0100
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Thu May 17 09:52:13 2018 +0100

scripts/code-stats.rb: count files better, handle bad utf8

---
 scripts/code-stats.rb |   28 +++++++++++++++++++---------
 1 files changed, 19 insertions(+), 9 deletions(-)

diff --git a/scripts/code-stats.rb b/scripts/code-stats.rb
index e87de26..d73343b 100755
--- a/scripts/code-stats.rb
+++ b/scripts/code-stats.rb
@@ -2,21 +2,22 @@
 
 require 'date'
 require 'pp'
+require 'set'
 
 REGEX = /(\w+)\s+'(.+)'\s+(.*)/
 
 Commit = Struct.new(:hash, :time, :author, :stats)
-CommitStats = Struct.new(:nr_files, :nr_added, :nr_deleted)
+CommitStats = Struct.new(:files, :nr_added, :nr_deleted)
 
 def calc_stats(diff)
-        changed = 0
+        changed = Set.new
         added = 0
         deleted = 0
         
         diff.lines.each do |l|
-        	case l
-                when /^\+\+\+/
-                        changed = changed + 1
+        	case l.encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')
+                when /^\+\+\+ (\S+)/
+                        changed << $1
                 when /^\+/
                         added = added + 1
                 when /^---/
@@ -61,20 +62,29 @@ def pad(str, col)
         str + (' ' * (col - str.size))
 end
 
+def code_delta(s)
+        s.nr_added + s.nr_deleted
+end
+
+def cmp_stats(lhs, rhs)
+        code_delta(rhs) <=> code_delta(lhs)
+end
+
 #-----------------------------------
 
 commits = select_commits(&since(DateTime.now - 14))
 
-authors = Hash.new {|hash, key| hash[key] = CommitStats.new(0, 0, 0)}
+authors = Hash.new {|hash, key| hash[key] = CommitStats.new(Set.new, 0, 0)}
 
 commits.each do |c|
 	author_stats = authors[c.author]
-	author_stats.nr_files = author_stats.nr_files + c.stats.nr_files
+	author_stats.files.merge(c.stats.files)
 	author_stats.nr_added = author_stats.nr_added + c.stats.nr_added
 	author_stats.nr_deleted = author_stats.nr_deleted + c.stats.nr_deleted
 end
 
 puts "#{pad("Author", 20)}\tChanged files\tInsertions\tDeletions"
-authors.each_pair do |k, v|
-	puts "#{pad(k, 20)}\t#{v.nr_files}\t\t#{v.nr_added}\t\t#{v.nr_deleted}"
+authors.keys.sort {|a1, a2| cmp_stats(authors[a1], authors[a2])}.each do |k|
+	v = authors[k]
+	puts "#{pad(k, 20)}\t#{v.files.size}\t\t#{v.nr_added}\t\t#{v.nr_deleted}"
 end


