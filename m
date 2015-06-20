From: Alasdair Kergon <agk@fedoraproject.org>
Date: Sat, 20 Jun 2015 00:05:27 +0000 (UTC)
Subject: master - post-release
Message-ID: <20150620000527.8FA1B60CFA@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=50d70eff352fd651a68b8edbd9a7fcbe30300726
Commit:        50d70eff352fd651a68b8edbd9a7fcbe30300726
Parent:        134b727b4f577c3e4b1a210e41d20136bc8bd876
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Sat Jun 20 01:05:21 2015 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Sat Jun 20 01:05:21 2015 +0100

post-release

---
 VERSION      |    2 +-
 VERSION_DM   |    2 +-
 WHATS_NEW    |    3 +++
 WHATS_NEW_DM |    3 +++
 4 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/VERSION b/VERSION
index 9f836eb..737d5a2 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.02.122(2)-git (2015-06-20)
+2.02.123(2)-git (2015-06-20)
diff --git a/VERSION_DM b/VERSION_DM
index 00645cd..7d2906a 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.99-git (2015-06-20)
+1.02.100-git (2015-06-20)
diff --git a/WHATS_NEW b/WHATS_NEW
index 5d97a43..7da2b51 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,3 +1,6 @@
+Version 2.02.123 - 
+=================================
+
 Version 2.02.122 - 20th June 2015
 =================================
   Flush stdout before printing to stderr.
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 25fd2f9..d4b1639 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,3 +1,6 @@
+Version 1.02.100 - 
+================================
+
 Version 1.02.99 - 20th June 2015
 ================================
   New dm_tree_node_set_thin_pool_read_only(DM_1_02_99) for read-only thin pool.


