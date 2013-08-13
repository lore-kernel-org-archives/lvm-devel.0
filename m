From: Alasdair Kergon <agk@fedoraproject.org>
Date: Tue, 13 Aug 2013 11:46:58 +0000 (UTC)
Subject: master - release 2.02.100
Message-ID: <20130813114658.140F961198@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=297907899c389fef074eeb56fd0d7b60d66dbb35
Commit:        297907899c389fef074eeb56fd0d7b60d66dbb35
Parent:        abc89422af75fa9e20d24285d1366e4631cb8748
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Aug 13 11:29:21 2013 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Aug 13 11:29:21 2013 +0100

release 2.02.100

 84 files changed, 1540 insertions(+), 442 deletions(-)

Mostly bug fixes this time.

Also note:
  md raid replaces dm mirroring as the default implementation.
  Can call out to thin_repair to fix thin metadata.
  Improved clvmd error detection/debugging information.
---
 VERSION      |    2 +-
 VERSION_DM   |    2 +-
 WHATS_NEW    |    9 +++++----
 WHATS_NEW_DM |    4 ++--
 4 files changed, 9 insertions(+), 8 deletions(-)

diff --git a/VERSION b/VERSION
index 1716ee6..c7d4f06 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.02.100(2)-git (2013-07-24)
+2.02.100(2)-git (2013-08-13)
diff --git a/VERSION_DM b/VERSION_DM
index 067a488..a11b7cd 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.79-git (2013-07-24)
+1.02.79-git (2013-08-13)
diff --git a/WHATS_NEW b/WHATS_NEW
index 68d4679..20331c3 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,17 +1,18 @@
-Version 2.02.100 -
-================================
+Version 2.02.100 - 13th August 2013
+===================================
   Fix inability to remove a VG's cluster flag if it contains a mirror.
   Suppress arg: prefix in log_sys_error macro when arg is empty string.
   Fix bug making lvchange unable to change recovery rate for RAID.
   Prohibit conversion of thin pool to external origin.
   Workaround gcc v4.8 -O2 bug causing failures if config/checks=1 (32bit arch).
   Verify clvmd message validity before processing and log error if incorrect.
-  Fix issue preventing PV creation on mirror LVs
+  When creating PV on existing LV don't forbid reserved LV names on LVs below.
+  Split out device_is_suspended_or_blocking from device_is_usable.
   When converting mirrors, default segtype should be the same unless specified.
   Make "raid1" the default mirror segment type.
   Fix clogd descriptor leak when daemonizing.
   Fix clvmd descriptor leak on restart.
-  Add pipe_open/close() to replace less secure popen() glibc call.
+  Add pipe_open/close() to use instead of less efficient/secure popen().
   Fix metadata area offset/size overflow if it's >= 4g and while using lvmetad.
   Inherit and apply any profile attached to a VG if creating new thin pool.
   Add initial support thin pool lvconvert --repair.
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 43eb4d8..0ef1755 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,5 @@
-Version 1.02.79 -
-================================
+Version 1.02.79 - 13th August 2013
+==================================
   Create dmeventd timeout threads as "detached" so exit status is freed.
   Add DM_ABORT_ON_INTERNAL_ERRORS env var support to abort on internal errors.
 


