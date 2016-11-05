From: Alasdair Kergon <agk@fedoraproject.org>
Date: Sat,  5 Nov 2016 01:14:25 +0000 (UTC)
Subject: master - pre-release
Message-ID: <20161105011425.BD5DF60F5C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=eed708dbd985f06ff73494cf688ab7ee54e2d1e7
Commit:        eed708dbd985f06ff73494cf688ab7ee54e2d1e7
Parent:        6dce0e948935678e647dddeeea816cb4937f078a
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Sat Nov 5 01:03:32 2016 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Sat Nov 5 01:03:32 2016 +0000

pre-release

---
 VERSION      |    2 +-
 VERSION_DM   |    2 +-
 WHATS_NEW    |    4 ++--
 WHATS_NEW_DM |    6 +++---
 4 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/VERSION b/VERSION
index b2fc25f..aceedeb 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.02.167(2)-git (2016-09-26)
+2.02.167(2)-git (2016-11-05)
diff --git a/VERSION_DM b/VERSION_DM
index 087153f..efc7dd5 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.136-git (2016-09-26)
+1.02.136-git (2016-11-05)
diff --git a/WHATS_NEW b/WHATS_NEW
index a5e6d45..379bd3b 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,5 @@
-Version 2.02.167 - 
-======================================
+Version 2.02.167 - 5th November 2016
+====================================
   Use log_error in regex and sysfs filter to describe reason of failure.
   Fix blkdeactivate to deactivate dev stack if dev on top already unmounted.
   Prevent non-synced raid1 repair unless --force
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 17c370c..bf16842 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,8 +1,8 @@
-Version 1.02.136 - 
-======================================
+Version 1.02.136 - 5th November 2016
+====================================
   Log failure of raid device with log_error level.
   Use dm_log_with_errno and translate runtime to dm_log only when needed.
-  Make log messages from dm and lvm library differnt from dmeventd.
+  Make log messages from dm and lvm library different from dmeventd.
   Notice and Info messages are again logged from dmeventd and its plugins.
   Dmeventd now also respects DM_ABORT_ON_INTERNAL_ERRORS as libdm based tool.
   Report as non default dm logging also when logging with errno was changed.


