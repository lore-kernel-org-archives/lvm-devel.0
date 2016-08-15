From: Alasdair Kergon <agk@fedoraproject.org>
Date: Mon, 15 Aug 2016 12:25:25 +0000 (UTC)
Subject: master - pre-release
Message-ID: <20160815122525.3D4D260AA6@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=829727696700ac509e8e89f669245947e830c8f6
Commit:        829727696700ac509e8e89f669245947e830c8f6
Parent:        2ff893cd854733de0c9e82edc9e57f55c3d9ce7a
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon Aug 15 13:01:27 2016 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Mon Aug 15 13:17:47 2016 +0100

pre-release

---
 VERSION      |    2 +-
 VERSION_DM   |    2 +-
 WHATS_NEW    |    5 ++++-
 WHATS_NEW_DM |    3 ---
 4 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/VERSION b/VERSION
index 5e46ebc..cce77c2 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.02.164(2)-git (2016-08-10)
+2.02.164(2)-git (2016-08-15)
diff --git a/VERSION_DM b/VERSION_DM
index a5de990..b07196b 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.134-git (2016-08-10)
+1.02.133-git (2016-08-15)
diff --git a/WHATS_NEW b/WHATS_NEW
index 425729a..61ae56d 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,8 @@
-Version 2.02.164 -
+Version 2.02.164 - 15th August 2016
 ===================================
+  Fix selection of PVs when allocating raid0_meta.
+  Fix sdbus socket leak leading to hang in lvmnotify.
+  Specify max stripes for raid LV types: raid0:64; 1:10; 4,5:63; 6:62; 10:32.
   Avoid double suffix when naming _rmeta LV paired with _rimage LV.
 
 Version 2.02.163 - 10th August 2016
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 7bbfd88..2b32d76 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,6 +1,3 @@
-Version 1.02.134 - 
-===================================
-
 Version 1.02.133 - 10th August 2016
 ===================================
   Add dm_report_destroy_rows/dm_report_group_output_and_pop_all for lvm shell.


