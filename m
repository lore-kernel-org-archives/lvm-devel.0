From: Alasdair Kergon <agk@fedoraproject.org>
Date: Mon, 15 Aug 2016 12:25:27 +0000 (UTC)
Subject: master - post-release
Message-ID: <20160815122527.51B6560AA6@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c7bd33d9516dd6d146a02b4af43eb142a4f0aa26
Commit:        c7bd33d9516dd6d146a02b4af43eb142a4f0aa26
Parent:        829727696700ac509e8e89f669245947e830c8f6
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon Aug 15 13:23:06 2016 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Mon Aug 15 13:23:06 2016 +0100

post-release

---
 VERSION      |    2 +-
 VERSION_DM   |    2 +-
 WHATS_NEW    |    3 +++
 WHATS_NEW_DM |    3 +++
 4 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/VERSION b/VERSION
index cce77c2..58f1a65 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.02.164(2)-git (2016-08-15)
+2.02.165(2)-git (2016-08-15)
diff --git a/VERSION_DM b/VERSION_DM
index b07196b..7cfcd9a 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.133-git (2016-08-15)
+1.02.134-git (2016-08-15)
diff --git a/WHATS_NEW b/WHATS_NEW
index 61ae56d..d78b281 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,3 +1,6 @@
+Version 2.02.165 - 
+===================================
+
 Version 2.02.164 - 15th August 2016
 ===================================
   Fix selection of PVs when allocating raid0_meta.
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 2b32d76..7bbfd88 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,3 +1,6 @@
+Version 1.02.134 - 
+===================================
+
 Version 1.02.133 - 10th August 2016
 ===================================
   Add dm_report_destroy_rows/dm_report_group_output_and_pop_all for lvm shell.


