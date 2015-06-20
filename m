From: Alasdair Kergon <agk@fedoraproject.org>
Date: Sat, 20 Jun 2015 00:04:02 +0000 (UTC)
Subject: master - pre-release
Message-ID: <20150620000402.5929D60DE9@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=134b727b4f577c3e4b1a210e41d20136bc8bd876
Commit:        134b727b4f577c3e4b1a210e41d20136bc8bd876
Parent:        b45e9183bc276da207c62072726b973e3d6a429c
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Sat Jun 20 00:57:35 2015 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Sat Jun 20 00:57:35 2015 +0100

pre-release

---
 VERSION      |    2 +-
 VERSION_DM   |    2 +-
 WHATS_NEW    |   11 ++++++-----
 WHATS_NEW_DM |    4 +++-
 4 files changed, 11 insertions(+), 8 deletions(-)

diff --git a/VERSION b/VERSION
index ac44695..9f836eb 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.02.122(2)-git (2015-06-12)
+2.02.122(2)-git (2015-06-20)
diff --git a/VERSION_DM b/VERSION_DM
index eb763e0..00645cd 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.99-git (2015-06-12)
+1.02.99-git (2015-06-20)
diff --git a/WHATS_NEW b/WHATS_NEW
index 8ea02cd..5d97a43 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,11 +1,12 @@
-Version 2.02.122 - 
+Version 2.02.122 - 20th June 2015
 =================================
-  Avoid allocation in display_lvname internal function.
+  Flush stdout before printing to stderr.
+  Use pre-allocated buffer for printed LV names in display_lvname.
   Support thins with size of external origin unaligned with thin pool chunk.
-  Allow to extend reduced thin volumes with external origins.
-  Consider snapshot and origin LV as unusable if its component is suspended.
+  Allow extension of reduced thin volumes with external origins.
+  Consider snapshot and origin LV as unusable if component devices suspended.
   Fix lvmconfig segfault on settings with undefined default value (2.02.120).
-  Add explicit 's' (shared) activation mode.
+  Add explicit 's' (shared) LV activation mode.
   Ignore hyphens in long options names (i.e. --long-option == --longoption).
 
 Version 2.02.121 - 12th June 2015
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index d87e2bd..25fd2f9 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,7 +1,9 @@
-Version 1.02.99 - 
+Version 1.02.99 - 20th June 2015
 ================================
   New dm_tree_node_set_thin_pool_read_only(DM_1_02_99) for read-only thin pool.
   Enhance error message when thin-pool message fails.
+  Fix dmeventd logging to avoid threaded use of static variable.
+  Remove redundant dmeventd SIGALRM coded.
 
 Version 1.02.98 - 12th June 2015
 ================================


