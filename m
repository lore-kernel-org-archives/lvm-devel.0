From: Alasdair Kergon <agk@fedoraproject.org>
Date: Tue, 28 Jun 2016 01:33:11 +0000 (UTC)
Subject: master - pre-release
Message-ID: <20160628013311.AD34160E26@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=887f071b2545bb2b60e13de854898ab71a6b0ff5
Commit:        887f071b2545bb2b60e13de854898ab71a6b0ff5
Parent:        15b932a70e4a29f386ea57e1b845d637780b463b
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Sat Jun 25 20:35:14 2016 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Sat Jun 25 20:35:14 2016 +0100

pre-release

---
 VERSION      |    2 +-
 VERSION_DM   |    2 +-
 WHATS_NEW    |    5 ++++-
 WHATS_NEW_DM |    2 +-
 4 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/VERSION b/VERSION
index 34e00b1..8cb5c44 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.02.158(2)-git (2016-06-17)
+2.02.158(2)-git (2016-06-25)
diff --git a/VERSION_DM b/VERSION_DM
index dd57819..389871f 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.128-git (2016-06-17)
+1.02.128-git (2016-06-25)
diff --git a/WHATS_NEW b/WHATS_NEW
index 7238568..530ece8 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,10 +1,13 @@
-Version 2.02.158 - 
+Version 2.02.158 - 25th June 2016
 =================================
   Pool metadata lvresize uses now same code as resize of normal volume.
   Preserve monitoring status when updating thin-pool metadata.
   Return 0 (inactive) when status cannot be queried in _lv_active().
   Switch to log_warn() for failing activation status query.
+  Replace vgimportclone script with binary.
+  While lvmetad is shutting down, continue handling all connections cleanly.
   Refactor lvconvert argument handling code.
+  Notify lvmetad when vgcfgrestore changes VG metadata.
   Add --logonly option to report only cmd log for a command, not other reports.
   Add log/command_log_selection to configure default selection used on cmd log.
   Use 'orphan' object type in cmd log for groups to collect PVs not yet in VGs.
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 8911e36..a03308b 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,4 +1,4 @@
-Version 1.02.128 -
+Version 1.02.128 - 25th June 2016
 =================================
   Recognize 'all' keyword used in selection as synonym for "" (no selection).
   Add dm_report_set_selection to set selection for multiple output of report.


