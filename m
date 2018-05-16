From: Joe Thornber <thornber@sourceware.org>
Date: Wed, 16 May 2018 10:28:56 -0400
Subject: master - scripts: add a little scripts to show git history for the last 2 weeks.
Message-ID: <201805161428.w4GESudc026166@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=64dd656ef7943f9991c83802dfa5f762c902e1fb
Commit:        64dd656ef7943f9991c83802dfa5f762c902e1fb
Parent:        7c852c75c3b3e719d57d3410bf0c2a5e61d67f4e
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Wed May 16 15:27:52 2018 +0100
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Wed May 16 15:27:52 2018 +0100

scripts: add a little scripts to show git history for the last 2 weeks.

---
 scripts/code-stats.rb |   80 +++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 80 insertions(+), 0 deletions(-)

diff --git a/scripts/code-stats.rb b/scripts/code-stats.rb
new file mode 100755
index 0000000..e87de26
--- /dev/null
+++ b/scripts/code-stats.rb
@@ -0,0 +1,80 @@
+#! /usr/bin/env ruby
+
+require 'date'
+require 'pp'
+
+REGEX = /(\w+)\s+'(.+)'\s+(.*)/
+
+Commit = Struct.new(:hash, :time, :author, :stats)
+CommitStats = Struct.new(:nr_files, :nr_added, :nr_deleted)
+
+def calc_stats(diff)
+        changed = 0
+        added = 0
+        deleted = 0
+        
+        diff.lines.each do |l|
+        	case l
+                when /^\+\+\+/
+                        changed = changed + 1
+                when /^\+/
+                        added = added + 1
+                when /^---/
+                        # do nothing
+                when /^\-/
+                        deleted = deleted + 1
+        	end
+	end
+
+	CommitStats.new(changed, added, deleted)
+end
+
+def select_commits(&block)
+        commits = []
+        
+	input = `git log --format="%h '%aI' %an"`
+	input.lines.each do |l|
+		m = REGEX.match(l)
+
+		raise "couldn't parse: ${l}" unless m
+
+		hash = m[1]
+		time = DateTime.iso8601(m[2])
+		author = m[3]
+
+		if block.call(hash, time, author)
+        		diff = `git log -1 -p #{hash} | filterdiff -X configure`
+        		commits << Commit.new(hash, time, author, calc_stats(diff))
+		end
+	end
+	
+	commits
+end
+
+def since(date)
+        lambda do |hash, time, author|
+        	time >= date
+        end
+end
+
+def pad(str, col)
+        str + (' ' * (col - str.size))
+end
+
+#-----------------------------------
+
+commits = select_commits(&since(DateTime.now - 14))
+
+authors = Hash.new {|hash, key| hash[key] = CommitStats.new(0, 0, 0)}
+
+commits.each do |c|
+	author_stats = authors[c.author]
+	author_stats.nr_files = author_stats.nr_files + c.stats.nr_files
+	author_stats.nr_added = author_stats.nr_added + c.stats.nr_added
+	author_stats.nr_deleted = author_stats.nr_deleted + c.stats.nr_deleted
+end
+
+puts "#{pad("Author", 20)}\tChanged files\tInsertions\tDeletions"
+authors.each_pair do |k, v|
+	puts "#{pad(k, 20)}\t#{v.nr_files}\t\t#{v.nr_added}\t\t#{v.nr_deleted}"
+end


